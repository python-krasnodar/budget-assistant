from django.views.generic import ListView as BaseListView, CreateView as BaseCreateView

from apps.accounts.models import Account


class ListView(BaseListView):
    template_name = 'accounts/index.html'
    queryset = Account.objects

    def get_queryset(self):
        queryset = super(ListView, self).get_queryset()
        queryset.filter(user__exact=self.request.user)

        return queryset.all()


class CreateView(BaseCreateView):
    template_name = 'accounts/create.html'
    model = Account
    fields = ('title', 'description', 'currency')
