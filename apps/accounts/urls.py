from django.urls.conf import path, include

from apps.accounts.views import AccountListView, AccountCreateView, AccountDeleteView, AccountDetailView

urlpatterns = [
    path('', AccountListView.as_view(), name='index'),
    path('create/', AccountCreateView.as_view(success_url='/accounts/'), name='create'),
    path('view/<int:pk>/', AccountDetailView.as_view(), name='view'),
    path('delete/<int:pk>/', AccountDeleteView.as_view(success_url='/accounts/'), name='delete'),
    path('ajax/', include(('apps.accounts.ajax_urls', 'ajax'))),
]
