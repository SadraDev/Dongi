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
        group_id = request.data.get('group_id')

        if not recipient_id or not group_id:
            return Response(
                {'error': 'Both recipient_id and group_id are required fields.'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        group = get_object_or_404(Group, pk=group_id)
        recipient = get_object_or_404(User, pk=recipient_id)

        # Security Check: Ensure the sender is an active member of this group
        if not GroupMember.objects.filter(group=group, user=request.user, status='accepted').exists():
            return Response(
                {'error': 'You are not an active member of this group.'}, 
                status=status.HTTP_403_FORBIDDEN
            )

        # Check: Ensure the recipient is an active member of this group
        if not GroupMember.objects.filter(group=group, user=recipient, status='accepted').exists():
            return Response(
                {'error': 'The designated recipient is not a member of this group.'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create the payment reminder notification
        Notification.objects.create(
            recipient=recipient,
            type='payment_reminder',
            message=f"{request.user.username} is reminding you to pay the fuck up in group '{group.name}'!",
            related_id=group.id
        )

        return Response({'status': 'Payment reminder sent successfully.'}, status=status.HTTP_201_CREATED)