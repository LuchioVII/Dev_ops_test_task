---

# DevOps Test Task: Django + PostgreSQL + RabbitMQ + Kubernetes

## Описание

Это репозиторий для тестового задания DevOps-инженера. Задание включает контейнеризацию Django-приложения с подключением к базе данных PostgreSQL и использованию RabbitMQ в качестве брокера сообщений с Celery. Развёртывание выполнено в Kubernetes с использованием манифестов для всех компонентов.

## Структура репозитория

- **`django_simple_app/`**: Django-приложение.
  - `requirements.txt`: Зависимости проекта.
  - Приложение с файлами настроек, моделей, задач и административного интерфейса.
  - `migrations_and_superuser.sh`: Скрипт для миграций и создания суперпользователя.
  
- **`k8s/`**: Манифесты Kubernetes для развёртывания приложения.
  - **`celery/`**: Манифесты для Celery.
    - `celery-deployment.yaml`: Манифест для развёртывания Celery.
    - `celery-service.yaml`: Манифест для сервиса Celery.
  - **`django/`**: Манифесты для Django-приложения.
    - `django-configmap.yaml`: ConfigMap для конфигурации Django-приложения.
    - `django-deployment.yaml`: Манифест для развёртывания Django-приложения.
    - `django-ingress.yaml`: Манифест для Ingress.
    - `django-secret.yaml`: Секреты для Django-приложения.
    - `django-service.yaml`: Манифест для сервиса Django.
  - **`postgres/`**: Манифесты для PostgreSQL.
    - `postgres-deployment.yaml`: Манифест для развёртывания PostgreSQL.
    - `postgres-pv.yaml`: Манифест для PersistentVolume PostgreSQL.
    - `postgres-service.yaml`: Манифест для сервиса PostgreSQL.
  - **`rabbitmq/`**: Манифесты для RabbitMQ.
    - `rabbitmq-deployment.yaml`: Манифест для развёртывания RabbitMQ.
    - `rabbitmq-service.yaml`: Манифест для сервиса RabbitMQ.
  - **`deploy-kind.sh`**: Скрипт для автоматического развертывания на локальном кластере kind.
  - **`kind-cluster.yaml`**: Конфигурация для создания кластера в kind.

- **`.env_example`**: Пример файла `.env` для настройки переменных окружения.
- **`.dockerignore`**: Файл для игнорирования ненужных файлов при сборке Docker-образа.
- **`docker-compose.yaml`**: Конфигурация для локальной сборки и запуска контейнеров.
- **`README.md`**: Этот файл.

## Часть 1: Docker-образ для Django-приложения

Docker-образ для Django-приложения настроен для использования RabbitMQ через Celery и подключения к базе данных PostgreSQL. Все настройки переменных окружения вынесены в файл `.env`.

### Сборка Docker-образа

Для сборки Docker-образа выполните команду:

```bash
docker-compose up --build
```

## Часть 2: Развёртывание в Kubernetes

### 1. Манифесты Kubernetes

- **Django**:
  - `django-deployment.yaml`, `django-service.yaml` — для развертывания Django-приложения.
  - `django-configmap.yaml`, `django-secret.yaml` — для конфигурации и секретов приложения.
  - `django-ingress.yaml` — для настройки доступа через Ingress.

- **PostgreSQL**:
  - `postgres-deployment.yaml`, `postgres-service.yaml` — для развертывания PostgreSQL.
  - `postgres-pv.yaml` — для настройки PersistentVolume.

- **RabbitMQ**:
  - `rabbitmq-deployment.yaml`, `rabbitmq-service.yaml` — для развертывания RabbitMQ.

- **Celery**:
  - `celery-deployment.yaml`, `celery-service.yaml` — для развертывания Celery.

### 2. Развёртывание в Kubernetes

- Для развёртывания на локальном кластере **kind**:
  1. Установите [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).
  2. Перейдите в папку с манифестами Kubernetes (`k8s/`).
  3. Сделайте скрипт `deploy-kind.sh` исполнимым:

     ```bash
     chmod +x deploy-kind.sh
     ```

  4. Запустите скрипт для автоматического развёртывания:

     ```bash
     ./deploy-kind.sh
     ```

### 3. Проверка подключения

- **Проверка подключения к RabbitMQ**:

  Для проверки подключения выполните портфорвардинг:

  ```bash
  kubectl port-forward svc/rabbitmq-service 15672:15672
  ```

  Затем откройте [http://localhost:15672](http://localhost:15672) для доступа к веб-интерфейсу RabbitMQ.

- **Проверка подключения к PostgreSQL**:

  Для проверки подключения к базе данных PostgreSQL из контейнера Django выполните:

  ```bash
  kubectl exec -it <django-pod-name> -- psql -h postgres -U django_user -d django_db
  ```

## Примечания

- Все переменные окружения для Django, PostgreSQL и RabbitMQ могут быть настроены через **ConfigMap** и **Secret** в Kubernetes.
- Настроены Docker-образы для локального тестирования и развёртывания в Kubernetes.
- Рабочие манифесты для развертывания всех компонентов в Kubernetes (Django, PostgreSQL, RabbitMQ, Celery).

---
