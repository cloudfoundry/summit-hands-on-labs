# CF Summit Lab: Moving from Dockerfiles to Buildpacks

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_image=gcr.io/summit-labs/paketo:latest&cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fcloudfoundry%2Fsummit-hands-on-labs&cloudshell_working_dir=2021%2FPaketo&cloudshell_tutorial=README.md)

## Introduction

Are you tired of updating your application dependencies in your Dockerfiles?
Would you like to try buildpacks, but you don’t know where to start? In this
session, we will demonstrate how you can move your application from a
Dockerfile to buildpacks. Once we move our application onto buildpacks, we’ll
show how you can keep your application dependencies up-to-date. We’ll cover the
details of what the buildpacks are doing, and what that means you can stop
doing.

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

#### Building the containers
1. Build the backend application
   ```
   docker build -t backend backend/
   ```

1. Build the frontend application
   ```
   docker build -t frontend frontend/
   ```

#### Running the containers

1. Run the backend application
   ```
   docker run -it backend
   ```

1. Find the internal IP for the backend application
   ```
   docker network inspect bridge
   ```

1. Run the frontend application
   ```
   docker run -it -p 8080:3000 --env BACKEND_HOST=http://<backend-internal-ip>:3000 frontend
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

1. Find the internal IP for the backend application
   ```
   docker network inspect bridge
   ```

1. Run the frontend application
   ```
   docker run -it -p 8080:3000 --env PORT=3000 --env BACKEND_HOST=<backend-internal-ip>:3000 frontend
   ```
