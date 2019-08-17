FROM hashicorp/terraform:full
WORKDIR /workspace
COPY ./aws.tf .
RUN echo $AWS_ACCESS_KEY_ID
RUN echo $AWS_SECRET_ACCESS_KEY
RUN terraform init
