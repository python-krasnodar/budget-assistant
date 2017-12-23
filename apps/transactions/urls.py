from django.urls.conf import path

from apps.transactions.views import ListView

urlpatterns = [
    path('', ListView.as_view(), name='index'),
]
