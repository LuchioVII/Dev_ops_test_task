# DevOps Test Task: Django + PostgreSQL + RabbitMQ + Kubernetes

## Описание

Это репозиторий для тестового задания DevOps-инженера. Задание включает контейнеризацию Django-приложения с подключением к базе данных PostgreSQL и использованием RabbitMQ в качестве брокера сообщений с Celery. Развёртывание выполнено в Kubernetes с использованием манифестов для всех компонентов.

## Структура репозитория

- **`django_simple_app/`**: Django-приложение.
  - `requirements.txt`: Зависимости проекта.
  - `manage.py`: Основной скрипт для управления проектом.
  - **`simple_app/`**: Основное Django-приложение.
    - `__init__.py`: Инициализация Django-приложения.
    - `settings.py`: Конфигурация Django.
    - `urls.py`: URL-маршруты.
    - `wsgi.py`: Точка входа для WSGI сервера.
    - `asgi.py`: Точка входа для ASGI сервера.
    - `celery.py`: Конфигурация для Celery.
    - **`models.py`**: Модели приложения.
    - **`admin.py`**: Админка Django.
    - **`task.py`**: Задачи Celery для выполнения асинхронных задач.
    - **`migrations_and_superuser.sh`**: Скрипт для миграций и создания суперпользователя.

- **`k8s/`**: Манифесты Kubernetes для развёртывания приложения.
  - **`cluster/`**: Конфигурации для кластера Kubernetes.
    - `kind-cluster.yaml`: Конфигурация для создания кластера в kind.
    - `app-secret.yaml`: Конфигурация секретов.
    - `app-configmap.yaml`: Конфигурация переменных окружения и настроек.
  - **`rabbitmq/`**: Манифесты для RabbitMQ.
    - `rabbitmq-deployment.yaml`: Манифест для развёртывания RabbitMQ.
    - `rabbitmq-service.yaml`: Манифест для сервиса RabbitMQ.
  - **`postgres/`**: Манифесты для PostgreSQL.
    - `postgres-deployment.yaml`: Манифест для развёртывания PostgreSQL.
    - `postgres-pv.yaml`: Манифест для PersistentVolume PostgreSQL.
    - `postgres-service.yaml`: Манифест для сервиса PostgreSQL.
  - **`celery/`**: Манифесты для Celery.
    - `celery-deployment.yaml`: Манифест для развёртывания Celery.
    - `celery-service.yaml`: Манифест для сервиса Celery.
  - **`django/`**: Манифесты для Django-приложения.
    - `django-deployment.yaml`: Манифест для развёртывания Django-приложения.
    - `django-service.yaml`: Манифест для сервиса Django.
    - `django-ingress.yaml`: Манифест для Ingress.
  - **`deploy-kind.sh`**: Скрипт для автоматического развертывания на локальном кластере kind.

- **`.env_example`**: Пример файла `.env` для настройки переменных окружения.
- **`docker-compose.yaml`**: Конфигурация для локальной сборки и запуска контейнеров.
- **`Dockerfile`**: Dockerfile для создания образа Django-приложения.

## Часть 1: Docker-образ для Django-приложения

Docker-образ для Django-приложения настроен для использования **RabbitMQ** через **Celery** и подключения к базе данных PostgreSQL. Все настройки переменных окружения вынесены в файл `.env`. **Celery** используется для выполнения фоновых задач, таких как обработка запросов и отправка уведомлений, не блокируя основной поток выполнения Django-приложения. В свою очередь, **RabbitMQ** выполняет роль брокера сообщений для Celery, управляя очередями задач.

### Что делают RabbitMQ и Celery в приложении?

- **RabbitMQ**: используется как брокер сообщений для Celery. Когда происходит вызов задачи в Django (например, при сохранении объекта `User`), задача отправляется в очередь RabbitMQ, откуда Celery забирает её для асинхронного выполнения.
  
- **Celery**: обрабатывает задачи асинхронно, такие как `my_task.delay()` и `another_task.delay()`, которые выполняются при сохранении пользователя. Это позволяет не блокировать основной поток приложения, улучшая производительность.

### Реализация в админке

В административной панели Django зарегистрирована кастомная модель `User`, которая расширяет стандартную модель `AbstractUser` и добавляет дополнительные поля, такие как `phone` и `telegram`. Это позволяет администраторам управлять пользователями через админку. При сохранении пользователя автоматически вызываются фоновые задачи, такие как `my_task` и `another_task`, которые обрабатываются через Celery.

### Сборка Docker-образа

Для сборки Docker-образа выполните команду:

```bash
docker-compose up --build
```

## Часть 2: Развёртывание в Kubernetes

Для развёртывания на локальном кластере **kind**:
  1. Установите [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).
  2. Перейдите в папку с манифестами Kubernetes (`k8s/`).
  3. Сделайте скрипт `deploy-kind.sh` исполняемым:

     ```bash
     chmod +x deploy-kind.sh
     ```

  4. Запустите скрипт для автоматического развёртывания:

     ```bash
     ./deploy-kind.sh
     ```
  Django приложение будет доступно на порту 8080 локальной машины (http://localhost:8080).
### 3. Проверка подключения

- **Проверка подключения к RabbitMQ**:

  Для проверки подключения выполните портфорвардинг:

  ```bash
  kubectl port-forward svc/rabbitmq 15672:15672
  ```

  Затем откройте [http://localhost:15672](http://localhost:15672) для доступа к веб-интерфейсу RabbitMQ.(Кредлы дефолт root/root)

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
