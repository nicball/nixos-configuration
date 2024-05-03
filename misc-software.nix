{ pkgs, ... }:

{
  # Flatpak
  services.flatpak.enable = true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Steam
  programs.steam.enable = true;

  # kde-connect
  programs.kdeconnect.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # Fish shell
  programs.fish.enable = true;

  # WireShark
  programs.wireshark.enable = true;

  # Man pages for devs
  documentation.dev.enable = true;

  # Git
  programs.git = {
    enable = true;
    config = {
      user = {
        email = "znhihgiasy@gmail.com";
        name = "Nick Ballard";
      };
    };
  };

  # Apps
  environment.systemPackages =
    with pkgs;
    [
      # dev
      man-pages man-pages-posix
      kakoune gcc gdb jdk gnumake
      # (agda.withPackages (p: [ p.standard-library ]))

      # i3
      # polybarFull xclip maim dmenu

      # cli tools
      file wget zip unzip neofetch jq screen unar pv rsync aria2 ffmpeg fd ripgrep

      # system tools
      cachix
      htop cpufrequtils parted lm_sensors sysstat usbutils pciutils smartmontools
      iw wirelesstools libva-utils vdpauinfo xdg-utils lsof traceroute iperf
      powertop stress-ng

      # emulators
      wineWowPackages.waylandFull winetricks xorg.xhost qemu

      # documents
      graphviz pandoc foliate # texlive.combined.scheme-full

      # GUI stuff

      ## Utility
      kitty firefox
      wl-clipboard

      ## Multimedia
      mpv obs-studio # tigervnc
      yesplaymusic

      ## Document
      libreoffice # calibre

      ## Game
      gamescope prismlauncher # lutris openttd minecraft fabric-installer
    ];

  # Default Applications
  environment.variables.EDITOR = "kak";
  environment.variables.BROWSER = "firefox";

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = { registry-mirrors = [ "https://docker.mirrors.ustc.edu.cn/" ]; };

}
