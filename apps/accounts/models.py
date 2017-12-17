from django.contrib.auth.models import User
from django.db import models


class Currency(models.Model):
    title = models.CharField(max_length=255, null=False, blank=False)
    iso4217 = models.CharField(max_length=3, null=False, blank=False, unique=True)
    created_at = models.DateTimeField(null=False, blank=True, editable=False)
    updated_at = models.DateTimeField(default=None, null=True, blank=True, editable=False)

    def __str__(self):
        return '%s (%s)' % (self.title, self.iso4217)


class Account(models.Model):
    title = models.CharField(max_length=255, null=False, blank=False)
    description = models.TextField(default=None, null=True, blank=True)
    amount = models.DecimalField(max_digits=15, decimal_places=2, null=False, blank=True, default=0.0, editable=False)
    user = models.ForeignKey(User, related_name='accounts', db_column='user_id', null=False, blank=False, on_delete=models.CASCADE)
    currency = models.ForeignKey(Currency, db_column='currency_id', null=False, blank=False, on_delete=models.PROTECT)
    created_at = models.DateTimeField(null=False, blank=True, editable=False)
    updated_at = models.DateTimeField(default=None, null=True, blank=True, editable=False)

    def __str__(self):
        return '%s (%s)' % (self.title, self.amount)
