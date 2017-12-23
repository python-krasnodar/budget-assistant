from django.urls.conf import path

from apps.accounts.views import CurrencyAjaxListView

urlpatterns = [
    path('currency/', CurrencyAjaxListView.as_view(), name='currency'),
]
