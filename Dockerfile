FROM php:7.0.8-cli

# Install requirements for standard builds.
RUN echo "deb http://http.us.debian.org/debian/ testing non-free contrib main" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
      curl \
      apt-transport-https \
      ca-certificates \
      wget \
      openssh-client \
      bzip2 \
      git \
      libmcrypt-dev \
      libicu-dev \
      python-yaml \
      python-jinja2 \
      python-httplib2 \
      python-keyczar \
      python-paramiko \
      python-setuptools \
      python-pkg-resources \
      python-pip \

  # Standard cleanup.
  && update-ca-certificates \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

# Install common PHP packages.
RUN docker-php-ext-install \
      mcrypt \
      mbstring \
      bcmath \
      intl

# Setup Ansible
RUN mkdir /etc/ansible/ \
    && echo '[local]\nlocalhost\n' > /etc/ansible/hosts \
    && mkdir /opt/ansible/ \
    && git clone http://github.com/ansible/ansible.git /opt/ansible/ansible \
    && git submodule update --init

# Composer installation.
RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/bin/composer \

  # Standard cleanup.
  && update-ca-certificates \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup WP-CLI
RUN curl -o https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install Node 7
RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - \
    && apt-get install -y nodejs \
    build-essential

# Add fingerprints for common sites.
RUN mkdir ~/.ssh \
  && ssh-keyscan -H github.com >> ~/.ssh/known_hosts \
  && ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts

# Show versions
RUN php -v
RUN node -v
RUN npm -v
