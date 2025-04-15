# Angular Application Continuous Integration & Deployment Pipeline

This repository implements a comprehensive CI/CD pipeline architecture for containerizing and automating deployment of a single-page Angular application. The implementation adheres to standard DevOps methodologies, including infrastructure-as-code, container orchestration, webhook-driven deployment, and semantic versioning.

## Repository Structure

- `angular-site/` - Angular application codebase with Node.js/npm dependencies
- `Dockerfile` - Multi-stage container build definition with production optimizations
- `.github/workflows/` - Declarative GitHub Actions workflow configurations
- `deployment/` - Infrastructure automation scripts and service configurations
- `diagrams/` - Architecture visualization source (DOT files)
- `images/` - Documentation assets and architectural diagrams
- `interactive/` - D3.js force-directed graph visualization of the CI/CD topology

## Technical Documentation

This implementation is thoroughly documented in two distinct technical specifications:

### [README-CI.md](https://github.com/WSU-kduncan/ceg3120-cicd-Luximo/blob/main/README-CI.md)

This specification details the Continuous Integration infrastructure:
- Docker containerization methodology using Node.js base images
- Container layer optimization and caching strategies
- GitHub Actions workflow orchestration with declarative YAML syntax
- DockerHub registry integration with token-based authentication
- Visualization of the CI process topology using directed graphs

### [README-CD.md](https://github.com/WSU-kduncan/ceg3120-cicd-Luximo/blob/main/README-CD.md)

This specification covers the Continuous Deployment architecture:
- Implementation of SemVer-compliant release tagging using Git metadata
- EC2 compute provisioning with appropriate security group configurations
- Event-driven deployment using webhook HTTP endpoints
- Systemd service configuration for process supervision
- Runtime persistence mechanisms and container orchestration
- End-to-end pipeline verification methodology

## Runtime Instantiation

To instantiate this container in a local environment:
```
docker pull luximo1/otuvedo-ceg3120:latest
docker run -d -p 4200:4200 --restart=unless-stopped luximo1/otuvedo-ceg3120:latest
```

HTTP service is exposed on port 4200 with standard Angular routing capabilities.