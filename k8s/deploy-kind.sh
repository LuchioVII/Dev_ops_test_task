#!/bin/bash

echo "Создание кластера kind..."
kind create cluster --config kind-cluster.yaml --name=newcluster

echo "Ожидание готовности кластера..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "Применение манифестов..."

kubectl apply -f ./django/django-configmap.yaml
kubectl apply -f ./django/django-secret.yaml

kubectl wait --for=condition=available deployment/django --timeout=120s

kubectl apply -f ./postgres/postgres-pv.yaml
kubectl apply -f ./postgres/postgres-deployment.yaml
kubectl apply -f ./postgres/postgres-service.yaml

kubectl wait --for=condition=available deployment/postgres --timeout=120s

kubectl apply -f ./rabbitmq/rabbitmq-deployment.yaml
kubectl apply -f ./rabbitmq/rabbitmq-service.yaml

kubectl wait --for=condition=available deployment/rabbitmq --timeout=120s

kubectl apply -f ./django/django-deployment.yaml
kubectl apply -f ./django/django-service.yaml

kubectl wait --for=condition=available deployment/django --timeout=120s

kubectl apply -f ./celery/celery-deployment.yaml
kubectl apply -f ./celery/celery-service.yaml

kubectl wait --for=condition=available deployment/celery --timeout=120s

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl label nodes newcluster-control-plane ingress-ready=true
kubectl apply -f ./django/django-ingress.yaml

echo "Все манифесты применены!"
