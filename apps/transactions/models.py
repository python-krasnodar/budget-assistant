from django.contrib.auth.models import User
from django.db import models

from apps.accounts.models import Account
from apps.db.fields import TransactionTypeField


class Category(models.Model):
    type = TransactionTypeField(null=False, blank=False)
    title = models.CharField(max_length=255, null=False, blank=False)
    description = models.TextField(default=None, null=True, blank=True)
    user = models.ForeignKey(User, null=False, blank=False, db_column='user_id', on_delete=models.CASCADE)
    created_at = models.DateTimeField(null=False, blank=True, editable=False)
    updated_at = models.DateTimeField(default=None, null=True, blank=True, editable=False)

    def __str__(self):
        return self.title


class Transaction(models.Model):
    type = TransactionTypeField(null=False, blank=False)
    amount = models.DecimalField(max_digits=15, decimal_places=2, null=False, blank=False)
    category = models.ForeignKey(Category, null=False, blank=False, db_column='category_id', on_delete=models.PROTECT)
    account = models.ForeignKey(Account, null=False, blank=False, db_column='account_id', on_delete=models.CASCADE)
    created_at = models.DateTimeField(null=False, blank=True, editable=False)
    updated_at = models.DateTimeField(default=None, null=True, blank=True, editable=False)

    def __str__(self):
        return '%s (%f)' % (self.category.title, self.amount)
