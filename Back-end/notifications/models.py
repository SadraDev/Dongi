from django.db import models
from django.conf import settings

class Notification(models.Model):
    # This keeps your code organized
    NOTIFICATION_TYPES = (
        ('friend_request', 'Friend Request'),
        ('group_invite', 'Group Invite'),
        ('payment_reminder', 'Pay Up!'),
    )
    
    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    related_id = models.IntegerField(null=True, blank=True) # ID of the group/friendship

    class Meta:
        ordering = ['-created_at']