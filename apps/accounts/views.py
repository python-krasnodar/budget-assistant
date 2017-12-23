import json

from django.http import HttpResponse
from django.views import View
from django.views.generic import ListView, CreateView, DeleteView

from apps.accounts.models import Account, Currency


class AccountListView(ListView):
    template_name = 'accounts/index.html'
    queryset = Account.objects

    def get_queryset(self):
        queryset = super(AccountListView, self).get_queryset()
        queryset.filter(user__exact=self.request.user)

        return queryset.all()


class AccountCreateView(CreateView):
    template_name = 'accounts/create.html'
    model = Account
    fields = ('title', 'description', 'currency')

    def form_valid(self, form):
        form.instance.user = self.request.user
        return super(AccountCreateView, self).form_valid(form)


class AccountDeleteView(DeleteView):
    queryset = Account.objects

    def get_queryset(self):
        queryset = super(AccountDeleteView, self).get_queryset()
        queryset.filter(user__exact=self.request.user)

        return queryset.all()

    def get(self, request, *args, **kwargs):
        return self.delete(request, *args, **kwargs)


class CurrencyAjaxListView(View):
    def get(self, request):
        queryset = Currency.objects.order_by('title')

        term = request.GET.get('term', None)
        if term is not None:
            queryset = queryset.filter(title__istartswith=term)

        currencies = queryset.all()
        data = {'results': [], 'pagination': {'more': False}}

        for currency in currencies:
            data['results'].append({
                'id': currency.pk,
                'text': currency.title,
            })

        return HttpResponse(
            json.dumps(data),
            content_type='application/json'
        )
