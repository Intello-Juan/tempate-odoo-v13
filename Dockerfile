FROM ubuntu:bionic

# Generate locale C.UTF-8
ENV LANG C.UTF-8

# Install dependencies.
RUN set -x; \
      apt-get update \
      && apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        gcc \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libldap2-dev \
        libsasl2-dev; \
    pip3 install \
      setuptools \
      wheel

# Set Odoo instance directory layout
RUN useradd -m -U -r odoo \
    && mkdir -p \
      /home/odoo/odoo-dev/src \
      /home/odoo/odoo-dev/addons \
      /home/odoo/odoo-dev/bin \
      /home/odoo/odoo-dev/filestore \
      /home/odoo/odoo-dev/config \
    && chown -R odoo /home/odoo/odoo-dev

# Install Odoo
COPY ./src /home/odoo/odoo-dev/src
RUN pip3 install -e /home/odoo/odoo-dev/src \
    && pip3 install num2words watchdog

# Setup entrypoint
COPY ./entrypoint.sh /home/odoo/odoo-dev/bin
RUN chown odoo /home/odoo/odoo-dev/bin/entrypoint.sh \
    && chmod u+x /home/odoo/odoo-dev/bin/entrypoint.sh

# Setup Odoo configuration file
COPY ./config/odoo.conf /home/odoo/odoo-dev/config
RUN chown odoo /home/odoo/odoo-dev/config/odoo.conf
ENV ODOO_RC /home/odoo/odoo-dev/config/odoo.conf

# Set default user
USER odoo

# Set default command
ENTRYPOINT ["/home/odoo/odoo-dev/bin/entrypoint.sh"]
CMD ["odoo"]
