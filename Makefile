PWD = $(shell pwd)

.PHONY: default-target
default-target: build
	@echo "########################"
	@echo AWS_ACCESS_KEY_ID IS $(AWS_ACCESS_KEY_ID)
	@echo AWS_SECRET_ACCESS_KEY IS $(AWS_SECRET_ACCESS_KEY)
	@echo "########################"
	chmod 400 multi_wordpress.pub
	chmod 400 multi_wordpress
	docker run \
	--rm \
	-it \
	-v $(PWD)/terraform.tfstate:/workspace/terraform.tfstate \
	--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	multi-wordpress-terraform \
	apply \
	-var multi_wordpress_repository=$(GIT_REPOSITORY)

###################

define MISSING_AWS_PROFILE
AWS_PROFILE is undefined.
Run command `make AWS_PROFILE=your_profile GIT_REPOSITORY=git@provider.com:username/repo_name.git <TARGET>`.
Make sure your profile has the relevant permissions to run the various actions (TODO) as defined in the `main.tf` file.
endef

define MISSING_GIT_REPOSITORY
GIT_REPOSITORY is undefined.
Run command `make AWS_PROFILE=your_profile GIT_REPOSITORY=git@provider.com:username/repo_name.git <TARGET>`.
Make sure you are using the url version (starting with "https://") instead of the git version (starting with "git:").
endef

.PHONY: check-argument
check-argument:
ifndef AWS_PROFILE
	$(error $(MISSING_AWS_PROFILE))
else ifndef GIT_REPOSITORY
	$(error $(MISSING_GIT_REPOSITORY))
else
	# init env var for aws cli to use https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
	$(eval export AWS_ACCESS_KEY_ID := $(shell aws --profile $(AWS_PROFILE) configure get aws_access_key_id))
	$(eval export AWS_SECRET_ACCESS_KEY := $(shell aws --profile $(AWS_PROFILE) configure get aws_secret_access_key))
	$(eval export AWS_DEFAULT_REGION := us-east-1)
endif

.PHONY: build
build: check-argument
	docker build -t multi-wordpress-terraform:latest .

destroy: check-argument build
	@echo "########################"
	@echo AWS_ACCESS_KEY_ID IS $(AWS_ACCESS_KEY_ID)
	@echo AWS_SECRET_ACCESS_KEY IS $(AWS_SECRET_ACCESS_KEY)
	@echo "########################"
	@echo NOTE: This operation will not destroy the "aws_ebs_volume".
	docker run \
	--rm \
	-it \
	-v $(PWD)/terraform.tfstate:/workspace/terraform.tfstate \
	--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	multi-wordpress-terraform \
	destroy \
	-target aws_s3_bucket.secrets_logging_bucket \
	-target aws_security_group.this \
	-target aws_volume_attachment.this \
	-target aws_eip.this \
	-target aws_instance.this \
	-target aws_iam_instance_profile.secrets_bucket \
	-target aws_iam_role.secrets_bucket \
	-target module.secrets_bucket \
	-target aws_key_pair.this

# Development

start:
	docker-compose -f docker-compose.base.yml -f docker-compose.development.yml up -d
stop:
	docker-compose -f docker-compose.base.yml -f docker-compose.development.yml down

setup:
	./setup.sh