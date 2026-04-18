FROM node:20-bookworm-slim

# Avoid running from /
WORKDIR /app

# use root to install needed packages
USER root

# Install necessary packages and set up environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        procps \
        curl \
        git \
        nano \
        tree \

        # tool for png --> webp image format
        webp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install cursor CLI
RUN curl https://cursor.com/install -fsS | bash

RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
RUN source ~/.bashrc

# Keep the container running while not
# binding its life cycle to the java app
CMD ["tail", "-f", "/dev/null"]

