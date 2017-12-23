from django.urls import reverse
from django.urls.conf import path, include

from apps.accounts.views import AccountListView, AccountCreateView

urlpatterns = [
    path('', AccountListView.as_view(), name='index'),
    path('create/', AccountCreateView.as_view(success_url='/accounts/'), name='create'),
    path('ajax/', include(('apps.accounts.ajax_urls', 'ajax'))),
]
