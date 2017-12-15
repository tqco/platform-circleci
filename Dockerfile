FROM circleci/openjdk:8u151-jdk-node-browsers

# gcloud installations command expect to run as root
USER root

RUN export DEBIAN_FRONTEND=noninteractive; \
	apt-get update -y; \
    apt-get install -y \
    apt-utils \
    unzip \
    curl;

RUN curl -fsSLO https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip; \
    unzip google-cloud-sdk.zip; \
    rm google-cloud-sdk.zip; \
    google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components kubectl alpha beta; \
    google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true; \
    export PATH=/google-cloud-sdk/bin:$PATH; \
    gcloud --version;

ENV PATH=/google-cloud-sdk/bin:$PATH

# Revert to default user
USER circleci
