# Variables
IMAGE_NAME = quay.io/rzhang/image-upload-frontend
IMAGE_TAG = latest
BASE_IMAGE = registry.access.redhat.com/ubi9/nginx-124:latest
REMOTE_BUILD_IMAGE_NAME=default-route-openshift-image-registry.apps.ocp3.galaxy.io/image-upload-frontend/image-upload-frontend-spa

# Default target
.PHONY: all
all: help

# Target: help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make dev    - Start the application locally"
	@echo "  make build  - Build the Vue.js application for production"
	@echo "  make image  - Build and tag the podman image using Nginx base"
	@echo "  make push   - Push the podman image to the registry (optional)"
	@echo "  make clean  - Clean build artifacts (optional)"

# Target: dev
.PHONY: dev
dev:
	@echo "Starting development server..."
	pnpm install
	pnpm run dev --host

# Target: build
.PHONY: build
build:
	@echo "Building the Vue.js application for production..."
	pnpm install
	pnpm run build

# Target: image
.PHONY: image
image: 
	@echo "Building the podman image..."
	# podman build --no-cache --platform linux/amd64  -t $(IMAGE_NAME)-amd64:$(IMAGE_TAG) .
	podman build  --no-cache -t $(IMAGE_NAME)-arm64:$(IMAGE_TAG) .

# Target: push (optional)
.PHONY: push
push: 
	podman pull $(REMOTE_BUILD_IMAGE_NAME):$(IMAGE_TAG) --tls-verify=false
	podman tag $(REMOTE_BUILD_IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):$(IMAGE_TAG) 
	podman push $(IMAGE_NAME):$(IMAGE_TAG) --tls-verify=false

push-remote-build: 
	podman pull $(REMOTE_BUILD_IMAGE_NAME):$(IMAGE_TAG) --tls-verify=false
	podman tag $(REMOTE_BUILD_IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):$(IMAGE_TAG) 
	podman push $(IMAGE_NAME):$(IMAGE_TAG) --tls-verify=false

# Target: clean (optional)
.PHONY: clean
clean:
	@echo "Cleaning up build artifacts..."
	rm -rf node_modules
	rm -rf dist
	rm -f package-lock.json
