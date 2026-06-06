# Minimal Minecraft Server

This is a minimal-dependency Minecraft server run as a rootless quadlet
container, with automatic updates.

By default, creates a data folder for persistent server data. Listens on default
ports.

## Usage

Create a non-root user to run the container as, and enable linger

  sudo addgroup -S <group>
  sudo adduser -S <user> -G <group>
  sudo loginctl enable-linger <user>

As the new user, clone this repo, run ./install.sh

  git clone https://github.com/zandeez/minecraft-rootless-quadlet.git
  cd minecraft-rootless-quadlet
  ./install.sh

Start the server

  systemctl --user start minecraft_server

If needed, allow port 25565 in your firewall, and 25575 if you need rcon.

## How it works

### entrypoint.sh

The main container entrypoint script. Simple starts the minecraft server.

### Containerfile

This is the container build file, an implementation agnostic variant of
Dockerfile.

Using the base latest alpine image, installs openjdk25-jre-headless and add the
minecraft_server.jar and entrypoint scripts.

### build.sh

This file checks the cached version file against the latest available Minecraft
server version. If they are different, it builds a new container version, and
updates the container using podman auto-update.

### install.sh

Runs build.sh, then installs the systemd user units.

### SystemD units

* build.service runs build.sh
* build.timer runs build.service once a day
* minecraft_server.container the quadlet container definition

