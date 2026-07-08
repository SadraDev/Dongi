# notifications/views.py
from rest_framework import generics, permissions, status
from .models import Notification
from .serializers import NotificationSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from expenses.models import Group, GroupMember
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model

User = get_user_model()

class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Only fetch notifications that haven't been read yet
        return Notification.objects.filter(
            recipient=self.request.user, 
            is_read=False
        ).order_by('-created_at')
    

class NotificationUpdateView(generics.UpdateAPIView):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # Ensure users can only update their own notifications
        return Notification.objects.filter(recipient=self.request.user)
    

class UnreadCountView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        count = Notification.objects.filter(recipient=request.user, is_read=False).count()
        return Response({'count': count})


class SendPaymentReminderView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        recipient_id = request.data.get('recipient_id')
        expense_id = request.data.get('expense_id')

        if not recipient_id or not expense_id:
            return Response(
                {'error': 'Both recipient_id and expense_id are required fields.'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        from expenses.models import ExpenseSplit
        recipient = get_object_or_404(User, pk=recipient_id)

        # Security Check: Ensure the sender is the payer and the recipient actually owes them for this specific expense
        split = ExpenseSplit.objects.filter(
            expense_id=expense_id,
            expense__payer=request.user,
            user=recipient,
            is_paid=False
        ).first()

        if not split:
            return Response(
                {'error': 'Active unpaid expense split not found for this user.'}, 
                status=status.HTTP_404_NOT_FOUND
            )

        # Create the payment reminder notification using the actual amount owed
        Notification.objects.create(
            recipient=recipient,
            type='payment_reminder',
            message=f"{request.user.username} is reminding you to pay the fuck up Ŧ{split.amount_owed:.2f} for '{split.expense.description}'!",
            related_id=expense_id
        )

        return Response({'status': 'Payment reminder sent successfully.'}, status=status.HTTP_201_CREATED)