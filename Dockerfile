FROM hypriot/rpi-alpine-scratch
MAINTAINER Gabriel Sentucq <perso@kazhord.fr>

# Download latest node release
ADD https://nodejs.org/dist/node-latest.tar.gz /tmp/node-latest.tar.gz

# Install dependencies and build
RUN apk add --update bash libgcc libstdc++ openssl ca-certificates git curl bzip2 tar make gcc clang g++ python linux-headers paxctl binutils-gold autoconf bison zlib-dev openssl-dev \ 
    && mkdir -p /usr/src/node \
    && tar -xzf /tmp/node-latest.tar.gz --strip-components=1 -C /usr/src/node \
    && cd /usr/src/node \
    && export GYP_DEFINES="linux_use_gold_flags=0" \
    && ./configure --prefix=/usr/local "--shared-openssl" \
    && make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && make install \
    && paxctl -cm /usr/local/bin/node \
    && cd / \
    && if [ -x /usr/bin/npm ]; then \
      npm install -g npm@latest \
      && find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
    fi \
    && apk del git curl bzip2 tar make gcc clang g++ python linux-headers paxctl binutils-gold autoconf bison zlib-dev openssl-dev \
    && rm -rf \
        /usr/src/node \
        /etc/ssl \
        /usr/local/include \
        /usr/local/share/man \
        /tmp/* \
        /var/cache/apk/* \
        /root/.npm \
        /root/.node-gyp \
        /root/.gnupg \
        /usr/local/lib/node_modules/npm/man \
        /usr/local/lib/node_modules/npm/doc \
        /usr/local/lib/node_modules/npm/html \
    && mkdir -p /app \
    && exit 0 || exit 1;
