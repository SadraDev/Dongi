from django.urls import path
from .views import (AcceptFriendRequestView, LoginAPIView, FriendsListView, 
                    ReceivedFriendRequestsView, RegisterAPIView, RemoveFriendView, 
                    SendFriendRequestView, UserSearchView, RejectFriendRequestView)

urlpatterns = [
    path('users/register/', RegisterAPIView.as_view(), name='register'),
    path('users/login/', LoginAPIView.as_view(), name='api_token_auth'),
    path('friends/send/', SendFriendRequestView.as_view(), name='send-friend-request'),
    path('friends/requests/', ReceivedFriendRequestsView.as_view(), name='list-friend-requests'),
    path('friends/accept/<int:pk>/', AcceptFriendRequestView.as_view(), name='accept-friend-request'),
    path('friends/list/', FriendsListView.as_view(), name='friends-list'),
    path('friends/remove/<int:pk>/', RemoveFriendView.as_view(), name='remove-friend'),
    path('users/search/', UserSearchView.as_view(), name='user-search'),
    path('friends/reject/<int:pk>/', RejectFriendRequestView.as_view(), name='reject-friend-request'),
]