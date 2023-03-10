FROM skycoder42/devcontainers-flutter:latest

RUN sudo apt-get -y update &&\
    sudo apt-get -y upgrade &&\
    sudo apt-get -y install libsodium-dev p7zip-full &&\
    curl -fLo /tmp/minisign.tar.gz 'https://github.com/jedisct1/minisign/releases/download/0.11/minisign-0.11-linux.tar.gz' &&\
    tar -xzvf /tmp/minisign.tar.gz -C /tmp &&\
    sudo mv /tmp/minisign-linux/x86_64/minisign /usr/local/bin
