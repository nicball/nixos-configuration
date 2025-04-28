{ pkgs, ... }:

{
  programs.ydotool = {
    enable = true;
    group = "users";
  };

  # Flatpak
  services.flatpak.enable = true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  security.sudo.wheelNeedsPassword = false;

  # Fish shell
  programs.fish.enable = true;

  # Zsh
  # programs.zsh = {
  #   enable = true;
  #   autosuggestions.enable = true;
  #   syntaxHighlighting.enable = true;
  #   ohMyZsh.enable = true;
  # };

  # WireShark
  programs.wireshark.enable = true;

  # Man pages for devs
  documentation.dev.enable = true;

  # Kakoune
  nic.kakoune.enable = true;

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

  # Cross compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Apps
  environment.systemPackages =
    with pkgs;
    [
      # dev
      man-pages man-pages-posix
      gcc gdb jdk gnumake
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
      wineWowPackages.stagingFull winetricks xorg.xhost qemu umu-launcher

      # documents
      graphviz pandoc # texlive.combined.scheme-full
    ];

  # Default Applications
  environment.variables.EDITOR = "kak";

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = { registry-mirrors = [ "https://docker.mirrors.ustc.edu.cn/" ]; };

}
