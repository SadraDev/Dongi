# notifications/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from users.models import Friendship
from .models import Notification
from expenses.models import GroupMember

@receiver(post_save, sender=Friendship)
def create_friend_request_notification(sender, instance, created, **kwargs):
    if created and instance.status == 'pending':
        Notification.objects.create(
            recipient=instance.receiver,
            type='friend_request',
            message=f"{instance.sender.username} sent you a friend request!",
            related_id=instance.id
        )

@receiver(post_save, sender=GroupMember)
def notify_group_invite(sender, instance, created, **kwargs):
    if created and instance.status == 'pending':
        Notification.objects.create(
            recipient=instance.user,
            type='group_invite',
            message=f"You've been invited to join the group: {instance.group.name}",
            related_id=instance.group.id
        )