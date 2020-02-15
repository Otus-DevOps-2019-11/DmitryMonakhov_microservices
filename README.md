# DmitryMonakhov_microservices
DmitryMonakhov microservices repository
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
