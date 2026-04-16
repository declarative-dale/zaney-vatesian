{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  expat,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ipu7-camera-bins";
  version = "unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-camera-bins";
    tag = "20260327_1";
    hash = "sha256-Sj1jBOOegTk8tdmDN06MYEa7KmutnfSb5AEhXhoQkSc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    (lib.getLib stdenv.cc.cc)
    expat
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --no-preserve=mode --recursive \
      lib \
      include \
      $out/

    runHook postInstall
  '';

  postFixup = ''
    for lib in $out/lib/lib*.so.*; do
      lib=''${lib##*/};
      if [ ! -e "$out/lib/''${lib%.*}" ]; then
        ln -s "$lib" "$out/lib/''${lib%.*}";
      fi
    done

    for pcfile in $out/lib/pkgconfig/*.pc; do
      substituteInPlace $pcfile \
        --replace 'prefix=/usr' "prefix=$out"
    done
  '';

  meta = {
    description = "IPU7 firmware and proprietary image processing libraries";
    homepage = "https://github.com/intel/ipu7-camera-bins";
    license = lib.licenses.issl;
    sourceProvenance = with lib.sourceTypes; [
      binaryFirmware
    ];
    maintainers = [];
    platforms = ["x86_64-linux"];
  };
})
