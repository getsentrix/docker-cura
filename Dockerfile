FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

LABEL maintainer="getsentrix"
LABEL org.opencontainers.image.source="https://github.com/getsentrix/docker-cura"

ENV TITLE=Cura

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget gnupg dbus-x11 ca-certificates xz-utils epiphany-browser && \
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
    echo 'update_notification_enabled = False' >> /config/.local/share/cura/5.0/cura.cfg
# Create desktop file for Cura
RUN mkdir -p /usr/share/applications && \
    echo '[Desktop Entry]' > /usr/share/applications/cura.desktop && \
    echo 'Type=Application' >> /usr/share/applications/cura.desktop && \
    echo 'Name=Cura' >> /usr/share/applications/cura.desktop && \
    echo 'Exec=/opt/cura/AppRun' >> /usr/share/applications/cura.desktop && \
    echo 'Icon=cura' >> /usr/share/applications/cura.desktop && \
    echo 'Categories=3DGraphics' >> /usr/share/applications/cura.desktop && \
    chmod +x /usr/share/applications/cura.desktop

EXPOSE 3000
