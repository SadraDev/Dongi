from .models import Friendship
from .serializers import FriendRequestSerializer
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .serializers import RegisterSerializer, LoginSerializer, UserSerializer
from rest_framework.views import APIView
from django.db.models import Q
from .serializers import UserSearchSerializer
from django.contrib.auth import get_user_model


User = get_user_model()

class UserSearchView(generics.ListAPIView):
    serializer_class = UserSearchSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        query = self.request.query_params.get('q', '')
        # Filter users by username, excluding the current logged-in user
        if query:
            return User.objects.filter(username__icontains=query).exclude(id=self.request.user.id)
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
        # Get users who are in an 'accepted' friendship with the requester
        friendships = Friendship.objects.filter(
            Q(sender=request.user) | Q(receiver=request.user), 
            status='accepted'
        )
        friends = []
        for f in friendships:
            friend = f.receiver if f.sender == request.user else f.sender
            friends.append({'id': f.id, 'username': friend.username})
        return Response(friends)

class RemoveFriendView(generics.DestroyAPIView):
    permission_classes = [permissions.IsAuthenticated]
    queryset = Friendship.objects.all()

    def get_queryset(self):
        return Friendship.objects.filter(Q(sender=self.request.user) | Q(receiver=self.request.user))
