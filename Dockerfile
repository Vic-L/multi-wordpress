FROM hashicorp/terraform:light
WORKDIR /workspace

COPY ./variables.tf .

COPY ./provider.tf .
RUN terraform init

COPY ./secrets_bucket.tf .
RUN terraform init

COPY ./secrets_iam.tf .
COPY ./main.tf .