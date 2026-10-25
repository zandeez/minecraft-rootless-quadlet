# Minimal Minecraft Server

This is a minimal-dependency Minecraft server run as a rootless quadlet
container, with automatic updates.

Supports running multiple independent instances (e.g. a survival and a
creative world) side by side on the same host, each on its own game/rcon
ports and with its own persistent data folder. All instances share the
same built image, so they always run the same Minecraft server version.

## Usage

Create a non-root user to run the container as, and enable linger

  sudo addgroup -S <group>
  sudo adduser -S <user> -G <group>
  sudo loginctl enable-linger <user>

As the new user, clone this repo, then install one or more instances:

  git clone https://github.com/zandeez/minecraft-rootless-quadlet.git
  cd minecraft-rootless-quadlet
  ./install.sh survival 25565 25575
  ./install.sh creative 25566 25576

Arguments are `<name> [game_port] [rcon_port]` — all optional, defaulting
to `default`, `25565`, and `25575` respectively, so `./install.sh` alone
still gives you a single instance on the original default ports.

Each instance gets its own data folder (`instances/<name>/data`) and its
own systemd user unit, named `minecraft_server-<name>`:

  systemctl --user start minecraft_server-survival
  systemctl --user start minecraft_server-creative

If needed, allow each instance's game port in your firewall (and its rcon
port too, if you use rcon).

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

Renders `minecraft_server.container.template` into a concrete quadlet
unit for the given instance name/ports, then runs build.sh and installs
the systemd user units. Safe to re-run per instance (e.g. once per name
you want to add), and re-running for an existing instance just
re-renders its unit file.

### SystemD units

* build.service runs build.sh (shared across all instances)
* build.timer runs build.service once a day (shared across all instances)
* minecraft_server.container.template the quadlet container definition,
  rendered per instance by install.sh into
  `minecraft_server-<name>.container`

