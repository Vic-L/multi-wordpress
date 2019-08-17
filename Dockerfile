FROM hashicorp/terraform:light
WORKDIR /workspace
COPY ./setup.tf .
RUN terraform init
RUN rm setup.tf
COPY ./aws.tf .