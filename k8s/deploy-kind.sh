#!/bin/bash

echo "Создание кластера kind..."
kind create cluster --config ./cluster/kind-cluster.yaml --name=newcluster

echo "Ожидание готовности кластера..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "Применение манифестов..."

echo "Применение ConfigMap и Secret для кластера..."
kubectl apply -f ./cluster/app-configmap.yaml
kubectl apply -f ./cluster/app-secret.yaml

echo "Развёртывание PostgreSQL..."
kubectl apply -f ./postgres/postgres-pv.yaml
kubectl apply -f ./postgres/postgres-deployment.yaml
kubectl apply -f ./postgres/postgres-service.yaml

echo "Ожидание готовности PostgreSQL..."
kubectl wait --for=condition=available deployment/postgres --timeout=120s

echo "Развёртывание RabbitMQ..."
kubectl apply -f ./rabbitmq/rabbitmq-deployment.yaml
kubectl apply -f ./rabbitmq/rabbitmq-service.yaml

echo "Ожидание готовности RabbitMQ..."
kubectl wait --for=condition=available deployment/rabbitmq --timeout=120s

echo "Применение манифеста для Django..."
kubectl apply -f ./django/django-deployment.yaml
kubectl apply -f ./django/django-service.yaml
kubectl wait --for=condition=available deployment/django --timeout=120s

echo "Применение манифестов для Celery..."
kubectl apply -f ./celery/celery-deployment.yaml
kubectl apply -f ./celery/celery-service.yaml
kubectl wait --for=condition=available deployment/celery --timeout=120s

echo "Установка Ingress-контроллера..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Добавление метки ingress-ready на ноду..."
kubectl label nodes newcluster-control-plane ingress-ready=true

echo "Ожидание готовности Ingress-контроллера..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=600s

echo "Применение манифеста Ingress..."
kubectl apply -f ./django/django-ingress.yaml

echo "Все манифесты успешно применены!"