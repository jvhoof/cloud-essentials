# Dockerfile for Ansible and Terraform
# including sshpass
# based on itech/ansible package
FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y --no-install-recommends install python-yaml \
               python-jinja2 python-httplib2 python-keyczar \
               python-paramiko python-setuptools python-mysqldb \
               python-pkg-resources git python-pip sshpass \
               openssh-client rsync curl wget unzip locales \
               python-wheel python-pathlib2 graphviz

# Install Ansible
RUN mkdir -p /etc/ansible/ \
    && echo '[local]\nlocalhost\n' > /etc/ansible/hosts \
    && pip install ansible 

# Install packaging for ARM Template deployments via Ansible
RUN pip install packaging

# Install Azure SDK for Python, Azure CLI 2.0 and AWS CLI
RUN pip install --pre azure azure-cli awscli

# Install Terraform
ENV TERRAFORM_VERSION 0.11.10

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform.zip -d /usr/local/bin \
  && rm -f terraform.zip

# Install Packer
ENV PACKER_VERSION 1.3.2

RUN wget -O packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip packer.zip -d /usr/local/bin \
  && rm -f packer.zip

# Debian maintenance
RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8

# clean packages
RUN apt-get clean \ 
    && apt-get purge --auto-remove -y python2.6 python2.6-minimal \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
