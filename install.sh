#!/bin/bash
CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

echo Installing to $CWD ...

pushd "$CWD" > /dev/null

echo Creating directories ...

mkdir -p ~/.config/systemd/user/ ~/.config/containers/systemd/ data

echo Creating unit files ...

sed "s|%PATH%|${CWD}|" build.service > ~/.config/systemd/user/build.service
sed "s|%PATH%|${CWD}|" minecraft_server.container > ~/.config/containers/systemd/minecraft_server.container
cp build.timer ~/.config/systemd/user/

echo Reloading SystemD and enabling services ...

systemctl --user daemon-reload
systemctl --user enable --now build.timer

echo Building container image ... 

./build.sh

popd > /dev/null

