# [Choice] PHP version (use -bullseye variants on local arm64/Apple Silicon): 8-bullseye, 8.1-bullseye, 8.0-bullseye, 7-bullseye, 7.4-bullseye, 8-buster, 8.1-buster, 8.0-buster, 7-buster, 7.4-buster
ARG VARIANT=8.1-cli-bullseye
FROM php:${VARIANT}

LABEL org.opencontainers.image.source="https://github.com/rjocoleman/php-cli-devcontainer.io"

# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get -y install --no-install-recommends lynx \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install xdebug
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode = debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request = default" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port = 9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && rm -rf /tmp/pear

# Install composer
RUN curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="16"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
RUN bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Remove library scripts for final image
RUN rm -rf /tmp/library-scripts

# Add Redis CLI
COPY --from=redis:6-bullseye /usr/local/bin/redis-cli /usr/local/bin/redis-cli

# Add SQL clients
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends default-mysql-client postgresql-client libpq-dev

# Add MySQL and Postgres support to PHP
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql && docker-php-ext-enable pdo_mysql pdo_pgsql

# Install shdotenv to use .env in post create scripts
RUN curl -sfL https://github.com/ko1nksm/shdotenv/releases/latest/download/shdotenv | install /dev/stdin /usr/local/bin/shdotenv

# Install dockerize
RUN curl -sfL $(curl -s https://api.github.com/repos/powerman/dockerize/releases/latest | grep -i /dockerize-$(uname -s)-$(uname -m)\" | cut -d\" -f4) | install /dev/stdin /usr/local/bin/dockerize

# Stop the container from terminating (needed for vscode as we don't have apache or something like that running)
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

# [Optional] Enable xdebug start_with_request
# RUN sed -i "s|xdebug.start_with_request = no|xdebug.start_with_request = yes|g" /usr/local/etc/php/conf.d/xdebug.ini

# [Optional] Add PHP extensions
# RUN docker-php-ext-install <your-extension-list-here> && docker-php-ext-enable <your-extension-list-here>
