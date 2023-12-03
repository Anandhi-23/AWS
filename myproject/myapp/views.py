from django.shortcuts import render
from .models import Content

# Create your views here.
def home(request):
    content = Content.objects.all()
    return render(request, 'myapp/home.html', {'content': content})
