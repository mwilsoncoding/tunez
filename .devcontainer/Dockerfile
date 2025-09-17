ARG ELIXIR_VERSION
ARG OTP_VERSION
ARG DEBIAN_VERSION
ARG LEFTHOOK_VERSION
ARG YAMLFMT_VERSION
ARG WATCHMAN_VERSION
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      inotify-tools \
      jq \
      unzip \
      libwxgtk-gl3.2-1 \
      postgresql-client \
      shellcheck \
      sudo \
      2>&1

RUN if id -u ${USERNAME} > /dev/null 2>&1 ; then \
      if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then \
         group_name="$(id -gn $USERNAME)" \
         && groupmod --gid $USER_GID ${group_name} \
         && usermod --gid $USER_GID $USERNAME ; \
      fi ; \
      if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then \
         usermod --uid $USER_UID $USERNAME ; \
      fi ; \
    else \
      if [ "${USER_GID}" = "automatic" ]; then \
        groupadd $USERNAME ; \
      else \
        groupadd --gid $USER_GID $USERNAME ; \
      fi ; \
      if [ "${USER_UID}" = "automatic" ]; then \
        useradd -s /bin/bash --gid $USERNAME -m $USERNAME ; \
      else \
        useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME ; \
      fi ; \
    fi

RUN if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then \
      echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
      && chmod 0440 /etc/sudoers.d/$USERNAME \
      && EXISTING_NON_ROOT_USER="${USERNAME}" ; \
    fi

ARG LEFTHOOK_VERSION
RUN curl -sfL https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_Linux_x86_64.gz | gunzip >/usr/local/bin/lefthook && \
    chmod +x /usr/local/bin/lefthook

ARG YAMLFMT_VERSION
RUN curl -L https://github.com/google/yamlfmt/releases/download/v${YAMLFMT_VERSION}/yamlfmt_${YAMLFMT_VERSION}_Linux_x86_64.tar.gz | tar -C /usr/local/bin -xzf - yamlfmt

ARG WATCHMAN_VERSION
RUN mkdir -p /tmp/watchman /usr/local/{bin,lib} /usr/local/var/run/watchman && \
    curl -L https://github.com/facebook/watchman/releases/download/v${WATCHMAN_VERSION}/watchman-v${WATCHMAN_VERSION}-linux.zip -o /tmp/watchman.zip && \
    unzip /tmp/watchman.zip -d /tmp/watchman && \
    cp /tmp/watchman/watchman-v${WATCHMAN_VERSION}-linux/bin/* /usr/local/bin/ && \
    cp /tmp/watchman/watchman-v${WATCHMAN_VERSION}-linux/lib/* /usr/local/lib/ && \
    rm /usr/local/lib/liblzma.so.5 && \
    ln -s /usr/lib/x86_64-linux-gnu/liblzma.so.5 /usr/local/lib/liblzma.so.5 && \
    chmod 755 /usr/local/bin/watchman && \
    chmod 2777 /usr/local/var/run/watchman && \
    rm -rf /tmp/watchman

# RUN curl -L https://github.com/elixir-lang/expert/releases/download/nightly/expert_linux_amd64 -o /usr/local/bin/expert && \
#     chmod +x /usr/local/bin/expert

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
