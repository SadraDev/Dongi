from django.core.management.base import BaseCommand
from users.models import User
from expenses.models import Group, Expense, ExpenseSplit

class Command(BaseCommand):
    def handle(self, *args, **options):
        # Assumes user 'admin' exists
        me = User.objects.get(username='God')
        
        # Create Group
        group = Group.objects.create(name='Weekend Trip to Berlin')
        group.members.add(me)
        
        # Create Expense
        expense = Expense.objects.create(
            group=group, payer=me, 
            description='Dinner at Mario\'s', total_amount=120.00
        )
        
        # Create Split
        ExpenseSplit.objects.create(expense=expense, user=me, amount_owed=40.00, is_paid=False)
        
        self.stdout.write(self.style.SUCCESS('Data seeded successfully!'))