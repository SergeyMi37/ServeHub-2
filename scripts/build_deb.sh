#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GUI_DIR="$PROJECT_ROOT/gui-installer"

cd "$GUI_DIR"

if [ ! -f "build/bin/gui-installer" ]; then
    echo "==> Бинарник gui-installer не найден. Запуск wails build..."
    wails build -tags webkit2_41
fi

DEB_DIR="build/debian/servehub-installer"
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"

echo "==> Копирование файлов..."
cp "build/bin/gui-installer" "$DEB_DIR/usr/bin/servehub-installer"

echo "==> Создание DEBIAN/control..."
cat <<EOF > "$DEB_DIR/DEBIAN/control"
Package: servehub-installer
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0 | libgtk-3-0t64, libwebkit2gtk-4.0-37 | libwebkit2gtk-4.1-0
Maintainer: Roman Frolov
Description: ServeHub GUI Installer
EOF

echo "==> Создание ярлыка..."
cat <<EOF > "$DEB_DIR/usr/share/applications/servehub.desktop"
[Desktop Entry]
Type=Application
Name=ServeHub Installer
Exec=servehub-installer
Icon=utilities-terminal
Categories=Utility;
Terminal=false
EOF

echo "==> Упаковка пакета..."
mkdir -p build/bin
dpkg-deb --root-owner-group --build "$DEB_DIR" build/bin/servehub-installer.deb

echo "==> Готово! Пакет сохранен в gui-installer/build/bin/servehub-installer.deb"