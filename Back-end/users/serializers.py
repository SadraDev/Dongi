from rest_framework import serializers
from django.contrib.auth import get_user_model, authenticate
from .models import Friendship

User = get_user_model()

class UserSearchSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'avatar_index', 'is_superuser')

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'avatar_index', 'is_superuser')

class UserAvatarSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('avatar_index',)

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'password')

    def validate_username(self, value):
        # 1. Check for reserved usernames (Case-Insensitive)
        # Converts the incoming username to lowercase and checks it against the reserved words
        lower_value = value.lower()
        reserved = getattr(User, 'RESERVED_USERNAMES', ['god', 'dio'])
        
        if any(r.lower() in lower_value for r in reserved):
            raise serializers.ValidationError("There can only be one God.")
        
        # 2. Check for case-insensitive uniqueness
        if User.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError("A user with this username already exists.")
        
        return value

    def create(self, validated_data):
        # We must use create_user so the password gets hashed (encrypted)
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password']
        )
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')
        
        # Try to find the user with a case-insensitive username match
        user_obj = User.objects.filter(username__iexact=username).first()
        
        if user_obj:
            # Now authenticate with the actual username from the database
            user = authenticate(username=user_obj.username, password=password)
            if user and user.is_active:
                return user
            
        raise serializers.ValidationError("Incorrect username or password.")


class FriendRequestSerializer(serializers.ModelSerializer):
    sender = serializers.SlugRelatedField(read_only=True, slug_field='username')
    receiver = serializers.SlugRelatedField(queryset=User.objects.all(), slug_field='username')

    class Meta:
        model = Friendship
        fields = ('id', 'sender', 'receiver', 'status')

    def validate(self, data):
        request = self.context.get('request')
        
        # Ensure we have the request context to identify the sender
        if not request or not hasattr(request, 'user'):
            return data
            
        sender = request.user
        receiver = data.get('receiver')

        # 1. Prevent sending a request to yourself
        if sender == receiver:
            raise serializers.ValidationError({"error": "You cannot send a friend request to yourself."})

        # 2. Check if you already sent them a request (catches the IntegrityError)
        if Friendship.objects.filter(sender=sender, receiver=receiver).exists():
            raise serializers.ValidationError({"error": "You have already sent a friend request to this user."})
        
        # 3. Check if they already sent you a request
        if Friendship.objects.filter(sender=receiver, receiver=sender).exists():
            raise serializers.ValidationError({"error": "This user has already sent you a friend request. Check your pending requests."})

        return data