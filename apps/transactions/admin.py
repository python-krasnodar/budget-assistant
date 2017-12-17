from django.contrib import admin

from apps.transactions.models import Category, Transaction


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    pass


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    pass
