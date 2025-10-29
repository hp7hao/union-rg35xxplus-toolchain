FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Debian Buster is archived, use archive.debian.org
RUN echo "deb http://archive.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get -y update && apt-get -y install \
	automake \
	autoconf \
	bc \
	bison \
    build-essential \
    bzip2 \
	bzr \
	cmake \
	cmake-curses-gui \
	cpio \
	curl \
	device-tree-compiler \
	flex \
	gettext \
	git \
	imagemagick \
	libncurses5-dev \
	libtool \
	locales \
	make \
	ninja-build \
	p7zip-full \
	pkg-config \
	python3 \
	python3-pip \
	rsync \
	sharutils \
	scons \
	tree \
	unzip \
	vim \
	wget \
	zip \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

COPY support .
RUN ./build-toolchain.sh
RUN ./add-sysroot.sh
RUN cat ./setup-env.sh >> .bashrc

# Install Meson 0.61+ (required for DirectFB2)
RUN wget -qO /tmp/meson.tar.gz https://github.com/mesonbuild/meson/releases/download/0.61.4/meson-0.61.4.tar.gz && \
    mkdir -p /opt/meson && \
    tar xf /tmp/meson.tar.gz --strip-components=1 -C /opt/meson && \
    mv /opt/meson/meson.py /opt/meson/meson && \
    chmod +x /opt/meson/meson && \
    rm /tmp/meson.tar.gz

ENV PATH="/opt/meson:${PATH}"

VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]