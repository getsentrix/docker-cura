FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

LABEL maintainer="getsentrix"
LABEL org.opencontainers.image.source="https://github.com/getsentrix/docker-cura"

# Optimized defaults for Railway free tier
ENV TITLE=Cura \
    SELKIES_ENCODER="jpeg" \
    SELKIES_FRAMERATE="10-20" \
    SELKIES_JPEG_QUALITY="60" \
    SELKIES_MANUAL_WIDTH="1024" \
    SELKIES_MANUAL_HEIGHT="768"

# REMOVED 'epiphany-browser' from this list to save RAM
# KEPT 'thunar' for file management
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget gnupg dbus-x11 ca-certificates xz-utils thunar && \
    echo "**** install cura from appimage ****" && \
    CURA_VERSION=$(curl -sX GET "https://api.github.com/repos/Ultimaker/Cura/releases/latest" | awk -F'"' '/tag_name/{print $4;exit}') && \
    cd /tmp && \
    curl -L -o cura.app "https://github.com/Ultimaker/Cura/releases/download/${CURA_VERSION}/UltiMaker-Cura-$(echo ${CURA_VERSION} | awk -F'-' '{print $1}')-linux-X64.AppImage" && \
    chmod +x /tmp/cura.app && \
    /tmp/cura.app --appimage-extract && \
    mv squashfs-root /opt/cura && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /config/.cache

# Pre-configure Cura to disable crash reports, updates, notifications
RUN mkdir -p /config/.local/share/cura/5.0 && \
    echo '[cura]' > /config/.local/share/cura/5.0/cura.cfg && \
    echo 'analytics_enabled = False' >> /config/.local/share/cura/5.0/cura.cfg && \
    echo 'crash_reports_enabled = False' >> /config/.local/share/cura/5.0/cura.cfg && \
    echo 'update_notification_enabled = False' >> /config/.local/share/cura/5.0/cura.cfg && \
    echo 'check_for_updates = False' >> /config/.local/share/cura/5.0/cura.cfg

# Create uploads folder for file sharing
RUN mkdir -p /config/uploads

EXPOSE 3000
