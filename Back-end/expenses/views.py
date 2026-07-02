from rest_framework import generics, permissions
from expenses.permissions import IsGroupCreator
from .models import Group, GroupMember, Expense, ExpenseSplit
from .serializers import GroupSerializer
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Sum

class GroupListView(generics.ListAPIView):
    serializer_class = GroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Use prefetch_related to ensure the serializer has fresh access to all splits
        return Group.objects.filter(
            memberships__user=self.request.user, 
            memberships__status='accepted'
        ).prefetch_related('expenses__splits')

class GroupCreateView(generics.CreateAPIView):
    serializer_class = GroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save()

class AcceptGroupInviteView(generics.UpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, pk):
        membership = GroupMember.objects.get(group_id=pk, user=request.user)
        membership.status = 'accepted'
        membership.save()
        return Response({'status': 'Accepted'})

class GroupDeleteView(generics.DestroyAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    permission_classes = [permissions.IsAuthenticated, IsGroupCreator]

class GroupDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        group = get_object_or_404(Group, pk=pk)
        user = request.user

        # 1. Security Check
        if not GroupMember.objects.filter(group=group, user=user, status='accepted').exists():
            return Response({"error": "You are not an active member of this group."}, status=403)

        # 2. Fetch Members & Calculate Balances
        members_data = []
        group_members = GroupMember.objects.filter(group=group).exclude(user=user)

        for member in group_members:
            # 1. Total YOU are owed by this member (Splits where you paid, they owe, is_paid=False)
            owed_to_me = ExpenseSplit.objects.filter(
                expense__group=group,
                expense__payer=user,
                user=member.user,
                is_paid=False
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            # 2. Total YOU owe this member (Splits where they paid, you owe, is_paid=False)
            owed_by_me = ExpenseSplit.objects.filter(
                expense__group=group,
                expense__payer=member.user,
                user=user,
                is_paid=False
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            balance = float(owed_to_me) - float(owed_by_me)

            members_data.append({
                "id": member.user.id,
                "name": member.user.username,
                "balance": balance,
                "status": member.status
            })

        # 3. Fetch Expenses & Splits
        expenses_data = []
        expenses = Expense.objects.filter(group=group).order_by('-created_at')

        for exp in expenses:
            paid_by_me = (exp.payer == user)
            
            splits_data = []
            for split in exp.splits.all():
                # FIX: Only include splits where the user owes money 
                # (is_paid=False) and is not the payer
                if split.user == exp.payer or split.is_paid:
                    continue
                    
                splits_data.append({
                    "id": split.id,
                    "user": split.user.id, # Included for your backend reminder calls
                    "name": "You" if split.user == user else split.user.username,
                    "amount": float(split.amount_owed),
                    "isPaid": split.is_paid
                })

            expenses_data.append({
                "id": exp.id,
                "title": exp.description,
                "amount": float(exp.total_amount),
                "paidByMe": paid_by_me,
                "payerName": "You" if paid_by_me else exp.payer.username,
                "splits": splits_data
            })

        return Response({
            "members": members_data,
            "expenses": expenses_data
        })

class ExpenseCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        group_id = request.data.get('group')
        group = get_object_or_404(Group, pk=group_id)

        if not GroupMember.objects.filter(group=group, user=request.user, status='accepted').exists():
            return Response({"error": "You are not an active member of this group."}, status=403)

        description = request.data.get('description', '')
        total_amount = float(request.data.get('total_amount', 0))
        divide_equally = request.data.get('divide_equally', True)

        expense = Expense.objects.create(
            group=group,
            payer=request.user,
            description=description,
            total_amount=total_amount
        )

        if divide_equally:
            active_memberships = GroupMember.objects.filter(group=group, status='accepted')
            member_count = active_memberships.count()
            if member_count > 0:
                amount_owed = total_amount / member_count
                for membership in active_memberships:
                    # FIX: Mark the payer as is_paid=True
                    ExpenseSplit.objects.create(
                        expense=expense,
                        user=membership.user,
                        amount_owed=amount_owed,
                        is_paid=(membership.user == request.user)
                    )
        else:
            custom_splits = request.data.get('custom_splits', [])
            for split in custom_splits:
                user_id = split.get('user_id')
                amount = float(split.get('amount_owed', 0))
                # FIX: Mark the payer as is_paid=True
                ExpenseSplit.objects.create(
                    expense=expense,
                    user_id=user_id,
                    amount_owed=amount,
                    is_paid=(user_id == request.user.id)
                )

        return Response({"status": "Expense created successfully"}, status=201)

class ToggleExpenseSplitView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        split = get_object_or_404(ExpenseSplit, pk=pk)
        if split.expense.payer != request.user:
            return Response({"error": "Only the expense payer can modify split logs."}, status=403)

        is_paid = request.data.get('is_paid')
        if is_paid is not None:
            split.is_paid = is_paid
            split.save()
            return Response({"status": "Updated", "is_paid": split.is_paid})
        return Response({"error": "Missing 'is_paid' field."}, status=400)


from django.contrib.auth import get_user_model
User = get_user_model()

class InviteGroupMemberView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        group = get_object_or_404(Group, pk=pk)
        
        # Security Check: Ensure the user sending the invite is an accepted member of this group
        if not GroupMember.objects.filter(group=group, user=request.user, status='accepted').exists():
            return Response({"error": "You must be an active member of this group to invite others."}, status=403)
        
        username = request.data.get('username')
        if not username:
            return Response({"error": "Username field is required."}, status=400)
            
        # Check if user exists before doing anything else
        try:
            invited_user = User.objects.get(username__iexact=username)
        except User.DoesNotExist:
            return Response({"error": "User does not exist"}, status=400)
        
        # Check 1: Are they already an accepted member?
        if GroupMember.objects.filter(group=group, user=invited_user, status='accepted').exists():
            return Response({"error": f"{username} is already a member of this group."}, status=400)
            
        # Check 2: Guard against duplicate invites - Is there already a pending invite?
        if GroupMember.objects.filter(group=group, user=invited_user, status='pending').exists():
            return Response({"error": "Invitation already sent"}, status=400)
            
        # Create pending invitation record (this automatically triggers the notification signal)
        GroupMember.objects.create(group=group, user=invited_user, status='pending')
        
        return Response({"status": f"Invitation successfully sent to {username}"}, status=201)
    
class SettleExpenseView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, split_id):
        split = get_object_or_404(ExpenseSplit, pk=split_id)

        # Security Check
        if request.user != split.expense.payer and request.user != split.user:
            return Response({"error": "Unauthorized"}, status=403)

        # Forcefully set is_paid based on the boolean sent in the request
        is_paid_val = request.data.get('is_paid')
        if is_paid_val is not None:
            split.is_paid = bool(is_paid_val)
            split.save()

        return Response({
            "status": "success", 
            "is_paid": split.is_paid
        })