FROM hashicorp/terraform:light
WORKDIR /workspace

COPY ./variables.tf .
COPY ./data.tf .

COPY ./provider.tf .
RUN terraform init

COPY ./secrets_bucket.tf .
RUN terraform init

COPY ./multi_wordpress multi_wordpress
COPY ./multi_wordpress.pub multi_wordpress.pub
COPY ./null_resource.tf .
RUN terraform init

COPY ./secrets_iam.tf .
COPY ./main.tf .