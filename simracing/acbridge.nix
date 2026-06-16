{ lib, pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "acbridge";
  version = "0.1.0";

  src = pkgs.fetchurl {
    url = "https://github.com/Spacefreak18/simshmbridge/releases/download/0.1.0/compatbinaries.zip";
    sha256 = "sha256-rQWcUvchRnpyhF2tVCKRBmOQlB0W1OYv9dk6ywgcUMA=";
  };

  nativeBuildInputs = [ pkgs.unzip ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p extracted
    unzip -o "$src" -d extracted

    mkdir -p $out/share/simshmbridge
    cp extracted/acbridge.exe $out/share/simshmbridge/
    cp extracted/pcars2bridge.exe $out/share/simshmbridge/
    cp extracted/rf2bridge.exe $out/share/simshmbridge/ 2>/dev/null || true

    mkdir -p $out/bin
    rm -rf extracted
    runHook postInstall
  '';

  postInstall = ''
    cat > $out/bin/acbridge.exe <<'WRAPPER'
    #!/bin/sh
    # Target /var/lib with user separation for impermanence compatibility
    RUN_DIR="/var/lib/simshmbridge/$(id -u)"

    if [ ! -L "$RUN_DIR/acbridge.exe" ]; then
      DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/share/simshmbridge"
      mkdir -p "$RUN_DIR"
      ln -sf "$DIR/acbridge.exe" "$RUN_DIR/"
      ln -sf "$DIR/pcars2bridge.exe" "$RUN_DIR/" 2>/dev/null || true
      ln -sf "$DIR/rf2bridge.exe" "$RUN_DIR/" 2>/dev/null || true
    fi
    exec "$RUN_DIR/acbridge.exe" "$@"
    WRAPPER
    chmod +x $out/bin/acbridge.exe
  '';

  meta = with lib; {
    description = "Assetto Corsa shared memory bridge";
    homepage = "https://github.com";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
