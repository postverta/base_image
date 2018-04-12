FROM ubuntu:16.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git vim curl xz-utils jq zip lsof

# Workaround to get fuse installed
RUN apt-get -y install fuse  || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse

# Install global node & npm (node8 & npm5)
RUN curl -Lo node.tar.xz https://nodejs.org/dist/v8.1.4/node-v8.1.4-linux-x64.tar.xz && tar xf node.tar.xz -C /usr/local/ --strip-components=1 && rm node.tar.xz

# Install language server
RUN npm i -g javascript-typescript-langserver@2.5.4

# Copy task definitions
COPY task /etc/task/

# Copy process definitions
COPY process /etc/process/

# Copy scripts
COPY scripts /scripts/

RUN mkdir /app
RUN chmod 777 /app
RUN useradd -d /app dev
RUN chown dev:dev /app
RUN chown -R dev:dev /etc/task

# Fix global NPM access control (give all global NPM access to user dev)
RUN chown -R dev:dev /usr/local/lib/node_modules
RUN chown -R dev:dev /usr/local/bin
RUN chown -R dev:dev /usr/local/share

# Create the language server symlink
RUN ln -s /app/.pv/langserver /langserver
RUN chown -h dev:dev /langserver

# Set setuid for fsfreeze so that we can run it without sudo
RUN chmod 4755 /sbin/fsfreeze

USER dev

WORKDIR /app
