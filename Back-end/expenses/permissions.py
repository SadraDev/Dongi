# expenses/permissions.py
from rest_framework import permissions

class IsGroupCreator(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to delete it.
    """
    def has_object_permission(self, request, view, obj):
        # Allow safe methods (GET, HEAD, OPTIONS) for everyone in the group
        if request.method in permissions.SAFE_METHODS:
            return True
            
        # Check if the user is the creator
        return obj.created_by == request.user