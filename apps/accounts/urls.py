from django.urls.conf import path, include

from apps.accounts.views import AccountListView, AccountCreateView, AccountDeleteView

urlpatterns = [
    path('', AccountListView.as_view(), name='index'),
    path('create/', AccountCreateView.as_view(success_url='/accounts/'), name='create'),
    path('delete/<int:pk>/', AccountDeleteView.as_view(success_url='/accounts/'), name='delete'),
    path('ajax/', include(('apps.accounts.ajax_urls', 'ajax'))),
]
