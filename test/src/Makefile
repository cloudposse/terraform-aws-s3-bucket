export TF_CLI_ARGS_init ?= -get-plugins=true

.DEFAULT_GOAL : all

.PHONY: all
## Default target
all: test

.PHONY : init
## Initialize tests
init:
	@exit 0

.PHONY : test
## Run tests
test: init
	# Verify we have valid AWS credential
	if command -v aws >/dev/null; then \
	  (unset AWS_PROFILE; aws sts get-caller-identity >/dev/null); \
	fi
	go test -v -timeout 10m -run TestExamplesComplete

## Run tests in docker container
docker/test:
	docker run --name terratest --rm -it -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e GITHUB_TOKEN \
		-e PATH="/usr/local/terraform/0.13/bin:/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
		-v $(CURDIR)/../../:/module/ cloudposse/test-harness:latest -C /module/test/src test

.PHONY : clean
## Clean up files
clean:
	rm -rf $(TF_DATA_DIR) ../../examples/complete/*.tfstate*
