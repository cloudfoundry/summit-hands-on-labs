# CF Summit Lab: Moving from Dockerfiles to Buildpacks

## Build with Docker

### Building and running the backend
1. `docker build -t backend backend/`
1. `docker run -it -p 3000:3000 backend`

### Building and running the frontend
1. `docker build -t frontend frontend/`
1. `docker run -it -p 3001:3000 --env BACKEND_HOST=127.0.0.1:3000 frontend`

## Build with Paketo Cloud Native Buildpacks

### Prerequistes.

- pack
  - https://buildpacks.io/docs/tools/pack

- Docker
  - https://www.docker.com/products/docker-desktop

### Backend

1. From `backend` directory run:
   - `pack build backend --buildpack paketo-buildpacks/ruby` --path backend/
1. Run the backend in a docker container locally execute:
   - `docker run -it -p 3000:9292 --env RAILS_ENV=production backend`


### Frontend

1. Make the following changes to the `nginx.conf` file:
   - Replace `listen 3000` with `listen {{ port }}`
   - Update `sub_filter 'BACKEND_HOST' '${BACKEND_HOST}';` to be `sub_filter 'BACKEND_HOST' '{{env "BACKEND_HOST"}}';`
1. Run the following command to build the frontend:
   - `pack build frontend --env BP_NODE_RUN_SCRIPTS="build" --buildpack paketo-buildpacks/node-engine@0.5.0 --buildpack paketo-buildpacks/yarn@0.3.0 --buildpack paketo-buildpacks/yarn-install@0.4.0 --buildpack <YOUR_LOCATION>/node-run-script/build/buildpackage.cnb --buildpack paketo-buildpacks/nginx@0.3.1 --path frontend/`
1. Run the frontend:
   - `docker run -it -p 3001:3000 --env PORT=3000 --env BACKEND_HOST=127.0.0.1:3000 frontend`
