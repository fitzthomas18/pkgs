{ lib, pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "simapi-all";
  version = "561ff2a687efad7c781acd4400ef28c74d716ba3-20";

  src = pkgs.fetchFromGitHub {
    owner = "wasabinator";
    repo = "simapi";
    rev = "561ff2a687efad7c781acd4400ef28c74d716ba3";
    hash = "sha256-LRkm7s4R7ihFBWVC7w9odzLcOvgJQb4Ude15QWWnOy4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.patchelf
    pkgs.makeWrapper
  ];
  buildInputs = with pkgs; [
    argtable
    libconfig
    libuv
    yder
  ];

  postPatch = ''
    # Debug: list the files we're patching
    ls simd/simd.c
    # Patch simd to use wine64 instead of wine (both paths)
    sed -i 's|dist/bin/wine|dist/bin/wine64|g' simd/simd.c
    sed -i 's|files/bin/wine|files/bin/wine64|g' simd/simd.c
    # Verify the patch
    grep -n "wine64" simd/simd.c || echo "WARNING: patch may not have worked"
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RELEASE"
    "-DCMAKE_INSTALL_RPATH=$out/lib"
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp ./simd/simd $out/bin/simd
    cp ./libsimapi.so* $out/lib/
    cp ${pkgs.libuv}/lib/libuv.so* $out/lib/
    cp ${pkgs.yder}/lib/libyder.so* $out/lib/
    cp ${pkgs.argtable}/lib/libargtable*.so* $out/lib/
    cp ${pkgs.libconfig}/lib/libconfig*.so* $out/lib/
    patchelf --set-rpath "$out/lib" $out/bin/simd
    wrapProgram "$out/bin/simd" --prefix LD_LIBRARY_PATH : "$out/lib"
  '';

  meta = with lib; {
    description = "Simd";
    homepage = "https://github.com/wasabinator/simapi";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
