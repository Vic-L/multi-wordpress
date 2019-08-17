AWS_ACCESS_KEY_ID = $(shell aws --profile $(AWS_PROFILE) configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY = $(shell aws --profile $(AWS_PROFILE) configure get aws_secret_access_key)

# init env var for aws cli to use https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
export AWS_ACCESS_KEY_ID := $(AWS_ACCESS_KEY_ID)
export AWS_SECRET_ACCESS_KEY := $(AWS_SECRET_ACCESS_KEY)
export AWS_DEFAULT_REGION := us-east-1

PWD = $(shell pwd)

default-target: check-argument build
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
	apply 

###################

define MISSING_AWS_PROFILE
AWS_PROFILE is undefined.
Run command `make AWS_PROFILE=your_profile <TARGET>`.
Make sure your profile has the relevant permissions to run the various actions (TODO) as defined in the `main.tf` file.
endef

check-argument:
ifndef AWS_PROFILE
	$(error $(MISSING_AWS_PROFILE))
endif

build:
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