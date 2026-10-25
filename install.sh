#!/bin/bash
set -euo pipefail
CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

NAME="${1:-default}"
GAME_PORT="${2:-25565}"
RCON_PORT="${3:-25575}"
UNIT_NAME="minecraft_server-${NAME}"

echo Installing instance \'$NAME\' \(game port $GAME_PORT, rcon port $RCON_PORT\) to $CWD ...

pushd "$CWD" > /dev/null

echo Creating directories ...

mkdir -p ~/.config/systemd/user/ ~/.config/containers/systemd/ "instances/${NAME}/data"

echo Creating unit files ...

sed "s|%PATH%|${CWD}|" build.service > ~/.config/systemd/user/build.service
cp build.timer ~/.config/systemd/user/
sed \
  -e "s|%PATH%|${CWD}|g" \
  -e "s|%NAME%|${NAME}|g" \
  -e "s|%GAME_PORT%|${GAME_PORT}|g" \
  -e "s|%RCON_PORT%|${RCON_PORT}|g" \
  minecraft_server.container.template > "${HOME}/.config/containers/systemd/${UNIT_NAME}.container"

echo Reloading SystemD and enabling services ...

systemctl --user daemon-reload
systemctl --user enable --now build.timer

echo Building container image ...

./build.sh

popd > /dev/null

echo Done. Start this instance with: systemctl --user start "${UNIT_NAME}"

