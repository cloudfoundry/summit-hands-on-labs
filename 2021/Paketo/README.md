# CF Summit Lab: Moving from Dockerfiles to Buildpacks

## Introduction



### Target Audience

Developers that a familiar with Docker and Dockerfiles, but interested in
reducing the burden of maintaining their container images.

### Learning Objectives

1. Run some basic `pack` commands
1. Build a couple of applications using buildpacks

### Prerequisites

Students should have a basic understanding of Docker, Dockerfiles, and containers.

## Lab

### Build with Docker

#### Building and running the backend
1. Build the backend application
   ```
   docker build -t backend backend/
   ```

1. Run the backend application
   ```
   docker run -it backend
   ```

1. Find the internal IP for the backend application
   ```
   docker network inspect bridge
   ```

#### Building and running the frontend
1. Build the frontend application
   ```
   docker build -t frontend frontend/
   ```

1. Run the frontend application
   ```
   docker run -it -p 8080:3000 --env BACKEND_HOST=<backend-internal-ip>:3000 frontend
   ```

### Build with Paketo Cloud Native Buildpacks

#### Backend

1. Build the backend application
   ```
   pack build backend --buildpack paketo-buildpacks/ruby --path backend/
   ```

1. Run the backend application
   ```
   docker run -it --env PORT=3000 --env RAILS_ENV=production backend
   ```


#### Frontend

1. Make the following changes to the `nginx.conf` file
   - Replace `listen 3000` with `listen {{ port }}`
   - Update `proxy_pass '${BACKEND_HOST}';` to be `proxy_pass '{{env "BACKEND_HOST"}}';`

1. Build the frontend application
   ```
   pack build frontend \
     --env BP_NODE_RUN_SCRIPTS="build" \
     --buildpack paketo-buildpacks/node-engine@0.5.0 \
     --buildpack paketo-buildpacks/yarn@0.3.0 \
     --buildpack paketo-buildpacks/yarn-install@0.4.0 \
     --buildpack paketo-buildpacks/node-run-script@0.1.0 \
     --buildpack paketo-buildpacks/nginx@0.3.1 \
     --path frontend/
   ```

1. Run the frontend application
   ```
   docker run -it -p 8080:3000 --env PORT=3000 --env BACKEND_HOST=<backend-internal-ip>:3000 frontend
   ```

## Review

## Beyond the Lab

---
