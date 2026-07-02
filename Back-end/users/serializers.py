from rest_framework import serializers
from django.contrib.auth import get_user_model, authenticate
from django.core.exceptions import ObjectDoesNotExist
from .models import Friendship

User = get_user_model()

class CaseInsensitiveSlugRelatedField(serializers.SlugRelatedField):
    """Custom field that performs case-insensitive lookups"""
    def to_internal_value(self, data):
        try:
            return self.get_queryset().get(**{self.slug_field + '__iexact': data})
        except ObjectDoesNotExist:
            self.fail('does_not_exist', slug_name=self.slug_field, value=repr(data))
        except (TypeError, ValueError):
            self.fail('invalid')

class UserSearchSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username')

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username')

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'password')

    def validate_username(self, value):
        # Check for reserved usernames (case-insensitive)
        user = User(username=value)
        if user.is_username_reserved():
            raise serializers.ValidationError("There can only be one God.")
        
        # Check for case-insensitive uniqueness
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
        # For login, we need to find the user with case-insensitive username
        username = data.get('username')
        password = data.get('password')
        
        # Try to find the user with case-insensitive username
        try:
            user = User.objects.get(username__iexact=username)
            # Now authenticate with the actual username from the database
            user = authenticate(username=user.username, password=password)
            if user and user.is_active:
                return user
        except User.DoesNotExist:
            pass
            
        raise serializers.ValidationError("Incorrect username or password.")


class FriendRequestSerializer(serializers.ModelSerializer):
    sender = serializers.SlugRelatedField(read_only=True, slug_field='username')
    receiver = CaseInsensitiveSlugRelatedField(queryset=User.objects.all(), slug_field='username')

    class Meta:
        model = Friendship
        fields = ('id', 'sender', 'receiver', 'status')