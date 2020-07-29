SHELL := /bin/bash
export TERRAFORM_VERSION = 0.12.3

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Lint terraform code
lint:
	$(SELF) terraform/install terraform/get-modules terraform/get-plugins terraform/lint terraform/validate

## Run Terraform commands in the examples/complete folder; e.g. make test/plan
test/%:
	@cd examples/complete && \
	terraform init && \
	terraform $* -var-file=fixtures.us-west-1.tfvars && \
	terraform $* -var-file=grants.us-west-1.tfvars
