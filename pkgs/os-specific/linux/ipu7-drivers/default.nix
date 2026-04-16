{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation rec {
  pname = "ipu7-drivers";
  version = "unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-drivers";
    tag = "20260327_1";
    hash = "sha256-kpo4Ir2tdvaia0Ic2G7mOwbnPyvHxRu5/Ooaf9PEwek=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags =
    kernelModuleMakeFlags
    ++ [
      "KERNELRELEASE=${kernel.modDirVersion}"
      "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

  enableParallelBuilding = true;

  preInstall = ''
    sed -i -e "s,INSTALL_MOD_DIR=,INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=," Makefile
  '';

  installTargets = [
    "modules_install"
  ];

  meta = {
    homepage = "https://github.com/intel/ipu7-drivers";
    description = "Out-of-tree Intel IPU7 PSYS kernel driver";
    license = lib.licenses.gpl2Only;
    maintainers = [];
    platforms = ["x86_64-linux"];
    broken = kernel.kernelOlder "6.17";
  };
}
