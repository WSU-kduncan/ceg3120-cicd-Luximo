# CI/CD Workflow Implementation – Phase One: Angular Frontend Containerization

## Abstract

This Project Phase 1 explains how I am creating a version of a web application designed with Angular, which will be packaged in a container as part of a broader initiative outlined in Phase 1 of this three-phase project. In this stage, I aim to develop a straightforward and adaptable Docker image for a single-page Angular application, which I will then share on DockerHub. You can think of it like preparing a well-organised dessert: just as you would bake a cake, decorate it, and put it into a box to keep it fresh for anyone who wants to enjoy it, we’re doing something similar with our application. We have documented every step of the process, from manually testing it to creating a set of instructions for building our Docker image and finally sharing it publicly, ensuring that everyone, regardless of the platform they use, can access and enjoy it without any hassle.

---

![CI/CD Diagram](images/ci-cd.png)

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
- [CI/CD Workflow Implementation – Phase Two: GitHub Actions Automation \& Registry Synchronization](#cicd-workflow-implementation--phase-two-github-actions-automation--registry-synchronization)
  - [1. Overview](#1-overview)
  - [2. Secure Integration with DockerHub](#2-secure-integration-with-dockerhub)
    - [2.1 Required Secrets](#21-required-secrets)
    - [2.2 Configuring Secrets](#22-configuring-secrets)
  - [3. Workflow Automation via GitHub Actions](#3-workflow-automation-via-github-actions)
    - [3.1 Workflow Trigger](#31-workflow-trigger)
    - [3.2 Job Definition: `build-and-push`](#32-job-definition-build-and-push)
    - [3.3 Key Components](#33-key-components)
  - [4. Repository and Image Distribution](#4-repository-and-image-distribution)
    - [4.1 DockerHub Target](#41-dockerhub-target)
    - [4.2 Docker Pull Command](#42-docker-pull-command)
      - [Workflow file link](#workflow-file-link)
  - [5. Reusability and Extension](#5-reusability-and-extension)
- [CI/CD Workflow Implementation – Phase Three: Visualization and System Mapping](#cicd-workflow-implementation--phase-three-visualization-and-system-mapping)
  - [1. Purpose and Scope](#1-purpose-and-scope)
  - [2. Tooling \& Methodology](#2-tooling--methodology)
  - [3. Repository Structure for Diagram Assets](#3-repository-structure-for-diagram-assets)
  - [4. Static Diagram Generation – Graphviz](#4-static-diagram-generation--graphviz)
    - [Command to Generate Output](#command-to-generate-output)
    - [Embedded Preview](#embedded-preview)
  - [5. Interactive Visualization – D3.js](#5-interactive-visualization--d3js)
    - [Interactive Features](#interactive-features)
    - [Accessing the Interactive Version](#accessing-the-interactive-version)
  - [6. Logical Flow Model](#6-logical-flow-model)
- [Resources](#resources)

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

This confirms that the browser rendered the SPA titled **Birds Gone Wild**, including an epic eagle graphic, themed layout, and a functional angular navigation component.

# CI/CD Workflow Implementation – Phase Two: GitHub Actions Automation & Registry Synchronization

## 1. Overview

This phase introduces continuous deployment by leveraging GitHub Actions to automate Docker image builds and distribution workflows. Upon every push to the `main` branch, the pipeline performs the following:

- Authenticates with DockerHub using encrypted secrets.  
- Builds the Angular container using the project’s Dockerfile.  
- Tags and pushes the image to a public DockerHub repository.  

This eliminates the need for manual `docker build` and `docker push` operations, aligning the workflow with modern Infrastructure-as-Code (IaC) and Continuous Deployment (CD) standards.

---

## 2. Secure Integration with DockerHub

GitHub Actions workflows require authenticated access to DockerHub in order to push images. This is achieved through GitHub repository secrets.

### 2.1 Required Secrets

| Secret Name       | Purpose                                              |
|-------------------|------------------------------------------------------|
| `DOCKER_USERNAME` | DockerHub account username (`luximo1`)              |
| `DOCKER_TOKEN`    | DockerHub Personal Access Token (Read/Write scope)  |

Secrets are environment-injected variables, encrypted at rest and never exposed in logs or build artifacts.

### 2.2 Configuring Secrets

To define these secrets within a GitHub repository:

1. Navigate to:  
   `GitHub Repository (ceg3120-cicd-Luximo) then Settings then Secrets and variables then click Actions`

2. Select **New repository secret**

3. Create the following key-value pairs:
   - `DOCKER_USERNAME = luximo1`
     - ![Fig2.0](images/image-5.png)
   - `DOCKER_TOKEN = <your personal access token>`
     - ![Fig2.1](images/image-6.png)

Personal access tokens can be generated from here:  
`DockerHub Avatar then Account Settings then Personal Access Token and click on Generate New Token`

---

## 3. Workflow Automation via GitHub Actions

A GitHub Actions pipeline is declared in:

```
.github/workflows/docker-build.yml
```

This workflow is automatically triggered on every push to the `main` branch. It builds and deploys a Docker image defined by the `Dockerfile` in the project root.

### 3.1 Workflow Trigger

```
on:
  push:
    branches:
      - main
```

This ensures deployment automation only occurs for production-bound commits on the `main` branch.

### 3.2 Job Definition: `build-and-push`

```
jobs:
  build-and-push: # Name of the job within the workflow
    runs-on: ubuntu-latest # Specifies the runner environment to use. In this case, it's the latest Ubuntu version.

    steps:
      - name: Checkout repository # Step to clone the repository onto the runner machine.
        uses: actions/checkout@v4 # Action that checks out the code from the repository. Version 4 of the checkout action is being used.

      - name: Set up Docker Buildx # Step to set up Docker Buildx, a tool that supports advanced build features like multi-platform builds.
        uses: docker/setup-buildx-action@v3 # Docker action that configures Buildx. Version 3 of this action is being used.

      - name: Authenticate to DockerHub # Step to log into DockerHub so the workflow can push images.
        uses: docker/login-action@v3 # Docker action that handles authentication to DockerHub. Version 3 of this action is being used.
        with: # Inputs for the authentication action.
          username: ${{ secrets.DOCKER_USERNAME }} # DockerHub username stored as a GitHub secret.
          password: ${{ secrets.DOCKER_TOKEN }} # DockerHub password or access token, also stored securely as a GitHub secret.

      - name: Build and Push Docker Image # Step to build the Docker image using the Dockerfile and push it to DockerHub.
        uses: docker/build-push-action@v5 # Docker action that builds and pushes Docker images. Version 5 of this action is being used.
        with: # Inputs for building and pushing the image.
          context: . # Specifies the build context, which is the current directory (where the code resides).
          file: ./Dockerfile # Path to the Dockerfile used for building the image.
          push: true # Indicates that the built image should be pushed to a registry (DockerHub).
          tags: luximo1/otuvedo-ceg3120:latest # Tag(s) assigned to the image. Tags help in identifying the image version or purpose.

```

### 3.3 Key Components

| Component                      | Description                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| `actions/checkout`            | Pulls the repository contents into the workflow runner                     |
| `docker/setup-buildx-action` | Enables advanced build features (layer caching, multi-arch, etc.)          |
| `docker/login-action`         | Authenticates securely using the injected secrets                          |
| `docker/build-push-action`    | Builds the container image and pushes it to DockerHub                      |

---

## 4. Repository and Image Distribution

### 4.1 DockerHub Target

The image is pushed to the following public repo:

**DockerHub:**  
[https://hub.docker.com/repository/docker/luximo1/otuvedo-ceg3120/general](https://hub.docker.com/repository/docker/luximo1/otuvedo-ceg3120/general)

### 4.2 Docker Pull Command

To retrieve the latest deployed image:

```
docker pull luximo1/otuvedo-ceg3120
docker run -p 4200:4200 luximo1/otuvedo-ceg3120
```
![Fig4.0](images/image-7.png)

This image will reflect the most recent commit to the `main` branch, ensuring immutable and reproducible deployments.

#### Workflow file link
- [Workflow file in my GitHub repo](https://github.com/WSU-kduncan/ceg3120-cicd-Luximo/actions/runs/14219530053/workflow)
---

## 5. Reusability and Extension

This workflow can be adapted for use across multiple repositories with minimal change. The only required modifications are:

- Update the image tag to match your DockerHub namespace:
  
  ```
  tags: your-dockerhub-username/your-repo-name:latest
  ```

- Ensure both `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets are present in the new repository.

- Ensure a valid `Dockerfile` exists in the root or update the `file:` path accordingly.

---

# CI/CD Workflow Implementation – Phase Three: Visualization and System Mapping

## 1. Purpose and Scope

This phase provides visual documentation for the CI/CD pipeline established in the earlier stages. I have created diagrams to show how the system is structured, how different resources work together, and what triggers the automation throughout the process of packaging and deploying applications. The final materials include both simple images and interactive formats, making them easy for everyone, regardless of technical knowledge, to understand.

---

## 2. Tooling & Methodology

| Tool         | Application Scope                                                                 |
|--------------|-------------------------------------------------------------------------------------|
| Graphviz     | Generated a static `.png` diagram from a declarative `.dot` source file            |
| D3.js        | Created an interactive, web-based graph model of the CI/CD pipeline                |

These tools were selected to meet dual objectives:  
- **Graphviz** for precise, version-controllable diagrams with build reproducibility  
- **D3.js** for browser-based interactivity, dynamic layouting, and much better visual parsing

---

## 3. Repository Structure for Diagram Assets

The following folder hierarchy was introduced to organize diagram sources, builds, and presentation layers:

![Fig2.0](images/image-16.png)

These directories support versioning, artifact regeneration, and standalone visualization access.

---

## 4. Static Diagram Generation – Graphviz

A static diagram was constructed using the DOT language to define a directed graph representing the CI/CD pipeline.

### Command to Generate Output

```
dot -Tpng diagrams/ci-cd.dot -o images/ci-cd.png
```

This converts the DOT graph source to a high-resolution PNG format suitable for embedding, documentation, and printing.

### Embedded Preview

The diagram below illustrates the data and process flow across the system components:

- ![CI/CD Diagram](images/ci-cd.png)

Key elements include:
- GitHub repository event triggers  
- Secure injection of encrypted secrets into GitHub Actions  
- Container build and image push to DockerHub  
- Angular application deployment from built container

---

## 5. Interactive Visualization – D3.js

To enhance interactive inspection and educational engagement, the logical pipeline was reconstructed using D3.js as a **force-directed graph model**.

### Interactive Features

- Physics-based layout with drag-and-drop interactivity
- Color-coded node clusters based on role (e.g., Auth, Build, Deployment)
- Link annotations to define relationships (e.g., *triggers*, *pulls*, *pushes*)
- Tooltip overlays for additional metadata per node

### Accessing the Interactive Version

This is the interactive version of continuous integration process below:

```
interactive/ci-cd-graph-arrows.html
```

---

## 6. Logical Flow Model

The diagram—both static and interactive—encodes the following CI/CD pipeline logic:

1. A **Git Push to the `main` branch** triggers an automated workflow.
2. **GitHub Actions** invokes a job runner on a clean `ubuntu-latest` environment.
3. **Secrets** (`DOCKER_USERNAME`, `DOCKER_TOKEN`) are securely injected at runtime.
4. **DockerHub Authentication** is performed using those credentials.
5. The local project directory and its **Dockerfile** are used to construct the container image.
6. The image is then **pushed to DockerHub** under the `luximo1/otuvedo-ceg3120` namespace.
7. The image becomes **publicly accessible** for downstream consumption or deployment.
---

# Resources
- []()


