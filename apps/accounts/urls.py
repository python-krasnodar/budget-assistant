from django.urls.conf import path

from apps.accounts.views import ListView, CreateView

urlpatterns = [
    path('', ListView.as_view(), name='index'),
    path('create/', CreateView.as_view(), name='create'),
]
