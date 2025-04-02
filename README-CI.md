# CI/CD Workflow Implementation – Phase One: Angular Frontend Containerization

## Abstract

This Project Phase 1 explains how I am creating a version of a web application designed with Angular, which will be packaged in a container as part of a broader initiative outlined in Phase 1 of this three-phase project. In this stage, I aim to develop a straightforward and adaptable Docker image for a single-page Angular application, which I will then share on DockerHub. You can think of it like preparing a well-organised dessert: just as you would bake a cake, decorate it, and put it into a box to keep it fresh for anyone who wants to enjoy it, we’re doing something similar with our application. We have documented every step of the process, from manually testing it to creating a set of instructions for building our Docker image and finally sharing it publicly, ensuring that everyone, regardless of the platform they use, can access and enjoy it without any hassle.

---

## Contents

- [CI/CD Workflow Implementation – Phase One: Angular Frontend Containerization](#cicd-workflow-implementation--phase-one-angular-frontend-containerization)
  - [Abstract](#abstract)
  - [Contents](#contents)
  - [1. Project Context](#1-project-context)
    - [Objectives](#objectives)
    - [Application: `Birds Gone Wild`](#application-birds-gone-wild)
  - [2. Technical Environment](#2-technical-environment)
    - [Docker Installation (WSL2 Backend)](#docker-installation-wsl2-backend)
  - [3. Preliminary Manual Containerization](#3-preliminary-manual-containerization)
    - [Runtime Procedure](#runtime-procedure)
  - [4. Declarative Dockerfile Construction](#4-declarative-dockerfile-construction)
    - [Dockerfile](#dockerfile)
    - [Build Logic](#build-logic)
  - [5. Image Compilation \& Execution](#5-image-compilation--execution)
    - [Image Build](#image-build)
    - [Local Run](#local-run)
  - [6. Container Registry Integration](#6-container-registry-integration)
    - [Repository Provisioning](#repository-provisioning)
    - [CLI Authentication](#cli-authentication)
    - [Push Operation](#push-operation)
    - [Repository Access](#repository-access)
  - [7. Application Accessibility](#7-application-accessibility)
  - [8. Validation Matrix](#8-validation-matrix)
  - [End Notes](#end-notes)

---

## 1. Project Context

This repository encapsulates the first milestone in a multi-phase DevOps pipeline implementation, aiming to reinforce containerization best practices and introduce Docker-centric automation workflows.

### Objectives

- Encapsulate an Angular application within a Docker container.  
- Validate runtime environment through both manual and declarative methods.  
- Publish containerized application to a public registry for universal accessibility.

### Application: `Birds Gone Wild`

The target application is a responsive Angular SPA, visually themed and bundled with an epic Eagle imagery and custom navigation logic. It is located under `angular-site/`.

---

## 2. Technical Environment

| Component      | Version / Spec                     |
|----------------|------------------------------------|
| Host OS        | Windows (Docker Desktop with WSL2) |
| Container Base | `node:18-bullseye`                 |
| Framework      | Angular CLI (latest via npm)       |
| Registry       | DockerHub                          |
| CLI Tools      | Docker, WSL, Git                   |

### Docker Installation (WSL2 Backend)

```
wsl --install
docker --version
```

Installation source:  
[Install Docker Desktop on Windows](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?_gl=1*1glbvc0*_gcl_au*NTY1OTMzODU3LjE3NDI1NjA0NDk.*_ga*MTc1NjI2MjY5OS4xNzM4NDIzNDk1*_ga_XJWPQMJYHQ*MTc0MzU5MzUyMS41LjEuMTc0MzU5MzUyNi41NS4wLjA.)

---

## 3. Preliminary Manual Containerization

This section illustrates a containerized Angular workflow executed entirely via CLI, without a `Dockerfile`. This is useful for prototyping or live-debug scenarios.

### Runtime Procedure

```
docker run -it --rm node:18-bullseye bash
```

Inside the container:

```
npm install -g @angular/cli
# Transfer angular-site/ via volume or docker cp
cd /app
npm install
ng serve --host 0.0.0.0
```

Rationale: Running Angular on `0.0.0.0` allows exposure through Docker port forwarding to the host system.

---

## 4. Declarative Dockerfile Construction

A production-ready `Dockerfile` was constructed to encapsulate the Angular build and serve processes using a multistep strategy.

### Dockerfile

```
# Use official Node.js 18 image as base
FROM node:18-bullseye

# Set the working directory inside the container
WORKDIR /app

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Copy package.json and package-lock.json first (to leverage caching)
COPY angular-site/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY angular-site/ .

# Expose the port Angular uses
EXPOSE 4200

# Run the Angular development server
CMD ["ng", "serve", "--host", "0.0.0.0"]

```

### Build Logic

- The image builds from a slim Debian-based Node.js distribution.  
- Angular CLI is installed globally to support live serving.  
- The working directory is isolated and layered with `COPY` and `RUN` to optimize build caching.  
- The application is served over port 4200 to enable host access via port mapping.

---

## 5. Image Compilation & Execution

### Image Build

```
docker build -t luximo1/otuvedo-ceg3120 .
```
![Fig5.0](images/image.png)

- Tag: `luximo1/otuvedo-ceg3120`  
- Build Context: Root project directory

### Local Run

```
docker run -p 4200:4200 luximo1/otuvedo-ceg3120
```

![Fig5.1](images/image-1.png)

Mapping `4200:4200` enables browser-based access on the host at `http://localhost:4200`.

![Fig5.2](images/image-2.png)

---

## 6. Container Registry Integration

### Repository Provisioning

A public repository was created at DockerHub under the namespace:

```
luximo1/otuvedo-ceg3120
```

Steps:
- Log in to DockerHub
- Create a new repository (`Public`)
- Repository name: `otuvedo-ceg3120`

### CLI Authentication

```
docker login
```

Enter:
- DockerHub Username: `luximo1`
- DockerHub Password or PAT

![Fig6.0](images/image-3.png)

### Push Operation

```
docker push luximo1/otuvedo-ceg3120
```

![Fig6.1](images/image-4.png)

This operation uploads the image layers and publishes the tagged build to the DockerHub registry.

### Repository Access

URL:  
[https://hub.docker.com/repository/docker/luximo1/otuvedo-ceg3120/general](https://hub.docker.com/repository/docker/luximo1/otuvedo-ceg3120/general)

To replicate the environment elsewhere:

```
docker pull luximo1/otuvedo-ceg3120
docker run -p 4200:4200 luximo1/otuvedo-ceg3120
```

---

## 7. Application Accessibility

Once the container is instantiated and running, navigate to:

```
http://localhost:4200
```

The browser should render the SPA titled **Birds Gone Wild**, including an epic eagle graphic, themed layout, and a functional Angular navigation component.

---

## 8. Validation Matrix

| Task                                                   | Outcome     |
|--------------------------------------------------------|-------------|
| Docker installed and verified (WSL2 backend)           | Confirmed   |
| Angular app placed under `angular-site/`               | Confirmed   |
| Manual runtime containerization                        | Validated   |
| Dockerfile written and optimized                       | Confirmed   |
| Image built using `docker build`                       | Successful  |
| Image executed locally via container                   | Functional  |
| Angular app accessible via browser                     | Verified    |
| DockerHub authentication and image push                | Successful  |
| Public pullable container image available              | Confirmed   |
| Final system behavior matches project requirements     | Verified    |

---

## End Notes

This README documents Phase One of the CI/CD workflow. It establishes a production-ready, platform-agnostic container for frontend delivery, aligning with modern DevOps and microservice standards. Phase Two will expand upon this by introducing automation pipelines using GitHub Actions, image versioning, and environment-specific deployments.