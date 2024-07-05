FROM alpine

# Build arguments
ARG android_ndk=false
ARG ndk_version=26.1.10909125
ARG gcloud=false
ARG gcloud_url=https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
ARG gcloud_home=/usr/local/gcloud
ARG gcloud_install_script=${gcloud_home}/google-cloud-sdk/install.sh
ARG gcloud_bin=${gcloud_home}/google-cloud-sdk/bin
ARG sdk_version=commandlinetools-linux-6200805_latest.zip
ARG android_home=/opt/android/sdk
ARG android_api=android-34
ARG android_build_tools=34.0.0
ARG cmake=3.22.1

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN apk update && apk add locales && \
    locale-gen en_US.UTF-8 || true
ENV LANG=en_US.UTF-8

# Install dependencies
RUN apk update && apk add \
  bash \
  git \
  wget \
  coreutils \
  zlib-dev \
  xxd  \
  jq  \
  npm \
  readline-dev \
  zip  \
  unzip \
  # Build compatibility for glibc which not part of Alpine
  gcompat  \
  make  \
  build-base \
  curl \
  # ruby-setup dependencies \
  ruby \
  ruby-dev \
  yaml-dev \
  gmp-dev \
  nodejs \
  file

# Add minimised JDK for build procedures
RUN echo "https://apk.bell-sw.com/main" | tee -a /etc/apk/repositories
RUN wget -P /etc/apk/keys/ https://apk.bell-sw.com/info@bell-sw.com-5fea454e.rsa.pub
RUN apk add bellsoft-java17-lite

# Clean dependencies
RUN apk cache clean --purge
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

# Set up bundler and gems
RUN gem install bundler:2.5.4
# Preinstall gems
ADD Gemfile /Gemfile
ADD Gemfile.lock /Gemfile.lock
RUN bundle install --jobs $(nproc)

# Install Google Cloud CLI
ENV PATH=${gcloud_bin}:${PATH}
RUN if [ "$gcloud" = true ] ; \
  then \
    echo "Installing GCloud SDK"; \
    apt-get update && apt-get install --no-install-recommends -y \
      gcc \
      python3 \
      python3-dev \
      python3-setuptools \
      python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${gcloud_home} && \
    wget --quiet --output-document=/tmp/gcloud-sdk.tar.gz ${gcloud_url} && \
    tar -C ${gcloud_home} -xvf /tmp/gcloud-sdk.tar.gz && \
    ${gcloud_install_script} && \
    pip3 uninstall crcmod && \
    pip3 install --no-cache-dir -U crcmod; \
  else \
    echo "Skipping GCloud SDK installation"; \
  fi

# Install Android SDK and NDK
RUN mkdir -p ${android_home} && \
    wget --quiet --output-document=/tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN sdkmanager --sdk_root=$ANDROID_HOME --install \
  "platform-tools" \
  "build-tools;${android_build_tools}" \
  "platforms;${android_api}"
RUN if [ "$android_ndk" = true ] ; \
  then \
    echo "Installing Android NDK ($ndk_version, cmake: $cmake)"; \
    sdkmanager --sdk_root="$ANDROID_HOME" --install \
    "ndk;${ndk_version}" \
    "cmake;${cmake}" ; \
  else \
    echo "Skipping NDK installation"; \
  fi
