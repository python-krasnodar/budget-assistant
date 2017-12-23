from django.views.generic import ListView as BaseListView

from apps.transactions.models import Transaction


class ListView(BaseListView):
    template_name = 'transactions/index.html'
    queryset = Transaction.objects

    def get_queryset(self):
        queryset = super(ListView, self).get_queryset()
        queryset.filter(account__user__exact=self.request.user)

        return queryset.all()
