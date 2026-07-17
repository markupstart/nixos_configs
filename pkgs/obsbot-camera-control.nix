# Nix derivation for obsbot-camera-control
# https://github.com/aaronsb/obsbot-camera-control
#
# IMPORTANT: The OBSBOT SDK (sdk/lib/libdev.so) is a pre-compiled closed-source
# binary shipped inside the source repo. autoPatchelfHook rewrites its ELF
# interpreter and RPATH so it works under NixOS.

{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, autoPatchelfHook
, patchelf
}:

stdenv.mkDerivation rec {
  pname = "obsbot-camera-control";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "aaronsb";
    repo = "obsbot-camera-control";
    rev = "v${version}";
    # Run: nix build .#obsbot-camera-control --no-link 2>&1 | grep "got:"
    # to get the correct hash, then replace this value.
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    autoPatchelfHook   # patches pre-built libdev.so + our built binaries
    qt6.wrapQtAppsHook # wraps executables with Qt env vars
  ];

  buildInputs = [
    qt6.qtbase           # Core, Widgets, OpenGLWidgets
    qt6.qtmultimedia     # Multimedia, MultimediaWidgets
    stdenv.cc.cc.lib     # libstdc++.so.6 / libgcc_s.so.1 (needed by libdev.so)
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # CMakeLists.txt has no install() targets; disable the cmake install phase.
  dontUseCmakeInstall = true;

  # Tell autoPatchelfHook to also scan $out/lib so it can satisfy the
  # libdev.so dependency when patching our built binaries.
  preFixup = ''
    addAutoPatchelfSearchPath "$out/lib"
  '';

  installPhase = ''
    runHook preInstall

    # The CMakeLists sets CMAKE_RUNTIME_OUTPUT_DIRECTORY = ''${CMAKE_SOURCE_DIR}/bin.
    # nixpkgs cmake hook builds in a "build/" subdirectory of the source root,
    # so the binaries land one level up at ../bin/.
    install -Dm755 ../bin/obsbot-gui "$out/bin/obsbot-gui"
    install -Dm755 ../bin/obsbot-cli "$out/bin/obsbot-cli"

    # Install the pre-built SDK shared library.
    # autoPatchelfHook (in the fixup phase) will rewrite its ELF interpreter
    # and RPATH to point into the Nix store.
    install -Dm755 ../sdk/lib/libdev.so.1.0.2 "$out/lib/libdev.so.1.0.2"
    ln -sf libdev.so.1.0.2 "$out/lib/libdev.so.1"
    ln -sf libdev.so.1.0.2 "$out/lib/libdev.so"

    # Desktop integration
    install -Dm644 ../obsbot-control.desktop \
      "$out/share/applications/obsbot-control.desktop"
    install -Dm644 ../resources/icons/camera.svg \
      "$out/share/icons/hicolor/scalable/apps/obsbot-control.svg"

    runHook postInstall
  '';

  # After autoPatchelfHook runs, also add $out/lib to the RPATH of the
  # built binaries so they can find libdev.so at runtime.
  postFixup = ''
    patchelf --add-rpath "$out/lib" "$out/bin/obsbot-gui"
    patchelf --add-rpath "$out/lib" "$out/bin/obsbot-cli"
  '';

  meta = with lib; {
    description = "Native Qt6 application for controlling OBSBOT cameras on Linux";
    longDescription = ''
      Controls OBSBOT cameras (Tiny 2, Meet 2, Tiny 4K, etc.) from Linux with a
      full GUI: PTZ, auto-framing, HDR, image settings, live preview, and
      optional virtual camera output via v4l2loopback.
    '';
    homepage = "https://github.com/aaronsb/obsbot-camera-control";
    license = licenses.mit;
    # The bundled OBSBOT SDK has no explicit license (distributed by OBSBOT).
    platforms = [ "x86_64-linux" ];
    mainProgram = "obsbot-gui";
  };
}
