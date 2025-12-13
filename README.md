# Conduit – Containerized Fullstack Application
This project represents a containerized full-stack web application based on the RealWorld Conduit example. <br>
An Angular frontend communicates via REST API with a Django backend, <br>
both services are operated in isolation and reproducibly using Docker and Docker Compose. <br>

## Table of contents
1. [Prerequisites](#prerequisites)
2. [Quickstart](#quickstart)
3. [Project Structure](#project-structure)
4. [Usage](#usage)
5. [Docker commands](#docker-command)
6. [Author](#author)

## Prerequisites
Before running this project, ensure you have:

- **Docker** installed  
- **Docker Compose** installed 


## Quickstart
Clone the repository from GitHub
```bash
git clone git@github.com:EnsslinAdrian/Conduit-Orchestrator.git conduit-orchestrator
```

Navigate to the folder
```bash
cd conduit-orchestrator
```

Create a `.env` file using this command and fill in the variables:

```bash
cp .env.template .env
```

Build the server directly:
```bash
docker compose build
```

Run the server directly:
```bash
docker compose up -d
```

Access this URL:
```
<YOUR_IP>:8000
```


## Project Structure
```
|-- 📁 conduit-backend
|--|-- 📁 conduit
|  |-- 📄 .dockerignore
|  |-- 📄 .gitignore
|  |-- 📄 Dockerfile
|  |-- 📄 entrypoint.sh
|  |-- 📄 manage.py
|  |-- 🖼️ project-logo.png
|  |-- ℹ️ README.md
|  |-- 📄 requirements.txt
|
|-- 📁 conduit-frontend
|--|-- 📁 nginx
|  |--|-- ⚙️ default.conf
|  |-- 📁 src
|  |-- 📄 .dockerignore
|  |-- 📄 .editorconfig
|  |-- 📄 .gitignore
|  |-- 📄 angular.json
|  |-- ℹ️ CODE_OF_CONDUCT.md
|  |-- 📄 LICENSE
|  |-- 📄 Dockerfile
|  |-- 🖼️ logo.png
|  |-- 📄 package-lock.json
|  |-- 📄 package.json
|  |-- ℹ️ README.md
|  |-- 📄 tsconfig.app.json
|  |-- 📄 tsconfig.json
|  |-- 📄 tsconfig.spec.json
|
|-- ⚙️ .env
|-- ⚙️ .env.template
|-- 📄 .gitignore
|-- 📄 docker-compose.yml
|-- ℹ️ README.md
```


## Usage
This project was created to use Docker orchestration without swarm but with a docker-compose.yml file.
Here we combine containerization using a frontend and a backend that are controlled simultaneously.

> The docker-compose.yml is the orchestrator of this application. Two services are created here: the frontend and the backend, which share the same network.
```yml
services:
    frontend:
      build:
        context: ./conduit-frontend
        args:
          API_URL: ${FRONTEND_API_URL} # backend url as variable in .env for local and vm
      restart: on-failure:5 # restart after error 5 times
      ports:
        - "8282:80" # port mapping 
      depends_on:
        - backend # frontend waits until backend is started
      networks:
        - backend_network # (optional) assigned network 

    backend:
      build:
        context: ./conduit-backend
      restart: on-failure:5
      ports:
        - "8000:8000" # port mapping
      networks:
        - backend_network # (optional) assigned network 
      env_file:
        - .env # .env variables are passed to the backend
      volumes:
        - backend_data:/app # persistent data storage



volumes:
    backend_data:

networks:
  backend_network: # (optional) assigned network
```

<br>

> In conduit-backend I have defined a Dockerfile that reflects the Multi Stage Build principle.
```yml
FROM python:3.5-slim as build # Base image with Python 3.5 (compatible with Django 1.10)
WORKDIR /app # Sets the working directory in the container
COPY . /app/ # Copies the complete backend source code into the container

RUN pip install --no-cache-dir -r requirements.txt && \ # Installs Python dependencies and makes the entrypoint script executable
    chmod +x /app/entrypoint.sh


FROM python:3.5-slim as runtime # Slim Python image for runtime
WORKDIR /app # Sets the working directory again
COPY --from=build /app /app # Copies the prepared application code from the build stage
RUN pip install --no-cache-dir -r requirements.txt # Reinstalls dependencies at runtime

EXPOSE 8000 # Opens port 8000 for Gunicorn / Django
ENTRYPOINT [ "/app/entrypoint.sh" ] # Starts the entrypoint script
```

<br>

> In conduit-backend there is also the entrypoint.sh file that handles migration, static files, superuser creation, and server startup via wsgi gunicorn.
```yml
#!/bin/bash
echo "Starting my application..."

python manage.py migrate
python manage.py collectstatic --noinput

python manage.py shell << EOF
from django.contrib.auth import get_user_model

User = get_user_model()

user, created = User.objects.get_or_create(
    username="${SUPERUSER_USERNAME}",
    defaults={
        "email": "${SUPERUSER_EMAIL}",
        "is_staff": True,
        "is_superuser": True,
    }
)

user.is_staff = True
user.is_superuser = True
user.set_password("${SUPERUSER_PASSWORD}")
user.save()
EOF

exec gunicorn conduit.wsgi:application --bind 0.0.0.0:8000
 
```

<br>

> Configuring the web server. In conduit-frontend, an nginx folder was created with a default.conf file since I want to use nginx as the web server.
```js
client_max_body_size 0;
server_tokens off;
server_names_hash_bucket_size 64;

server {
    listen 80; // Web server listens on port 80
    server_name localhost;

    location / {
        root   /usr/share/nginx/html; // the app is located in the /usr/share/nginx/html directory 
        index  index.html; // serves index.html for every accessed path
        try_files $uri $uri/ /index.html;
    }
}
```

<br>

> To create the frontend image, I also created a Dockerfile
```bash
FROM node:22-alpine AS buildcontainer # Uses a Node.js image to build the Angular frontend
WORKDIR /usr/src/app # Sets the working directory in the container
ARG API_URL # Build argument for the API URL
ENV API_URL=${API_URL} # Makes the API_URL available during the build process
COPY . ./ # Copies the complete frontend source code into the container
RUN npm install # Installs all npm dependencies
RUN sed -i "s|__API_URL__|${API_URL}|g" src/environments/environment*.ts # Replaces the __API_URL__ placeholder in all environment files
RUN npm run build # Builds the Angular application

FROM nginx:alpine # Slim Nginx image for serving static files
LABEL maintainer="Adrian Enßlin" # Image metadata
COPY nginx/default.conf /etc/nginx/conf.d # Copies the custom Nginx configuration
COPY --from=buildcontainer /usr/src/app/dist/angular-conduit /usr/share/nginx/html # Copies the built Angular frontend from the build stage to the Nginx HTML directory
```


## Docker commands
Start project
```bash
docker compose up -d
```
Stop containers
```bash
docker compose down
```
Remove containers + volumes
```bash
docker compose down -v
```
Restart
```bash
docker compose restart
```
### Useful Docker commands
List running containers
```bash
docker ps
```
View container logs
```bash
docker logs -f <container-name>
```


## Author
**Adrian Enßlin**