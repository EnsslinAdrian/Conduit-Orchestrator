#!/bin/bash
echo "Starting my application..."

mkdir -p /app/db /app/media

python manage.py migrate
python manage.py collectstatic --noinput

python manage.py shell << EOF
from django.contrib.auth import get_user_model

User = get_user_model()

user, created = User.objects.get_or_create(
    username="${SUPERUSER_USERNAME}",
    defaults={
        "email": "${SUPERUSER_EMAIL}",
        "is_staff": True,
        "is_superuser": True,
    }
)

user.is_staff = True
user.is_superuser = True
user.set_password("${SUPERUSER_PASSWORD}")
user.save()
EOF

exec gunicorn conduit.wsgi:application --bind 0.0.0.0:8000
 