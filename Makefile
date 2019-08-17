AWS_ACCESS_KEY_ID = $(shell aws --profile $(AWS_PROFILE) configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY = $(shell aws --profile $(AWS_PROFILE) configure get aws_secret_access_key)
default-target: check-argument build
	@echo AWS_ACCESS_KEY_ID IS $(AWS_ACCESS_KEY_ID)
	@echo AWS_SECRET_ACCESS_KEY IS $(AWS_SECRET_ACCESS_KEY)
	docker run --rm --env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) --env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) multi-wordpress-terraform apply

###################

define MISSING_AWS_PROFILE
AWS_PROFILE is undefined.
Run command `make AWS_PROFILE=your_profile`.
Make sure your profile has the relevant permissions to run the various actions (TODO) as defined in the `aws.tf` file.
endef

check-argument:
ifndef AWS_PROFILE
	$(error $(MISSING_AWS_PROFILE))
endif

build:
	docker build -t multi-wordpress-terraform:latest .
