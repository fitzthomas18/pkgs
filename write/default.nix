 { pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "styluslabs-write";
  version = "jan-2025";

  src = pkgs.fetchurl {
    url = "https://github.com/styluslabs/Write/releases/download/${version}/write-latest.tar.gz";
    hash = "sha256-NiBTrzjxRfpahUK3yBwUrltoiJMYZJMm+3fWgZNQTgo=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    pkg-config
    SDL2
    libGL.dev
    roboto
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    tar -xzf ${src}
    install -m755 -D Write/Write $out/bin/Write
    cp Write/Roboto-Regular.ttf $out/bin/
    cp Write/DroidSansFallback.ttf $out/bin/
    cp Write/Intro.svg $out/bin/
    mkdir -p $out/share/applications/
    mkdir -p $out/share/icons/
    cp Write/Write144x144.png $out/share/icons
    mkdir -p $out/share/applications
    cat <<INI > $out/share/applications/Write.desktop
    [Desktop Entry]
    Type=Application
    # desktop entry spec version
    Version=1.0
    Name=Write
    Comment=A word processor for handwriting
    Exec=Write
    Icon=Write144x144
    MimeType=image/svg+xml;
    Terminal=false
    Categories=Education
    INI
    runHook postInstall
  '';
}
