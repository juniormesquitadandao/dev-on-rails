# Ubuntu on Rails
Dockerfile and docker-compose to build ubuntu image to development with rails

- Install Docker: https://docs.docker.com/get-docker
- Install Docker Compose: https://docs.docker.com/compose/install

## Ex.: New project name "UoR"
- Create folder: UoR 
- Create file: UoR/docker-compose.yml 
```yml
version: '3.8'
services:
  app:
    build:
      context: .
      args:
        RUBY_VERSION: 2.7.2
        RAILS_VERSION: 6.0.3.4
        NODE_VERSION: 15.3.0
        YARN_VERSION: 1.22.5
    container_name: app
    working_dir: /home/UoR
    volumes:
      - .:/home/UoR
      - rvm:/usr/local/rvm
      - nvm:/root/.nvm
    ports:
      - 3000
    tty: true

volumes:
  rvm:
  nvm:
```
- Run to build image: docker-compose build
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal: docker-compose exec app bash
```shell
rails new .
rails s
exit
```
- Run: docker-compose down
