from django.contrib.auth.models import AbstractUser
from django.db import models
from .task import my_task, another_task


class User(AbstractUser):
    phone = models.CharField(max_length=100, blank=True, null=True)
    telegram = models.CharField(max_length=100, blank=True, null=True)

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        my_task.delay()
        another_task.delay()
