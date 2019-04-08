FROM    centos:7.2.1511

# Remove all repositories
RUN     rm /etc/yum.repos.d/*

# Add only the specific CentOS 7.2 repositories, because that's what XS used for the majority of packages
COPY    files/CentOS-Vault-7.2.repo /etc/yum.repos.d/

# Add our repositories
# Repository file depends on the target version of XCP-ng, and is pre-processed by build.sh
COPY    files/tmp-xcp-ng.repo /etc/yum.repos.d/xcp-ng.repo

# Fix invalid rpmdb checksum error with overlayfs, see https://github.com/docker/docker/issues/10180
RUN     yum install -y yum-plugin-ovl

# Use priorities so that packages from our repositories are preferred over those from CentOS repositories
RUN     yum install -y yum-plugin-priorities

# Update
RUN     yum update -y

# Build requirements
RUN     yum install -y --exclude=gcc-xs \
            gcc \
            gcc-c++ \
            genisoimage \
            git \
            git-lfs \
            make \
            mercurial \
            mock \
            rpm-build \
            rpm-python \
            sudo \
            syslinux \
            yum-utils \
            epel-release

# Niceties
RUN     yum install -y \
            vim \
            wget \
            which

# OCaml in XS is slightly older than in CentOS
RUN     sed -i "/gpgkey/a exclude=ocaml*" /etc/yum.repos.d/Cent* /etc/yum.repos.d/epel*

# Set up the builder user
RUN     useradd builder \
        && echo "builder:builder" | chpasswd \
        && echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
        && usermod -G mock builder

RUN     mkdir -p /usr/local/bin
COPY    files/init-container.sh /usr/local/bin/init-container.sh
COPY    files/rpmmacros /home/builder/.rpmmacros
