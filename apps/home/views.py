from django.utils.decorators import method_decorator
from django.contrib.auth.decorators import login_required
from django.views.generic import TemplateView
from django.contrib.auth.views import LoginView as BaseLoginView

from apps.home.decorators import anonymous_required


@method_decorator(login_required, name='dispatch')
class IndexView(TemplateView):
    template_name = 'home/index.html'


@method_decorator(anonymous_required, name='dispatch')
class LoginView(BaseLoginView):
    template_name = 'home/login.html'
