{
  lib,
  stdenv,
  fetchFromGitHub,
  # build
  cmake,
  pkg-config,
  # runtime
  expat,
  gst_all_1,
  ipu7-camera-bins,
  jsoncpp,
  libdrm,
  libtool,
  # Pick one of
  # - ipu7x (Lunar Lake)
  # - ipu75xa (Panther Lake)
  # - ipu8
  ipuVersion ? "ipu7x",
}:
stdenv.mkDerivation {
  pname = "${ipuVersion}-camera-hal";
  version = "unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-camera-hal";
    tag = "20260327_1";
    hash = "sha256-iYLPu6b64bx+DNCe4+Yl+oXBcKZTVRJlssYMe7G2DWs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DBUILD_CAMHAL_ADAPTOR=ON"
    "-DBUILD_CAMHAL_PLUGIN=ON"
    "-DIPU_VERSIONS=${ipuVersion}"
    "-DUSE_STATIC_GRAPH=ON"
    "-DUSE_STATIC_GRAPH_AUTOGEN=ON"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error"
  ];

  enableParallelBuilding = true;

  buildInputs = [
    expat
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    ipu7-camera-bins
    jsoncpp
    libdrm
    libtool
  ];

  postPatch = ''
    substituteInPlace src/platformdata/JsonParserBase.h \
      --replace-fail '<jsoncpp/json/json.h>' '<json/json.h>'

    substituteInPlace src/core/processingUnit/IntelTNR7Stage.h \
      --replace-fail '"/usr/share/cros-camera/"' '"${placeholder "out"}/share/cros-camera/"'
  '';

  postInstall = ''
    mkdir -p $out/include/${ipuVersion}/
    cp -r $src/include $out/include/${ipuVersion}/libcamhal
  '';

  postFixup = ''
    sed -i \
      's|^includedir=.*$|includedir=''${prefix}/include/libcamhal|' \
      $out/lib/pkgconfig/libcamhal.pc

    for lib in $out/lib/*.so; do
      patchelf --add-rpath "${ipu7-camera-bins}/lib" "$lib"
    done
  '';

  passthru = {
    inherit ipuVersion;
  };

  meta = {
    description = "HAL for Intel IPU7 image processing in userspace";
    homepage = "https://github.com/intel/ipu7-camera-hal";
    license = lib.licenses.asl20;
    maintainers = [];
    platforms = ["x86_64-linux"];
  };
}
