# PHP CLI Devcontainer

Based on https://github.com/microsoft/vscode-dev-containers/tree/main/containers/php

My use case is Laravel projects using `php artisan serve` and PHP built-in webserver rather than more complicated Apache / supervisord containers.
Designed to be a drop-in replacement for Microsoft devcontainer base images - and seperate containers for databases (etc).

## Image:

Image `ghcr.io/rjocoleman/php-cli-devcontainer` hosted on GitHub Container Registry. Should be available in linux/amd64, linux/arm/v7 and linux/arm64 variants.


### Features:

* PHP 8.1 CLI (no Apache).
* Tries to stay as close to Microsoft devcontainer as much as possible i.e. includes `vscode` user etc.
* Adds php-pdo, php-pdo_mysql and pdo_pgsql.
* Adds postgres-client and mysql-client.
* Adds Node version 16 by default (can be customised or removed - see below), for Laravel Mix.
* Uses port `9003` for Xdebug, and sets `xdebug.start_with_request` to [default](https://xdebug.org/docs/all_settings#start_with_request).
* Sets default Xdebug `client_host` to `host.docker.internal` (override with [`XDEBUG_CONFIG`](https://xdebug.org/docs/all_settings#XDEBUG_CONFIG) env).
* Adds [dockerize](https://github.com/powerman/dockerize) and [shdotenv](https://github.com/ko1nksm/shdotenv/) for use in postCreateCommand e.g. waiting for a DB to be in a ready state before running migrations and loading .env variables into postCreateCommand. These are just installed but do not do anything by default.
* Adds Redis CLI.
* `CMD` is set to `sleep infinity` to prevent the container from prematurely terminating (needed by vscode).
* Based on Debian Bullseye and should support both x86_64/amd64 and aarch64/arm64.


### Example usage:

* `devcontainer.json` as `"image": "ghcr.io/rjocoleman/php-cli-devcontainer"`
* `docker-compose.yml` as `image: ghcr.io/rjocoleman/php-cli-devcontainer`

Or, if you need to customise it use it as a base in a `Dockerfile`:

```Dockerfile
FROM ghcr.io/rjocoleman/php-cli-devcontainer

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

# [Optional] Enable xdebug start_with_request
# RUN sed -i "s|xdebug.start_with_request = no|xdebug.start_with_request = yes|g" /usr/local/etc/php/conf.d/xdebug.ini

# [Optional] Add PHP extensions
# RUN docker-php-ext-install <your-extension-list-here> && docker-php-ext-enable <your-extension-list-here>
```


### Customising Node.js version

Given JavaScript front-end web client code written for use in conjunction with a PHP back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.
You must use the custom `Dockerfile` approach above to build this, Node 14 is included by default.

```jsonc
"args": {
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```


### Credits

This is mostly just Microsoft's excellent devcontainer image with a couple of things removed and a couple of things added.


### Disclaimer

This is built and published so that I can use it across multiple projects without needing to build each time. I make no commitments that I'll add features, maintain compatibility, incorperate any future changes from the base Microsoft devcontainers, publish new updates or in any way maintain this - but I might (no promises).
