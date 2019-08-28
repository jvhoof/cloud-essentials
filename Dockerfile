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

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

# Install Ansible, Azure CLI, asciinema
# Dropped support for AWS CLI (has a requirement for colorama version 0.3.7) and AWS doesn't seem to update to the latest version 0.4.1.
# https://github.com/aws/aws-cli/pull/2892
RUN mkdir -p /etc/ansible/ && \
    echo '[local]\nlocalhost ansible_python_interpreter={{ansible_playbook_python}}\n' > /etc/ansible/hosts && \
    echo '[defaults]\ninterpreter_python=/usr/bin/python3' > /etc/ansible/ansible.cfg
RUN pip3 install ansible fortiosapi ansible[azure] azure-cli netaddr pexpect asciinema

RUN mkdir -p /opt/ansible/modules && \
    cd /opt/ansible/modules && \
    git clone https://github.com/networktocode/fortimanager-ansible.git && \
    git clone https://github.com/fortinet-solutions-cse/ansible_fgt_modules.git && \
    cd /opt/ansible/modules/fortimanager-ansible && \
    echo 'library        = /opt/ansible/modules/' >> /etc/ansible/ansible.cfg && \
    pip3 install -r requirements.txt && \
    cd /tmp && \
    git clone https://github.com/jvhoof/cloud-essentials.git && \
    cd /opt/ansible/modules/fortimanager-ansible && \
    # Patch as return_values function was removed from Ansible. Diff from PR
    # https://github.com/networktocode/fortimanager-ansible/pull/70/files
#    patch -s -p0 < /tmp/cloud-essentials/patch/70.patch && \
    # Patch to support v3 of the API for FortiManager
#    patch -s -p0 < /tmp/cloud-essentials/patch/71.patch && \
    # Clean up of patches
    rm -rf /tmp/cloud-essentials

# Install Terraform
ENV TERRAFORM_VERSION 0.12.7

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform.zip -d /usr/local/bin \
  && rm -f terraform.zip

# Install Packer
ENV PACKER_VERSION 1.4.2

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
