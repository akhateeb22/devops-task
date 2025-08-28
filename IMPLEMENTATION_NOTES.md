# DevOps Assignment – DevOps Notes

This document complements the original Formlabs assignment README.
It explains how I approached the task, my technology choices, and how
to run the project in Docker, Kubernetes, and through CI/CD.

---

## 1. Docker
- Build image:
  ```bash
  docker build -t helloapp:dev .
  ```
- Run container:
  ```bash
  docker run -p 8080:8080 helloapp:dev
  ```

---

## 2. Kubernetes (Helm)
The application is deployed on a managed Kubernetes cluster.

- Build and push image to DOCR:
  ```bash
  docker buildx build --platform linux/amd64 \
    -t registry.digitalocean.com/abd-registry/formlabs:<tag> \
    --push .
  ```
- Deploy with Helm:
  ```bash
  helm upgrade --install helloapp ./helloapp-chart \
    --set image.repository=registry.digitalocean.com/abd-registry/formlabs \
    --set image.tag=<tag>
  ```

### Image Tag Strategy
- The default image tag in `values.yaml` is set to **`dev`**.
- This acts as a placeholder for manual or local deployments.
- In CI/CD, the tag is always overridden with the short Git commit SHA.
- This ensures:
  - **Reproducibility** → every deployment corresponds to a unique commit
  - **Traceability** → easy rollback to a known commit
  - **Safety** → avoids the risks of using `latest`

### Live Deployment
You can test the running application on my DigitalOcean Kubernetes cluster here:  
👉 http://209.38.235.48:30080/

---

## 3. CI/CD (GitHub Actions)
Pipeline stages:
1. Checkout repository
2. Run unit tests with `unittest`
3. Build & push Docker image (amd64)
4. Deploy to DigitalOcean Kubernetes via Helm

**Why GitHub Actions?**
- Natively integrated with GitHub
- Secrets management is simple
- Alternatives (Jenkins, Ansible) were considered, but Actions fits
  this workflow best

**Why Helm?**
- Reusable, templated manifests
- Easier overrides in CI/CD (`--set image.tag=$SHA`)
- Alternative: plain YAML + kubectl, but less flexible

**Why Docker Buildx?**
- Supports multi-arch, but optimized to amd64 for speed
- Alternative: buildah, but Docker Buildx has better GH Actions support

---

## 4. Conclusion
This setup provides:
- Docker image for reproducible builds
- Helm chart for Kubernetes deployment
- GitHub Actions pipeline for automation
- A live deployment accessible at http://209.38.235.48:30080/

Each commit explains decisions and trade-offs in detail, as requested.
