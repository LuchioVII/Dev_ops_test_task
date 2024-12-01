FROM python:3.11-slim
LABEL authors="luchio"

ENV  PYTHONDONTWRITEBYTECODE 1
ENV  PYTHONUNBUFFERED 1
ENV  PIP_ROOT_USER_ACTION=ignore
ENV DJANGO_SETTINGS_MODULE=simple_app.settings

WORKDIR /django_simple_app

COPY ./django_simple_app /django_simple_app/

RUN pip install --no-cache-dir -r requirements.txt





