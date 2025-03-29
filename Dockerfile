FROM debian:stable-slim

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -y curl sudo git make build-essential perl

ARG USER_NAME=user
ARG GROUP_NAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $GROUP_NAME && \
    useradd -l -u $UID -m -g $GID -G sudo -s /bin/bash $USER_NAME && \
    echo "$USER_NAME    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USER_NAME
WORKDIR /home/$USER_NAME/

# Theos 설치
RUN bash -c "yes y | $(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

ENV THEOS /home/$USER_NAME/theos
ENV PATH $PATH:$THEOS/bin

# # iOS SDK 설치 (추가)
# RUN mkdir -p "$THEOS/sdks" && \
#     curl -LO https://github.com/theos/sdks/archive/master.zip && \
#     unzip master.zip && \
#     mv sdks-master/*.sdk "$THEOS/sdks/" && \
#     rm -rf master.zip sdks-master

# AltList 설치 및 Makefile 복사
RUN git clone --recurse-submodules https://github.com/opa334/AltList.git
COPY --chown=$USER_NAME:$GROUP_NAME lib/AltList/Makefile AltList/
RUN (cd AltList && ./install_to_theos.sh && cd .. && rm -rf AltList)

# XPC 헤더 복사 (mac-headers)
RUN git clone --recurse-submodules https://github.com/realthunder/mac-headers.git && \
    mkdir -p "$THEOS/include/xpc" && \
    cp -r mac-headers/usr/include/xpc/* "$THEOS/include/xpc/" && \
    rm -rf mac-headers

# libSandy 설치 및 Makefile 복사
RUN git clone --recurse-submodules https://github.com/opa334/libSandy.git
COPY --chown=$USER_NAME:$GROUP_NAME lib/libSandy/Makefile libSandy/
RUN (cd libSandy && ./install_to_theos.sh && cd .. && rm -rf libSandy)

# 환경 설정
RUN echo 'alias theos="$THEOS/bin/nic.pl"' >> ~/.bashrc && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*
