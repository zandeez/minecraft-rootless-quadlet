#!/bin/bash
set -euo pipefail
CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

NAME="${1:-default}"
GAME_PORT="${2:-25565}"
RCON_PORT="${3:-25575}"
UNIT_NAME="minecraft_server@${NAME}"

echo Installing instance \'$NAME\' \(game port $GAME_PORT, rcon port $RCON_PORT\) to $CWD ...

pushd "$CWD" > /dev/null

echo Creating directories ...

QUADLET_DIR="${HOME}/.config/containers/systemd"
DROPIN_DIR="${QUADLET_DIR}/minecraft_server@${NAME}.container.d"
mkdir -p ~/.config/systemd/user/ "$QUADLET_DIR" "$DROPIN_DIR" "instances/${NAME}/data"

echo Creating unit files ...

sed "s|%PATH%|${CWD}|" build.service > ~/.config/systemd/user/build.service
cp build.timer ~/.config/systemd/user/

# The template itself is the same for every instance -- only %i (the
# instance name) varies, and systemd/Quadlet substitutes that at
# generate time, not here.
sed "s|%PATH%|${CWD}|g" "minecraft_server@.container" > "${QUADLET_DIR}/minecraft_server@.container"

# Ports can't come from %i alone (one specifier, two ports needed), so
# each instance gets its own drop-in overriding/adding PublishPort.
cat > "${DROPIN_DIR}/ports.conf" <<EOF
[Container]
PublishPort=${GAME_PORT}:25565/tcp
PublishPort=${RCON_PORT}:25575/tcp
EOF

echo Reloading SystemD and enabling services ...

systemctl --user daemon-reload
systemctl --user enable --now build.timer

echo Building container image ...

./build.sh

popd > /dev/null

echo Done. Start this instance with: systemctl --user start "${UNIT_NAME}"

