FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install 32-bit architecture support and required libraries
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        libc6:i386 \
        libxext6:i386 \
        libxrender1:i386 \
        libxtst6:i386 \
        libxi6:i386 \
        libxt6:i386 \
        libstdc++6:i386 \
        libx11-6:i386 \
        libice6:i386 \
        libsm6:i386 \
        libnsl-dev:i386 \
        libbsd0:i386 \
        wget \
        unzip \
        tar \
        make \
        && \
    rm -rf /var/lib/apt/lists/*

# Set up J2ME directory
WORKDIR /opt/j2me

# Download and install 32-bit JDK 8
RUN wget -q "https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-i586.tar.gz" && \
    tar -xzf jdk-8u202-linux-i586.tar.gz && \
    rm jdk-8u202-linux-i586.tar.gz

# Download and extract Sun Java Wireless Toolkit 2.5.2
# The file is a self-extracting shell script with a ZIP payload
RUN wget -q --no-cookies --no-check-certificate \
        --header "Cookie: oraclelicense=accept-securebackup-cookie" \
        "https://download.oracle.com/otn-pub/java/sun_java_wireless_toolkit/2.5.2_01/sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh" && \
    tail -c +26625 sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh > wtk.zip && \
    unzip -q wtk.zip -d wtk/ && \
    rm sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh wtk.zip

# Set environment variables
ENV JAVA_HOME=/opt/j2me/jdk1.8.0_202
ENV WTK_HOME=/opt/j2me/wtk
ENV PATH="${JAVA_HOME}/bin:${WTK_HOME}/bin:${PATH}"

# Create a build script for J2ME projects
RUN echo '#!/bin/bash\n\
if [ -f "build.xml" ]; then\n\
    ant -Dsdk.home="${WTK_HOME}" -Djava.home="${JAVA_HOME}" "$@"\n\
else\n\
    echo "No build.xml found. Please provide a build script or use the WTK tools directly."\n\
    echo "Available tools:"\n\
    echo "  preverify - Preverify classes for J2ME"\n\
    echo "  jar - Create JAR files"\n\
    echo "  javac - Compile Java sources"\n\
fi' > /usr/local/bin/j2me-build && \
    chmod +x /usr/local/bin/j2me-build

# Default working directory for projects
WORKDIR /workspace

# Verify installation
RUN java -version && \
    echo "J2ME SDK installed at: ${WTK_HOME}" && \
    ls -la ${WTK_HOME}/bin/

CMD ["/bin/bash"]
