# Variables
NAMESPACE=$(shell oc config view --minify -o jsonpath='{..namespace}')
HELM_RELEASE_NAME=image-upload-frontend

# Paths for config files
FRONTEND_CONFIG_PATH=config/frontend-config.js

# URLs for downloading the files
FRONTEND_CONFIG_URL=https://gitlab.galaxy.io/ryanzhang-appdev/ocp-serverless/-/raw/main/deployment/frontend/public/config.js

# Targets
.PHONY: install uninstall test install-dev

install-dev:
	@echo "Preparing to deploy to namespace: $(NAMESPACE)"
	@read -p "Do you want to continue deploying to $(NAMESPACE)? (y/n): " CONFIRM && [ $${CONFIRM} = y ]
	helm upgrade --install $(HELM_RELEASE_NAME) . -f values.yaml -f values-dev.yaml --namespace $(NAMESPACE)


# Install the Helm chart
install: 
	@echo "Preparing to deploy to namespace: $(NAMESPACE)"
	@read -p "Do you want to continue deploying to $(NAMESPACE)? (y/n): " CONFIRM && [ $${CONFIRM} = y ]
	# helm lint .
	helm upgrade --install $(HELM_RELEASE_NAME) . --namespace $(NAMESPACE)

# Uninstall the Helm chart
uninstall:
	helm uninstall $(HELM_RELEASE_NAME) --namespace $(NAMESPACE)

# Run Helm test template
test: 
	helm lint . --set isLinting=true
	helm template image-upload . -f values.yaml -f values-dev.yaml --set isLinting=true| tee test-dev.yaml
	helm template image-upload . -f values.yaml --set isLinting=true| tee test.yaml
	@echo "Test yaml has been generated in test.yaml, please review"

# Download files and perform pre-installation tasks
init:
	@echo "Downloading necessary files..."
	# Ignore TLS check and download frontend-config.js
	curl -kL $(FRONTEND_CONFIG_URL) -o $(FRONTEND_CONFIG_PATH)
	@echo "Files downloaded and pre-task completed."
