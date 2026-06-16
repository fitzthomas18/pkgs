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
    mkdir -p $out/bin
    cp extracted/acbridge.exe $out/bin/
    cp extracted/pcars2bridge.exe $out/bin/
    cp extracted/rf2bridge.exe $out/bin/ 2>/dev/null || true
    rm -rf extracted
    runHook postInstall
  '';

  postInstall = ''
    cat > $out/bin/acbridge.exe <<'WRAPPER'
    #!/bin/sh
    if [ ! -L "/home/thomas/.local/share/simshmbridge/acbridge.exe" ]; then
      DIR="$(dirname "$(readlink -f "$0")")"
      mkdir -p "/home/thomas/.local/share/simshmbridge"
      ln -sf "$DIR/acbridge.exe" "/home/thomas/.local/share/simshmbridge/"
      ln -sf "$DIR/pcars2bridge.exe" "/home/thomas/.local/share/simshmbridge/" 2>/dev/null || true
      ln -sf "$DIR/rf2bridge.exe" "/home/thomas/.local/share/simshmbridge/" 2>/dev/null || true
    fi
    exec "/home/thomas/.local/share/simshmbridge/acbridge.exe" "$@"
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
