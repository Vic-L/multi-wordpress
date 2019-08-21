FROM hashicorp/terraform:light
WORKDIR /workspace

COPY ./variables.tf .
COPY ./data.tf .
COPY ./terraform.tf .

COPY ./provider.tf .
RUN terraform init

COPY ./secrets_bucket.tf .
RUN terraform init

COPY scripts ./scripts
COPY ./scripts.tf .
RUN terraform init

COPY ./secrets_iam.tf .
COPY ./main.tf .
COPY ./multi_wordpress multi_wordpress
COPY ./multi_wordpress.pub multi_wordpress.pub
COPY ./nginx.conf
COPY ./docker-compose.production.yml docker-compose.production.yml