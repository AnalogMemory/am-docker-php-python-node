FROM php:7.0-cli

# Install requirements for standard builds.
RUN echo "deb http://http.us.debian.org/debian/ testing non-free contrib main" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      apt-transport-https \
      ca-certificates \
      wget \
      openssh-client \
      bzip2 \
      git \
      libmcrypt-dev \
      libicu-dev \
      libpng-dev \
      python-yaml \
      python-jinja2 \
      python-httplib2 \
      python-keyczar \
      python-paramiko \
      python-setuptools \
      python-pkg-resources \
      python-pip \

  # Standard cleanup
  && apt-get autoremove -y \
  && update-ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install common PHP packages.
RUN docker-php-ext-install \
      mcrypt \
      mbstring \
      bcmath \
      intl

# Setup Ansible
RUN mkdir -p /etc/ansible/ \
    && echo '[local]\nlocalhost\n' > /etc/ansible/hosts \
    && pip install ansible

# Composer installation.
RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/bin/composer

# Setup WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install Node (Latest)
RUN cd /tmp && \
    wget http://nodejs.org/dist/node-latest.tar.gz && \
    tar xvzf node-latest.tar.gz && \
    rm -f node-latest.tar.gz && \
    cd node-v* && \
    ./configure && \
    CXX="g++ -Wno-unused-local-typedefs" make && \
    CXX="g++ -Wno-unused-local-typedefs" make install && \
    cd /tmp && \
    rm -rf /tmp/node-v* && \
    npm install -g npm && \
    echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

# Add fingerprints for common sites.
RUN mkdir ~/.ssh \
  && ssh-keyscan -H github.com >> ~/.ssh/known_hosts \
  && ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

# Show versions
RUN php -v
RUN node -v
RUN npm -v

CMD ["bash"]
