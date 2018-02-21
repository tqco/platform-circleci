FROM circleci/openjdk:8u151-jdk-node-browsers

## gcloud installations command expect to run as root
USER root

## Install prerequisites
RUN export DEBIAN_FRONTEND=noninteractive; \
	apt-get update -y; \
    apt-get install -y \
    apt-utils \
    unzip \
    curl;

## Install Google Cloud SDK
RUN curl -fsSLO https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip; \
    unzip google-cloud-sdk.zip; \
    rm google-cloud-sdk.zip; \
    google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components kubectl alpha beta; \
    google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true; \
    export PATH=/google-cloud-sdk/bin:$PATH; \
    gcloud --version;

ENV PATH=/google-cloud-sdk/bin:$PATH

## Install libvips requirement for Sharp (https://www.npmjs.com/package/sharp)
## See http://sharp.pixelplumbing.com/en/stable/install/#docker
## Shamelessly stolen from https://github.com/TailorBrands/docker-libvips

ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 6
ENV LIBVIPS_VERSION_PATCH 1
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  automake build-essential curl \
  cdbs debhelper dh-autoreconf flex bison \
  libjpeg-dev libtiff-dev libpng-dev libgif-dev librsvg2-dev libpoppler-glib-dev zlib1g-dev fftw3-dev liblcms2-dev \
  liblcms2-dev libmagickwand-dev libfreetype6-dev libpango1.0-dev libfontconfig1-dev libglib2.0-dev libice-dev \
  gettext pkg-config libxml-parser-perl libexif-gtk-dev liborc-0.4-dev libopenexr-dev libmatio-dev libxml2-dev \
  libcfitsio-dev libopenslide-dev libwebp-dev libgsf-1-dev libgirepository1.0-dev gtk-doc-tools; \

  # Build libvips
  cd /tmp && \
  curl -L -O https://github.com/jcupitt/libvips/releases/download/v$LIBVIPS_VERSION/vips-$LIBVIPS_VERSION.tar.gz && \
  tar zxvf vips-$LIBVIPS_VERSION.tar.gz && \
  cd /tmp/vips-$LIBVIPS_VERSION && \
  ./configure --enable-debug=no --without-python $1 && \
  make && \
  make install && \
  ldconfig;

## Revert to default user
USER circleci
