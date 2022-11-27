FROM docker.io/archlinux:latest
#RUN pacman --sync --refresh --noconfirm mkinitcpio
#RUN sed -i 's/autodetect //' /etc/mkinitcpio.conf
#RUN pacman --sync --noconfirm base linux linux-firmware

RUN pacman --sync --refresh --noconfirm xorg xorg-server xorg-xinit
RUN pacman --sync --noconfirm xterm xorg-xclock xorg-twm
RUN pacman --sync --noconfirm glxgears

COPY config/Xwrapper.config /etc/X11/Xwrapper.config
COPY config/x11-autologin.service /etc/systemd/system/x11-autologin.service

RUN systemctl enable x11-autologin.service

COPY config/install.conf /etc/systemd/system/systemd-firstboot.service.d/install.conf
COPY config/10-login.conf /etc/systemd/logind.conf.d/10-login.conf
COPY config/20-wired.network /etc/systemd/network/20-wired.network

RUN systemctl mask getty@tty1.service
RUN systemctl enable getty@tty2.service

RUN echo "root:root" | chpasswd

RUN groupadd user && \
    useradd --create-home --gid user --shell /bin/bash --password user user && \
    usermod --gid user user && \
    echo "user:user" | chpasswd

#RUN chown --recursive user:user /tmp/.X11-unix
WORKDIR /tmp/.X11-unix/
RUN chown --recursive user:user .
USER user
WORKDIR /home/user/
RUN touch .Xauthority

#file /home/user/.Xauthority does not exist