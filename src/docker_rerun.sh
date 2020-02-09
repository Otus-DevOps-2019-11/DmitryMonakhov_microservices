docker rmi -f $(docker images -a -q)
docker build -t docker-267016/comment:2.0 -f ./comment/Dockerfile.2 ./comment
docker build -t docker-267016/post:2.0 -f ./post-py/Dockerfile.2 ./post-py
docker build -t docker-267016/ui:2.0 -f ./ui/Dockerfile.2 ./ui

docker rm -f $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post docker-267016/post:2.0
docker run -d --network=reddit --network-alias=comment docker-267016/comment:2.0
docker run -d --network=reddit -p 9292:9292 docker-267016/ui:2.0
