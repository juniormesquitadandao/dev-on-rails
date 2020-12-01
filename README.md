# Ubuntu 20.04 on Rails
Dockerfile and docker-compose to build ubuntu image to development with rails

- Install Docker: https://docs.docker.com/get-docker
- Install Docker Compose: https://docs.docker.com/compose/install

## Ex.: New project with name UoR
- Create folder: UoR 
- Create file: UoR/docker-compose.yml 
- Add "gem: -N" to file: UoR/.gemrc
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
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal app: docker-compose exec app bash
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
- Add "gem: -N" to file: UoR/.gemrc
- Add "pg_sockets" to file: UoR/.gitignore
- Add "pg_backups" to file: UoR/.gitignore
```yml
version: '3.8'
services:
  app:
    build:
      context: .
      args:
        RUBY_VERSION: 2.7.2
        RAILS_VERSION: 6.0.3.4
        BUNDLER_VERSION: 2.1.4
        NODE_VERSION: 15.3.0
        NPM_VERSION: 6.14.9
        YARN_VERSION: 1.22.5
        AROUND_BUILD: >
          sudo apt install libpq-dev -y
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    depends_on:
      - postgresql
      - redis
    volumes_from:
      - postgresql
    tty: true
  postgresql:
    image: postgres:13.1
    working_dir: /var/backups/postgresql
    environment:
      POSTGRES_USER: uor
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD_TO_FIRST_UP}
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./pg_sockets:/var/run/postgresql
      - ./pg_backups:/var/backups/postgresql
  redis:
    image: redis:6.0.9
volumes:
  rvm:
  nvm:
  pg_data:
```
- Run to build and up: POSTGRES_PASSWORD_TO_FIRST_UP=password docker-compose up --build
- Type to exit: CTRL+C
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal app: docker-compose exec app bash
```bash
# Create new project with current folder name
rails new . --database=postgresql

# Add jquery
yarn add jquery

# Create Postgresql databases
# Rails auto connect in Postgresql with Unix Socket "/var/run/postgresql/.s.PGSQL.5432" and ubuntu current user "uor" without password
rails db:create

# Start rails console
rails c

# Ping redis
Redis.new(host: 'redis').ping
exit

# Start server and access: http://localhost:3000
rails s -b 0.0.0.0            

exit
```
- Run to access terminal postgresql: docker-compose exec postgresql bash
```bash
# Create ubuntu sudo user equal postgresql user to connect postgresql without password
adduser --disabled-password --gecos "" uor && usermod -aG sudo uor && passwd -d uor

# Add ubuntu user "uor" with permissions to backups folder. Or your host user will need sudo to exclude backups
chown uor:uor /var/backups/postgresql

# Create backup and see filder "UoR/pg_backups"
pg_dump -d uor_development -f uor_development.backup -F c -Z 9 -w -U uor

# Restore backup
pg_restore -d uor_development uor_development.backup -O --role=uor -U uor

exit
```
- Connect PGAdmin or other database client by unix socket without password: 
```yml
host: /home/user/path_projects/UoR/pg_sockets
port: 5432
role/user: uor
database: postgres
```
- Run to access terminal redis: docker-compose exec redis bash
```bash
# Ping redis
redis-cli PING

exit
```
- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm
- Run to show volume postgres: docker volume inspect uor_pg_data

## Ex.: Migrate existing project with name UoR and Postgres
- Create file: UoR/docker-compose.yml 
- Remove file: UoR/.ruby-version
- Remove file: UoR/.ruby-gemset
- Add "gem: -N" to file: UoR/.gemrc
- Add "pg_sockets" to file: UoR/.gitignore
- Add "pg_backups" to file: UoR/.gitignore
```yml
version: '3.8'
services:
  app:
    build:
      context: .
      args:
        RUBY_VERSION: [project version]
        RAILS_VERSION: [project version]
        BUNDLER_VERSION: [project version]
        NODE_VERSION: [project version]
        NPM_VERSION: [project version]
        YARN_VERSION: [project version]
        AROUND_BUILD: >
          sudo apt install libpq-dev -y
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    depends_on:
      - postgresql
      - redis
    volumes_from:
      - postgresql
    tty: true
  postgresql:
    image: postgres:[project version]
    working_dir: /var/backups/postgresql
    environment:
      POSTGRES_USER: uor
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD_TO_FIRST_UP}
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./pg_sockets:/var/run/postgresql
      - ./pg_backups:/var/backups/postgresql
  redis:
    image: redis:[project version]
volumes:
  rvm:
  nvm:
  pg_data:
```
- Run to build and up: POSTGRES_PASSWORD_TO_FIRST_UP=password docker-compose up --build
- Type to exit: CTRL+C
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to access terminal app: docker-compose exec app bash
```bash
# Install project gems
bundle install

# Install project packages
yarn

# Create Postgresql databases
# Rails auto connect in Postgresql with Unix Socket "/var/run/postgresql/.s.PGSQL.5432" and ubuntu current user "uor" without password
rails db:create db:migrate db:seed

# Start rails console
rails c

# Ping redis
Redis.new(host: 'redis').ping
exit

# Start server and access: http://localhost:3000
rails s -b 0.0.0.0            

exit
```
- Run to access terminal postgresql: docker-compose exec postgresql bash
```bash
# Create ubuntu sudo user equal postgresql user to connect postgresql without password
adduser --disabled-password --gecos "" uor && usermod -aG sudo uor && passwd -d uor

# Add ubuntu user "uor" with permissions to backups folder. Or your host user will need sudo to exclude backups
chown uor:uor /var/backups/postgresql

# Create backup and see filder "UoR/pg_backups"
pg_dump -d uor_development -f uor_development.backup -F c -Z 9 -w -U uor

# Restore backup
pg_restore -d uor_development uor_development.backup -O --role=uor -U uor

exit
```
- Connect PGAdmin or other database client by unix socket without password: 
```yml
host: /home/user/path_projects/UoR/pg_sockets
port: 5432
role/user: uor
database: postgres
```
- Run to access terminal redis: docker-compose exec redis bash
```bash
# Ping redis
redis-cli PING

exit
```
- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm
- Run to show volume postgres: docker volume inspect uor_pg_data
