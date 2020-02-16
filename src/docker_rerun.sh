docker build -t dmitrymonakhov/comment:3.0 -f ./comment/Dockerfile ./comment
docker build -t dmitrymonakhov/post:1.0 -f ./post-py/Dockerfile ./post-py
docker build -t dmitrymonakhov/ui:3.0 -f ./ui/Dockerfile ./ui

docker rm -f $(docker ps -a -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post dmitrymonakhov/post:1.0
docker run -d --network=reddit --network-alias=comment dmitrymonakhov/comment:3.0
docker run -d --network=reddit -p 9292:9292 dmitrymonakhov/ui:3.0

docker run -d --network=reddit --network-alias=post_db_new --network-alias=comment_db_new mongo:latest
docker run -d --network=reddit --network-alias=post_new --env POST_DATABASE_HOST=post_db_new dmitrymonakhov/post:1.0
docker run -d --network=reddit --network-alias=comment_new --env COMMENT_DATABASE_HOST=comment_new_db  dmitrymonakhov/comment:3.0
docker run -d --network=reddit -p 9292:9292 --env POST_SERVICE_HOST=post_new --env COMMENT_SERVICE_HOST=comment_new dmitrymonakhov/ui:3.0
