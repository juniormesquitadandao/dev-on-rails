# Ubuntu 20.04 on Rails
Dockerfile and docker-compose to build ubuntu image to development with rails

- Install Docker: https://docs.docker.com/get-docker
- Install Docker Compose: https://docs.docker.com/compose/install

## Ex.: New project with name UoR
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
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    tty: true
volumes:
  rvm:
  nvm:
```
- Run to check config: docker-compose config
- Run to build image: docker-compose build
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal: docker-compose exec app bash
```bash
# Create new project with current folder name
rails new .
# Add jquery
yarn add jquery
# Create SQLite databases
rails db:create
# Start server and access: http://localhost:3000
rails s -b 0.0.0.0            
exit
```
- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm

## Ex.: New project with name UoR and Postgres 13.1
- If you did the previous example and want to keep the same name as the project, run to clean the docker:
```bash
docker-compose down
docker rm -f $(docker ps -qa)
docker volume rm -f $(docker volume ls -q)
docker rmi -f $(docker images -qa)
```
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
        AROUND_BUILD: >
          sudo apt install libpq-dev -y
    container_name: app
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    depends_on:
      - postgres
    volumes_from:
      - postgres
    tty: true
  postgres:
    image: postgres:13.1
    environment:
      POSTGRES_USER: uor
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres:/var/run/postgresql
volumes:
  rvm:
  nvm:
  postgres:
```
- Run to build image: docker-compose build
- Run to up in background: POSTGRES_PASSWORD=password docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal: docker-compose exec app bash
```bash
# Create new project with current folder name
rails new . --database=postgresql
# Add jquery
yarn add jquery
# Create Postgres databases
rails db:create
# Start server and access: http://localhost:3000
rails s -b 0.0.0.0            
exit
```
- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm
- Run to show volume postgres: docker volume inspect uor_postgres
