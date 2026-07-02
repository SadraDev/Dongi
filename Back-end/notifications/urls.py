from django.urls import path
from .views import NotificationListView, NotificationUpdateView, UnreadCountView, SendPaymentReminderView

urlpatterns = [
    # This maps /api/notifications/ to your List view
    path('', NotificationListView.as_view(), name='notification-list'),
    path('<int:pk>/', NotificationUpdateView.as_view(), name='notification-update'),
    path('unread-count/', UnreadCountView.as_view(), name='unread-count'),
    path('remind/', SendPaymentReminderView.as_view(), name='send-payment-reminder'),
]