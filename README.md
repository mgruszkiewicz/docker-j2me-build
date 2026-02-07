# J2ME Build Docker Container

This Docker container provides all the tools needed to build J2ME (Java 2 Micro Edition) applications on modern Linux systems.

## What's Included

- **32-bit JDK 8** (jdk-8u202-linux-i586) - Required by the Wireless Toolkit
- **Sun Java Wireless Toolkit 2.5.2** - The official J2ME SDK
- **32-bit libraries** - Required for running the 32-bit toolchain on 64-bit systems

## Building the Container

```bash
docker build -t j2me-build .
```

## Usage

### Build a J2ME Project

Mount your project directory and build:

```bash
docker run --rm -v "$(pwd):/workspace" j2me-build j2me-build
```

### Interactive Shell

Access the container interactively to run WTK tools manually:

```bash
docker run --rm -it -v "$(pwd):/workspace" j2me-build bash
```

### Using WTK Tools Directly

Once inside the container, you can use WTK tools:

```bash
# Preverify classes
preverify -classpath ${WTK_HOME}/lib/midpapi20.jar:${WTK_HOME}/lib/cldcapi11.jar -d ./output ./classes

# Create JAD and JAR files
# (Use your own build scripts or ant with the WTK)
```

## Environment Variables

- `JAVA_HOME` - Points to the 32-bit JDK 8 installation
- `WTK_HOME` - Points to the Sun Java Wireless Toolkit installation
- `PATH` - Includes both JDK and WTK binaries

## Example Project Structure

Your project should be mounted at `/workspace`. A typical J2ME project:

```
project/
├── src/
│   └── com/
│       └── example/
│           └── MyMIDlet.java
├── build.xml          # Ant build file (optional)
└── manifest.mf        # JAR manifest
```

## ARM64 Support (Apple Silicon, ARM Servers)

The J2ME toolchain (32-bit JDK and Sun Wireless Toolkit) is x86/x86_64 only. To run this container on ARM64 hosts (Apple Silicon Macs, Linux ARM servers), you need to use x86 emulation. When using Docker Desktop/orbstack it should contain qemu emulation by default. Simply add the `--platform` flag:

```bash
# Build the image with platform specification
docker build --platform linux/amd64 -t j2me-build .

# Run the container with platform specification
docker run --rm --platform linux/amd64 -v "$(pwd):/workspace" j2me-build make
```

## Notes

- This container is for **building only** - no emulator is included
- The 32-bit toolchain requires i386 architecture support
- All WTK binaries are available in the PATH
