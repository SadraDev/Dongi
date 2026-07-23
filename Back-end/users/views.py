from .models import Friendship
from .serializers import FriendRequestSerializer, UserAvatarSerializer
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .serializers import RegisterSerializer, LoginSerializer, UserSerializer
from rest_framework.views import APIView
from django.db.models import Q, Case, When, Value, IntegerField, Sum
from .serializers import UserSearchSerializer
from django.contrib.auth import get_user_model

# Import ExpenseSplit to calculate cross-group balances
from expenses.models import ExpenseSplit

User = get_user_model()

class UserAvatarView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response({"avatar_index": request.user.avatar_index})

    def patch(self, request):
        serializer = UserAvatarSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserSearchView(generics.ListAPIView):
    serializer_class = UserSearchSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        query = self.request.query_params.get('q', '')
        
        # Filter users by username, excluding the current logged-in user
        if query:
            return User.objects.filter(
                username__icontains=query
            ).exclude(
                id=self.request.user.id
            ).annotate(
                match_rank=Case(
                    # Exact case-sensitive match
                    When(username=query, then=Value(1)),
                    
                    # Case-sensitive prefix match
                    When(username__startswith=query, then=Value(2)),
                    
                    # Exact case-insensitive match
                    When(username__iexact=query, then=Value(3)),
                    
                    # Case-insensitive prefix match
                    When(username__istartswith=query, then=Value(4)),
                    
                    # Everything else (partial matches inside the string)
                    default=Value(5),
                    output_field=IntegerField()
                )
            ).order_by('match_rank', 'username')
            
        return User.objects.none()

class RegisterAPIView(generics.GenericAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny] # Anyone can register

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Generate a token for the new user
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            "user": UserSerializer(user, context=self.get_serializer_context()).data,
            "token": token.key
        })

class LoginAPIView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny] # Anyone can attempt login

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        
        # Get or create the token for the logging-in user
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            "user": UserSerializer(user, context=self.get_serializer_context()).data,
            "token": token.key
        })

class SendFriendRequestView(generics.CreateAPIView):
    serializer_class = FriendRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)

class ReceivedFriendRequestsView(generics.ListAPIView):
    serializer_class = FriendRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Friendship.objects.filter(receiver=self.request.user, status='pending')

class AcceptFriendRequestView(generics.UpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    queryset = Friendship.objects.all()

    def update(self, request, *args, **kwargs):
        friendship = self.get_object()
        if friendship.receiver == request.user:
            friendship.status = 'accepted'
            friendship.save()
            return Response({'status': 'accepted'})
        return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)

class RejectFriendRequestView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, pk):
        try:
            friendship = Friendship.objects.get(pk=pk)
        except Friendship.DoesNotExist:
            return Response({"error": "Friend request not found."}, status=status.HTTP_404_NOT_FOUND)

        if friendship.receiver != request.user:
            return Response({"error": "Unauthorized"}, status=status.HTTP_403_FORBIDDEN)

        if friendship.status != 'pending':
            return Response({"error": "This request has already been handled."}, status=status.HTTP_400_BAD_REQUEST)

        friendship.delete()
        return Response({"status": "rejected"}, status=status.HTTP_200_OK)

class FriendsListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        # Get users who are in an 'accepted' friendship with the requester
        friendships = Friendship.objects.filter(
            Q(sender=user) | Q(receiver=user), 
            status='accepted'
        )
        friends = []
        for f in friendships:
            friend = f.receiver if f.sender == user else f.sender
            
            # 1. Total YOU are owed by this friend (Overall)
            owed_to_me = ExpenseSplit.objects.filter(
                expense__payer=user,
                user=friend,
                is_paid=False
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            # 2. Total YOU owe this friend (Overall)
            owed_by_me = ExpenseSplit.objects.filter(
                expense__payer=friend,
                user=user,
                is_paid=False
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            balance = float(owed_to_me) - float(owed_by_me)

            # 3. Total Direct YOU are owed by this friend (No group)
            direct_owed_to_me = ExpenseSplit.objects.filter(
                expense__payer=user,
                user=friend,
                is_paid=False,
                expense__group__isnull=True
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            # 4. Total Direct YOU owe this friend (No group)
            direct_owed_by_me = ExpenseSplit.objects.filter(
                expense__payer=friend,
                user=user,
                is_paid=False,
                expense__group__isnull=True
            ).aggregate(total=Sum('amount_owed'))['total'] or 0.0

            direct_balance = float(direct_owed_to_me) - float(direct_owed_by_me)

            friends.append({
                'id': friend.id, 
                'username': friend.username,
                'avatar_index': friend.avatar_index,
                'is_superuser': friend.is_superuser,
                'balance': balance,
                'direct_balance': direct_balance
            })
            
        return Response(friends)

class RemoveFriendView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, pk):
        # 1. Guard: Check for any unpaid expenses between the two users
        has_unpaid_expenses = ExpenseSplit.objects.filter(
            Q(expense__payer=request.user, user_id=pk, is_paid=False) |
            Q(expense__payer_id=pk, user=request.user, is_paid=False)
        ).exists()

        if has_unpaid_expenses:
            return Response(
                {"error": "Settle your expenses first"}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # 2. Proceed with deletion if no unpaid expenses exist
        try:
            # Find the friendship involving both the logged-in user and the friend
            friendship = Friendship.objects.get(
                (Q(sender=request.user) & Q(receiver_id=pk)) | 
                (Q(sender_id=pk) & Q(receiver=request.user))
            )
            friendship.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Friendship.DoesNotExist:
            return Response(
                {"error": "Friendship not found."}, 
                status=status.HTTP_404_NOT_FOUND
            )