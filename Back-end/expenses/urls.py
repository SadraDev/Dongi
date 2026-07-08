from django.urls import path
from .views import (
    AcceptGroupInviteView, FriendDetailView, GroupCreateView, GroupDeleteView, 
    GroupDetailView, GroupListView, ExpenseCreateView,
    InviteGroupMemberView, SettleExpenseView, RejectGroupInviteView
)

urlpatterns = [
    path('groups/', GroupListView.as_view(), name='group-list'),
    path('groups/create/', GroupCreateView.as_view(), name='group-create'),
    path('groups/<int:pk>/accept/', AcceptGroupInviteView.as_view(), name='group-accept'),
    path('groups/<int:pk>/delete/', GroupDeleteView.as_view(), name='group-delete'),
    path('groups/<int:pk>/', GroupDetailView.as_view(), name='group-detail'),
    path('expenses/create/', ExpenseCreateView.as_view(), name='expense-create'),
    path('groups/<int:pk>/invite/', InviteGroupMemberView.as_view(), name='group-invite'),
    path('splits/<int:split_id>/settle/', SettleExpenseView.as_view(), name='settle-split'),
    path('groups/<int:pk>/reject/', RejectGroupInviteView.as_view(), name='group-reject'),
    path('friends/<int:pk>/', FriendDetailView.as_view(), name='friend-detail'),
]