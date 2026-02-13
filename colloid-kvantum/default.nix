{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
   pname = "colloid-kvantum";
   version = "20250706";

   src = pkgs.fetchFromGitHub {
     owner = "vinceliuice";
     repo = "Colloid-kde";
     rev = "b768904d10ba9fcb95abfb59538eab100b1fed1e";
     sha256 = "sha256-CWa6HnMP042jh573/x7WxYyRScN/l+jjCasiaBODljA=";
   };

   installPhase = ''
     runHook preInstall
     mkdir -p $out/share/Kvantum
     cp -a "Kvantum/Colloid" $out/share/Kvantum
     runHook postInstall
   '';
 }
