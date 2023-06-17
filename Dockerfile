# Dockerfile for Ansible and Terraform
# including sshpass
# based on itech/ansible package
FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y --no-install-recommends install \
               sshpass openssh-client rsync curl \
               wget unzip locales zile byobu git \
               build-essential \
               python3 python3-dev \
               python3-pip python3-venv python3-wheel python3-setuptools python3-psutil libssl-dev libffi-dev

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 2

RUN mkdir -p /etc/ansible/ && \
    echo '[local]\nlocalhost ansible_python_interpreter={{ansible_playbook_python}}\n' > /etc/ansible/hosts && \
    echo '[defaults]\ninterpreter_python=/usr/bin/python3' > /etc/ansible/ansible.cfg
RUN pip3 install ansible ansible[azure] azure-cli netaddr pexpect asciinema 

# Install Terraform
ENV TERRAFORM_VERSION 1.5.0

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform.zip -d /usr/local/bin \
  && rm -f terraform.zip

# Install Packer
ENV PACKER_VERSION 1.9.1

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
