# DmitryMonakhov_microservices
DmitryMonakhov microservices repository
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
