# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/base-main:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
     for copr in \
        ublue-os/staging \
        ublue-os/packages; \
    do \
    dnf -y install dnf5-plugins && \
    dnf -y copr enable $copr; \
    done && unset -v copr && \
    dnf -y install @xfce-desktop-environment && \
    dnf -y install lightdm lightdm-gtk-greeter gdk-pixbuf2-modules-extra ublue-brew ublue-fastfetch ublue-os-udev-rules ublue-os-update-services ublue-os-signing ublue-os-luks ublue-os-just && \
    /ctx/build.sh && \
    systemctl enable lightdm && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
