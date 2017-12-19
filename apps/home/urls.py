from django.urls import path

from apps.home.views import IndexView

urlpatterns = [
    path('', IndexView.as_view(), name='index'),
]
