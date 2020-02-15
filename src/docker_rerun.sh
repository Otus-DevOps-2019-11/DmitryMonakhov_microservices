docker build -t docker-267016/comment:3.0 -f ./comment/Dockerfile ./comment
docker build -t docker-267016/post:1.0 -f ./post-py/Dockerfile ./post-py
docker build -t docker-267016/ui:3.0 -f ./ui/Dockerfile ./ui

docker rm -f $(docker ps -a -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post docker-267016/post:1.0
docker run -d --network=reddit --network-alias=comment docker-267016/comment:3.0
docker run -d --network=reddit -p 9292:9292 docker-267016/ui:3.0
