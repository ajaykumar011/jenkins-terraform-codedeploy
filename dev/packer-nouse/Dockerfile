FROM amazonlinux:2

# Install Python and Ansible
ENV ANSIBLE_VERSION=2.7.10
LABEL ansible_version=${ANSIBLE_VERSION}

RUN yum -y install python3

RUN pip3 install -q ansible==${ANSIBLE_VERSION} 

#Install Packer
ENV PACKER_VERSION=1.3.5
LABEL packer_version=${PACKER_VERSION}

RUN yum -y install openssh git wget openssl unzip

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin

RUN rm -rf packer_${PACKER_VERSION}_linux_amd64.zip


# ENV PACKER_TEMPLATE=template-docker.json
# COPY $PACKER_TEMPLATE /usr/local/share/packer/template-docker.json

# VOLUME /opt
# WORKDIR /usr/local/share/packer/

