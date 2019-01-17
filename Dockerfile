FROM centos:7
#Derived from official TeamCity image
LABEL modified "Alexis Jeandet <alexis.jeandet@member.fsf.org>"

RUN yum install -y centos-release-scl wget git freetype libpng fontconfig \
                   libX11 mesa-libGL mesa-libEGL-devel mesa-libGL-devel \
                   mesa-libGLU-devel mesa-libGLw-devel cups-libs mariadb-libs \
                   postgresql-libs file

RUN yum install -y devtoolset-7-gcc \
                   devtoolset-7-gcc-c++ \
                   rh-python36-python-devel \
                   rh-python36-python-pip

ADD https://raw.githubusercontent.com/Slicer/SlicerBuildEnvironment/master/Docker/qt5-centos7/qt-installer-noninteractive.qs /

RUN curl -LO http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run && \
    chmod u+x qt-unified-linux-x64-online.run && \
  ./qt-unified-linux-x64-online.run --verbose --platform minimal --script ./qt-installer-noninteractive.qs && \
  rm -f qt-installer-noninteractive.qs qt-unified-linux-x64-online.run && rm -rf /opt/qt/Docs /opt/qt/Examples /opt/qt/Tools 

RUN source /opt/rh/devtoolset-7/enable && source /opt/rh/rh-python36/enable && pip3 install --user meson ninja
RUN wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage && \
    chmod +x  linuxdeployqt-continuous-x86_64.AppImage && ./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract && \
    ln -s /squashfs-root/AppRun /usr/bin/linuxdeployqt 

ENV PKG_CONFIG_PATH="/opt/qt/5.11.2/gcc_64/lib/pkgconfig:/opt/rh/rh-python36/root/lib64/pkgconfig"
ENV PATH="/root/.local/bin:/opt/qt/5.11.2/gcc_64/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]