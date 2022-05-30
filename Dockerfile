# syntax=docker/dockerfile:1.4
FROM fedora:rawhide as Build

RUN dnf -y update && dnf clean all

### SYSTEMD ###
RUN dnf -y install systemd && dnf clean all && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

### LIBVIRT ###
RUN dnf -y install \
    libvirt \
    qemu \
    qemu-kvm \
    virt-install \
    python3-gobject \
    jq \
    && dnf clean all

# Enable libvirtd and virtlockd services.
RUN systemctl enable libvirtd
RUN systemctl enable virtlockd

# Add configuration for "default" storage pool.
RUN mkdir -p /etc/libvirt/storage
COPY pool-default.xml /etc/libvirt/storage/default.xml

### IMAGEFACTORY ###
RUN dnf install -by imagefactory \
    imagefactory-plugins-TinMan \
    imagefactory-plugins-Docker \
    imagefactory-plugins \
    pykickstart && \
    sed -i 's/# memory = 1024/memory = 2048/g' /etc/oz/oz.cfg

# The entrypoint.sh script runs before services start up to ensure that
# critical directories and permissions are correct.
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/init"]
