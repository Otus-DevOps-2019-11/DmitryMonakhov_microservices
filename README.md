# DmitryMonakhov_microservices
DmitryMonakhov microservices repository
## homework#26 kubernetes-2
### Kubernetes. Запуск кластера и приложения. Модель безопасности
Установлен `minikube` и `kubectl`, с помощью `minikude` развернут локальный кластер

Созданы ресурсы `Deployment` для приложений `ui`, `comment`, `post` и базы данных `mongodb`

Созданы ресурсы `Service` для приложений `comment`, `post` и базы данных `mongodb`

Для обеспечения доступа использован тип `NodePort` сервиса `ui`

Выполнен запуск веб-интерфейса кластера `minikube dashboard`

Создан namespace `dev`, развернуты созданные ресурсы

Создан кластер в Google Kubernetes Engine из двух нод, добавлено правило фаервола для диапазона tсp портов 30000-32767

В кластере Google Kubernetes Engine создан namespace `dev`, выполнено развертывание созданных ресурсов
## homework#25 kubernetes-1
### Введение в Kubernetes
Выполнена установка основных компонентов Kubernetes кластера в соответствии с `Kubernetes The Hard Way`

Выпонена проверка запуска подов:
```
kubectl apply -f ui-deployment.yml
kubectl apply -f post-deployment.yml
kubectl apply -f mongo-deployment.yml
kubectl apply -f comment-deployment.yml
```
## homework#23 logging-1
### Логирование и распредераспределенная трассировка
Выполнено обновление кода приложения `reddit`

Собраны новые образы `ui`, `post`, `commit`. Образы запушены в Docker Hub

Собран образ `fluentd` для сбора лог сообщений и пересылки их в контейнер с Elasticsearch

Создан отдельный compose-файл `docker-compose-logging.yml`

Для логирования сервисов в `docker-compose.yml` определен драйвер `fluentd`

Для визуализации и анализа собираемых логов использована `Kibana`

Для парсинга логов созданы фильтры, grok-патерны и регулярные выражения

Для распределенного логирования добавлен сервис Zipkin
## homework#21 monitoring-2
### Мониторинг приложения и инфраструктуры
##### Подготовка окружения:
```sh
$ export GOOGLE_PROJECT=_ваш-проект_
$ docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-oscloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host
$ eval $(docker-machine env docker-host)
```
Запуск приложений reddit производится с помощью:  `docker-compose up -d`
Запуск приложений мониторинга производится с помощью: `docker-compose -f docker-compose-monitoring.yml up -d`
##### Мониторинг Docker контейнеров
cAdvisor:  используется для мониторинга состояния Docker контейнеров. Web UI `http://<docker-machinehost-ip>:8080`
Добавить сервис в `dockercompose-monitoring.yml`:
```
  cadvisor:
    image: google/cadvisor:v0.29.0
    container_name: cadvisor
    volumes:
      - '/:/rootfs:ro'
      - '/var/run:/var/run:rw'
      - '/sys:/sys:ro'
      - '/var/lib/docker/:/var/lib/docker:ro'
    ports:
      - '8080:8080'
    networks:
      - back_net
      - front_net
```
Добавить в `prometheus.yml`:
```
- job_name: 'cadvisor'
    static_configs:
      - targets:
        - 'cadvisor:8080'
```
##### Визуализация метрик
Grafana: используется для визуализации данных из Prometheus. Web UI `http://<dockermachine-host-ip>:3000`
Добавить сервис в `dockercompose-monitoring.yml`:
```
grafana:
  grafana:
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    networks:
      - back_net
      - front_net
volumes:
grafana_data:
```
##### Alertmanager
Функционал alerting в Grafana уступает по функционалу Alertmanager в Prometheus. Для использования Alertmanager добавить в `monitoring/alertmanager/Dockerfile`:
```
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
```
Добавить сервис в `dockercompose-monitoring.yml`:
```
  alertmanager:
    image: ${USER_NAME}/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - 9093:9093
    networks:
      - back_net
      - front_net
```
Правила, при которых срабатывает Alertmanager - Alert rules: добавить в `monitoring/alertmanager/Dockerfile`:
```
ADD alerts.yml /etc/prometheus/
```
Правила описываются в `monitoring/alertmanager/alerts.yml`:
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```
Для получения алертов из Alertmanager в Slack используется [Incoming Webhook](https://devops-team-otus.slack.com/apps/A0F7XDUAZ-incoming-webhooks?next_id=737777317219&direction=forwards)

Запушить образы на DockerHub:
```sh
$ docker push $USER_NAME/ui
$ docker push $USER_NAME/comment
$ docker push $USER_NAME/post
$ docker push $USER_NAME/prometheus
$ docker push $USER_NAME/alertmanager
```
[https://hub.docker.com/u/dmitrymonakhov](https://hub.docker.com/u/dmitrymonakhov)
## homework#20 monitoring-1
### Введение в мониторинг. Системы мониторинга
Создание правил firewall для Prometheus и Puma:
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```
Создание `docker-host` в GCE, с использованием `docker-machine`:
```
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host
```
Создание окружения для работы с `Docker`:
```
eval $(docker-machine env docker-host)
```
Запуск Prometheus:
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```
Получение информации о версии `Prometheus` с помощью веб-интерфейса `<external_ip_docker_machine>:9090` и выбора метрики `prometheus_build_info`

Сборка образа `Prometheus` с помощью Docker файла в директории `monitoring/prometheus`:
```
docker build -t $USER_NAME/prometheus .
```
Конфигурирование параметров мониторинга производится в файле `monitoring/prometheus/prometheus.yml`

Сборка образов сервисов выполняется из корня репозитория:
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```
Для мониторинга приложений, которые не поддерживают метрики, используются экспортеры. Мониторинг docker-host c помощью `node-exporter` осуществляется указанием в файле `docker/docker-compose.yml`:
```
services:
...
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  prometheus_data:
```
В веб-интерфейсе `Prometheus` отображается сервис `node`

Загрузка созданных образов в `Docker hub`:
```
docker push $USERNAME/ui
docker push $USERNAME/comment
docker push $USERNAME/post
docker push $USERNAME/prometheus
```
Образы загружены в docker-hub: https://hub.docker.com/u/dmitrymonakhov

## homework#19 gitlab-ci-1
### Устройство Gitlab CI. Построение процесса непрерывной поставки
Развертывание сервера `Gitlab CI` в инфраструктуре GCP произведено с использованием `docker-machine`
```sh
docker-machine create --driver google \
    --google-project docker-267016 \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-disk-size "100" \
    --google-zone us-east1-b \
    docker-host
```
и файла `docker-compose.yml` https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose

Определен `CI/CD Pipeline` для проекта в файле `.gitlab-ci.yml`
На сервере Gilab CI создан и зарегистирован `Runner`:
```sh
$ docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
$ docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
```
Созданы стадии (`stages`) тестирования приложения reddit

Определены `job` для окружений `dev`, `staging`, `production`. Использована директива `when: manual` для ручного запуска `job`. С помощью директивы `only: ` установлено ограничение для запуска `job` только в случае наличие тэга в коммите

При использовании переменных, доступных в `.gitlab-ci.yml`, возможно определение динамического окружения, например, для каждой создаваемой ветки

## homework#17 docker-4
### Сетевое взаимодействие Docker контейнеров. Docker Compose. Тестирование образов
Рассмотрены различные виды сетей Docker: `none`, `host`, `bridge`. Общий случай использования сети `none` - локальное тестирование без сетевого взаимодействия. Для обращения к контейнерам по именам используется опция ` --network-alias` при старте контейнера. Создание Docker-сети осуществляется с помощью `docker network create network_name --subnet=network_ip`. Один контейнер может быть подключен к нескольким сетям: `docker network connect <network> <container>`.

При работе с микросервисной инфраструктурой использование `docker build/run/create` становится неудобным, предпочтительным вариантом в этом случае является `docker-compose`. Приложения reddit собраны и запущены с помощью `docker-compose`: опции запуска контейнеров описываются в `docker-compose.yml`. Для параметризации `docker-compose.yml` используются переменные окружения, определяемые в файле `.env`. Базовое имя проекта определяется переменной `COMPOSE_PROJECT_NAME`.

При необходимости переопределения параметров контейнеров используется `docker-compose.override.yml`. Для возможности изменения кода приложений без пересборки образа подключены локальные `volumes` для каждого контейнера из каталога `$PWD/src`

## homework#16 docker-3
### Docker-образы. Микросервисы
С помощью `Dockerfile` выполнено описание сборки Docker-образов для микросервисного приложения

Приложение в формате микросервисов развернуто в инфраструктуре GCP на `docker-host`

Проверена работоспособность приложения при перезапуске контейнеров с сетевыми алиасами с помощью переменных окружения `--env`

Выполнена оптимизация размеров Docker-образов с использованием образа `ruby:2.7-alpine3.11` в 5-6 раз по отношению к исходным

Для обеспечения сохранности результатов работы приложения при перезапуске контейнера `mongo` создан и подключен `Docker volume` `docker volume create reddit_db`

## homework#15 docker-2
### Технология контейнеризации.Введение в Docker
Подготовка репозитория microservices:
- Создание нового проекта GCP `docker-{ID}`
- Настройка интеграции с TravisCI, настройка уведомлений в Slack: `/github subscribe Otus-DevOps-2019-11/DmitryMonakhov_microservices commits:all`
- Настройка gcloud для работы с GCP:
```sh
$ gcloud init
$ glocud auth  application-default login
```

Изучение базовых команд для работы с контейнерами:
```sh
$  docker info
$  docker ps
$  docker ps -a
$  docker images
$  docker exec -it <u_container_id> bash
$  docker commit <u_container_id> yourname/ubuntu-tmp-file
$  docker tag local-image:tagname new-repo:tagname &&  docker push new-repo:tagname
$  docker system df
$  docker rm [-f] <u_container_id>
$  docker rm $(docker ps -a q)
$  docker rmi <image_id>
```

Подготовка `docker-host` в инфраструктуре GCP с помощью `docker-machine`:
```sh
$ export GOOGLE_PROJECT=docker-{ID}
$ docker-machine create --driver google --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west1-b docker-host
```
Переключиться на работу с `docker engine` в GCP: `eval $(docker-machine env docker-host)`

Создание образа, содержащего приложение reddit с помощью `Dockerfile`

Публикация образа {DockerHubAccount}/otus-reddit:1.0 в `Docker Hub`: `$ docker push {DockerHubAccount}/otus-reddit:1.0`

Подготовка прототипа инфраструктуры `infra` с помощью:
- Packer: подготовка образа с установленным `docker`
- Terrafom: создание инстансов `docker-host` в инфраструктуре GCP на базе образа, подготовленного Packer. Использование переменной `count` для создания произвольного количества инстансов
- Ansible: запуск контейнера {DockerHubAccount}/otus-reddit:1.0 на `docker-host` c использованием динамической инвентаризаций с помощью плагина `gcp_compute`. Не допускается использование символов {-} в имени группы хостов, для которой будут применяться плейбуки
