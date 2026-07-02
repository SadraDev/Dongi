from rest_framework import serializers
from django.db.models import Sum
from django.contrib.auth import get_user_model
from django.core.exceptions import ObjectDoesNotExist
from .models import Group, GroupMember
from django.db import models

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

class GroupSerializer(serializers.ModelSerializer):
    balance = serializers.SerializerMethodField()
    members = CaseInsensitiveSlugRelatedField(
        many=True, queryset=User.objects.all(), slug_field='username', required=False
    )

    class Meta:
        model = Group
        fields = ('id', 'name', 'balance', 'members', 'created_by')
        read_only_fields = ('created_by',)

    def create(self, validated_data):
        user = self.context['request'].user
        invited_users = validated_data.pop('members', [])
        
        group = Group.objects.create(created_by=user, **validated_data)
        
        # Creator is accepted by default
        GroupMember.objects.create(group=group, user=user, status='accepted')
        
        # Invitees are pending
        for invited_user in invited_users:
            if invited_user != user:
                GroupMember.objects.create(group=group, user=invited_user, status='pending')
        
        return group
        
    def get_balance(self, obj):
        user = self.context['request'].user
        
        # 1. Money the user OWEs (Unpaid debts)
        total_owe_dec = obj.expenses.filter(
            splits__user=user, 
            splits__is_paid=False
        ).aggregate(total=Sum('splits__amount_owed'))['total'] or 0.0
        
        # 2. Money the user is OWED
        # Only sum the splits of others where is_paid=False
        # We look for all expenses paid by the user, then look at the splits of OTHER people
        total_lent = obj.expenses.filter(
            payer=user
        ).aggregate(
            total=Sum('splits__amount_owed', filter=~models.Q(splits__user=user) & models.Q(splits__is_paid=False))
        )['total'] or 0.0
        
        return float(total_lent) - float(total_owe_dec)