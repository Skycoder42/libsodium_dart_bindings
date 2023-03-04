FROM mcr.microsoft.com/vscode/devcontainers/base:latest

RUN sudo apt-get -y update &&\
    sudo apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev chromium lcov libsodium-dev &&\
    chmod a+rwxt /opt

COPY on-post-create.sh /usr/local/bin/on-post-create.sh
COPY google-chrome.sh /usr/bin/google-chrome
ENV PUB_CACHE=/opt/pub-cache
ENV CHROME_EXECUTABLE="chromium --no-sandbox"
