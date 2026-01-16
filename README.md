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
6. [Logs](#logs)
7. [Author](#author)

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

Generate a Django secret key:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

> [!NOTE]
> Paste the generated key into your `.env`.


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
|-- 📁 .github
|--|-- 📁 workflows
|  |--|-- ❕ docker-image.yml
|
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

> The docker-compose.yml acts as the orchestrator of this application. Two services are defined here: the frontend and the backend, which share the same network.

→ [docker-compose.yml](./docker-compose.yml)
``` yml
- args        # Backend API URL provided via .env (local and VM environments)
- restart     # Restarts the container up to 5 times on failure
- ports       # Port mapping <host>:<container>
- depends_on  # Ensures the backend is started before the frontend
- networks    # (Optional) Assigned Docker network
```

→ [docker-compose.yml](./docker-compose.yml)
``` yml
- restart   # Restarts the container up to 5 times on failure
- ports     # Port mapping <host>:<container>
- networks  # (Optional) Assigned Docker network
- env_file  # Loads environment variables from .env
- volumes   # Persists data such as database and media files outside the container
```

<br>

> The backend Dockerfile defines a minimal single-stage build for running the Django application inside a container.

→ [Backend Dockerfile](./conduit-backend/Dockerfile)
``` yml
- base image   # Uses a slim Python 3.5 image compatible with Django 1.10
- workdir      # Sets the application working directory inside the container
- copy         # Copies the complete backend source code into the container
- dependencies # Installs Python dependencies and prepares the entrypoint script
- expose       # Exposes port 8000 for the Django/Gunicorn application
- entrypoint   # Starts the application via an entrypoint script
```

<br>

> The entrypoint.sh script is responsible for preparing and starting the backend application at container startup.

→ [Entrypoint script](./conduit-backend/entrypoint.sh)
``` yml
- initialization   # Prepares required directories for database and media files
- migrations       # Applies all pending Django database migrations
- static files     # Collects static assets for production usage
- superuser setup  # Creates or updates an administrative user from environment variables
- application run  # Starts the Django application using Gunicorn (WSGI server)
```

<br>

> The frontend is served using Nginx as a lightweight and performant web server.

→ [Nginx configuration](./conduit-frontend/nginx/default.conf)
``` yml
- build stage     # Compiles the Angular application using Node.js
- config injection # Injects the backend API URL at build time via build arguments
- optimization    # Excludes Node.js and build tools from the final image
- runtime stage   # Serves the compiled frontend via a minimal Nginx image
```

<br>

> The frontend image is built using a multi-stage Docker build to separate the build process from the runtime environment.

→ [Frontend Dockerfile](./conduit-frontend/Dockerfile)
``` yml
- build stage     # Compiles the Angular application using Node.js
- config injection # Injects the backend API URL at build time via build arguments
- optimization    # Excludes Node.js and build tools from the final image
- runtime stage   # Serves the compiled frontend via a minimal Nginx image

```
<br>

> The GitHub Actions workflow automates the build, publish, and deployment process for the Conduit application using Docker and GitHub Container Registry.

→ [GitHub Actions Workflow](./.github/workflows/docker-image.yml)
``` yml
- checkout        # Checks out the repository to access Dockerfiles and compose configuration
- registry login  # Authenticates to GitHub Container Registry (GHCR) using GITHUB_TOKEN
- image build     # Builds backend and frontend Docker images via Docker Buildx
- image publish   # Pushes versioned images (latest + commit SHA) to GHCR
- env provisioning# Creates and secures the .env file on the target VM via SSH
- compose sync    # Transfers the docker-compose.yml to the remote server
- deployment      # Pulls updated images and recreates containers using Docker Compose
- cleanup         # Removes unused Docker images to keep the server clean
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

## Logs
Logs of running containers can be viewed directly via the Docker CLI.

View logs
```bash
docker logs <container-name>
```

View logs
```bash
docker logs <container-name>
```

View logs live
```bash
docker logs -f <container-name>
```

Save logs to a file
```bash
docker logs <container-name> > <container-name>-logs.txt
```


## Author
**Adrian Enßlin**