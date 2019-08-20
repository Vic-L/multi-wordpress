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
COPY ./startup.sh startup.sh
COPY ./automount_reboot.sh automount_reboot.sh
COPY ./scripts.tf .
RUN terraform init

COPY ./secrets_iam.tf .
COPY ./main.tf .