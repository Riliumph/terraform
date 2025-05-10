FROM mcr.microsoft.com/devcontainers/base:debian

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "INSTALL terraform"
RUN apt-get update -qq\
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends -y\
    wget\
    curl\
    gnupg\
    software-properties-common\
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

ARG HASHICORP_KEYRING_PATH=/usr/share/keyrings/hashicorp-archive-keyring.gpg
ARG HASHICORP_APT_URL=https://apt.releases.hashicorp.com
RUN curl -sSL "${HASHICORP_APT_URL}/gpg" | gpg --dearmor > "${HASHICORP_KEYRING_PATH}"\
    && VERSION_CODENAME=$(. /etc/os-release && echo "${VERSION_CODENAME}")\
    && echo "deb [signed-by=${HASHICORP_KEYRING_PATH}] ${HASHICORP_APT_URL} ${VERSION_CODENAME} main" > \
    /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update -qq\
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends -y\
    terraform


RUN echo "INSTALL UTIL"
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install --no-install-recommends -y\
    ## util
    ca-certificates libssl-dev\
    locales\
    less\
    silversearcher-ag\
    peco\
    git\
    vim\
    ## network tools
    lsof\
    dnsutils\
    iproute2\
    iputils-ping\
    traceroute\
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

# hadolint for docker
ARG HADOLINT_URL
RUN wget -q -O /usr/local/bin/hadolint ${HADOLINT_URL} --no-check-certificate\
    && chmod +x /usr/local/bin/hadolint

# git
WORKDIR /usr/share/doc/git/contrib/diff-highlight
RUN make all && \
    cp diff-highlight /usr/local/bin

# terraform auto complete
USER vscode
WORKDIR /home/vscode
RUN terraform -install-autocomplete

