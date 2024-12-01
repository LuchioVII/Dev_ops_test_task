#!/bin/bash
python manage.py makemigrations simple_app
python manage.py migrate
python manage.py createsuperuser --noinput --username root --email root@example.com
python -c "import django; django.setup(); from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username='root'); user.set_password('root'); user.save()"
