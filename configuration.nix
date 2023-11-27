# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, nicpkgs, niclib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];


  # # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Secure boot
  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
    configurationLimit = 10;
  };

  # Flatpak
  services.flatpak.enable = true;

  # services.mysql.enable = true;
  # services.mysql.package = pkgs.mariadb;

  # Switch CapsLock and Left Ctrl
  ## evdev:atkbd:dmi:bvnLENOVO:bvrJ6CN40WW:bd*:svnLENOVO:pn21D1:pvr*:*
  services.udev.extraHwdb = ''
    evdev:atkbd:*
     KEYBOARD_KEY_3a=leftctrl
     KEYBOARD_KEY_1d=capslock
  '';

  ## For keyboard patch
  boot.kernelPackages = pkgs.linuxPackages_6_5;

  ## For realtek wifi
  boot.extraModulePackages = [ (nicpkgs.rtw89.override { kernel = config.boot.kernelPackages.kernel; }) ];
  # hardware.enableRedistributableFirmware = true;

  # AMD PState
  powerManagement.cpuFreqGovernor = "powersave";
  boot.kernelModules = [ "amd_pstate" ];
  boot.kernelParams = [
    "initcall_blacklist=acpi_cpufreq_init"
    "amd_pstate=active"
    "iomem=relaxed" # for ryzenadj
  ];
  services.acpid = {
    enable = true;
    acEventCommands = ''
      vals=($1)
      case ''${vals[3]} in
        00000000)
          for i in /sys/devices/system/cpu/cpufreq/policy*; do
            echo power > $i/energy_performance_preference
          done
        ;;
        00000001)
          for i in /sys/devices/system/cpu/cpufreq/policy*; do
            echo performance > $i/energy_performance_preference
          done
        ;;
      esac
    '';
  };
  systemd.services.auto-set-epp =
    let script = pkgs.writeShellScript "auto-set-epp.sh" ''
      if ${pkgs.acpi}/bin/acpi -a | grep off-line > /dev/null; then
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo power > $i/energy_performance_preference
        done
      else
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo performance > $i/energy_performance_preference
        done
      fi
    '';
    in {
      description = "Automatically set AMD PState EPP on startup";
      wantedBy = [ "multi-user.target" ];
      after = [ "cpufreq.service" ];
      serviceConfig = {
        ExecStart = script;
        Type = "oneshot";
      };
    };

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Do nothing when closing the lid with wall power
  services.logind.lidSwitchExternalPower = "ignore";

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions =
      let
        sway-config = pkgs.substituteAll {
            src = ./sway-config;
            wallpaper = ./wallpaper.png;
        };
      in
      [ "'--config ${sway-config}'" ];
  };
  xdg = {
    portal.wlr.enable = true;
  };

  # Input methods
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    source-han-sans source-han-serif
    source-code-pro
    font-awesome_5
    mononoki
    julia-mono
  ];
  # Prefer Simplified Chinese Fonts
  fonts.fontconfig.localConf = ''
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>DejaVu Sans</family>
          <family>Source Han Sans SC</family>
        </prefer>
      </alias>
      <alias>
        <family>monospace</family>
        <prefer>
          <family>DejaVu Sans Mono</family>
          <family>Source Han Sans SC</family>
        </prefer>
      </alias>
      <alias>
        <family>serif</family>
        <prefer>
          <family>DejaVu Serif</family>
          <family>Source Han Serif SC</family>
        </prefer>
      </alias>
    </fontconfig>
  '';

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  hardware.bluetooth = {
    enable = true;
  };

  # Steam
  programs.steam.enable = true;

  # Time zone
  time.timeZone = "Asia/Shanghai";
  # Compatible with Windows
  time.hardwareClockInLocalTime = true;

  # Clash
  systemd.services.clash = {
    description = "Clash Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.clash}/bin/clash -f ${./private/clash.yaml} -d /var/clash > /dev/null 2>&1";
    };
  };

  # Network
  networking = {
    hostName = "nixos-laptop";

    proxy.httpProxy = "http://127.0.0.1:7890";
    proxy.httpsProxy = "http://127.0.0.1:7890";
    proxy.noProxy = "127.0.0.1,localhost";

    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
    interfaces.wlo1.useDHCP = true;

    # Disable IPV6 temp address
    tempAddresses = "disabled";

    # DNS
    # nameservers = [ "8.8.4.4" "8.8.8.8" ];
    # hosts = {
    #     "202.38.64.59" = [ "wlt.ustc.edu.cn" "wlt" ];
    # };
    dhcpcd.extraConfig = ''
        # nohook resolv.conf
        release
    '';

    # Wireless
    wireless.enable = true;
    wireless.networks = import ./private/wireless-networks.nix;
    wireless.userControlled.enable = true; # allow wpa_cli to connect
  };

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [ "8286ac0e47b1e8e6" ];
  # };

  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   shares = { aria2d = {
  #     path = "/var/aria2d";
  #     writable = "yes";
  #   }; };
  # };

  # Nix channels
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  nixpkgs.config.allowUnfree = true;

  # Users
  users.users.nicball = {
    isNormalUser = true;
    createHome = false;
    home = "/home/nicball";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "kvm" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxtyU71qMEWzYBaa5aQzGCRlRsERuzc2sFshGA3tWewv3UfcZca27yQTGQnMCvqmObL4+zl0SikUTbQX7Pi4vo7U42EADdWJ4nHJ+/4kJ3s7xtYnlJAdkuS/fDZYsjDLxqEBMR5GCgtPvE8K2A3siBHW837J0fb8SuH7hUe0QnibCeHFPlNuY2OEAZBkUDsXhBz0jDd3D2rg7W1ALdHl+zFt+SimF4H0jOOssF893XfjXZw9C9DLbs0pKeWBJ8cMAf0ZSRFBcJMiiOqUbJQP0QyzVnwfJVX5WsAsebouClwK+tc7txX04BuJqefJbQ1t58cFFYwLQQKDCWwI5smNxqBVhjDSNf1i4ggmcIgaAnV6WWpV30+uObWWLQfox2zkNcxA0k6jkOfoJhkOjxRSFy588GNAstsXd6TgmaZI85RwAM1R9mO7FNrKGaEwpWjclaaml2/ZvnuaYW8mO0bySpYJPACk7O7hgj97BkJGlHdVixR9DSBnBVzHZ2ppQtsqM= nicball"
    ];
  } // import ./private/user.nix;
  users.users.wine = {
      isNormalUser = true;
      home = "/home/wine";
      shell = pkgs.fish;
  } // import ./private/user.nix;

  security.sudo.wheelNeedsPassword = false;

  # Fish shell
  programs.fish.enable = true;

  # Greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd fish";
      };
      initial_session = {
        command = "sway";
        user = "nicball";
      };
    };
  };

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
      nicpkgs.kakoune gcc gdb jdk gnumake
      # nicpkgs.emacs ripgrep # direnv nix-direnv
      # (pkgs.agda.withPackages (p: [ p.standard-library ]))

      # i3
      # polybarFull xclip maim dmenu

      # cli tools
      file wget zip unzip neofetch jq screen unar pv rsync nicpkgs.aria2 ffmpeg

      # system tools
      clash cachix
      htop cpufrequtils parted lm_sensors sysstat usbutils pciutils smartmontools
      iw wirelesstools libva-utils vdpauinfo xdg-utils lsof traceroute iperf
      nicpkgs.ryzenadj radeontop powertop stress-ng

      # emulators
      wineWowPackages.stable xorg.xhost qemu

      # documents
      graphviz pandoc # texlive.combined.scheme-full

      # GUI stuff

      ## Utility
      nicpkgs.screenshot pavucontrol nicpkgs.kitty firefox
      gnome.nautilus dex swaylock nicpkgs.rofi nicpkgs.waybar wl-clipboard nicpkgs.mako xorg.xrdb
      gnome.adwaita-icon-theme swayimg acpilight alsa-utils

      ## Multimedia
      mpv obs-studio # tigervnc
      yesplaymusic

      ## Document
      libreoffice # calibre

      ## Game
      prismlauncher # lutris openttd minecraft fabric-installer
    ];

  # Default Applications
  environment.variables = {
      EDITOR = "kak";
      BROWSER = "firefox";
      QT_WAYLAND_FORCE_DPI = "144";
  };
  xdg.mime.defaultApplications = {
    "application/epub+zip" = "calibre-ebook-viewer.desktop";
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = { registry-mirrors = [ "https://docker.mirrors.ustc.edu.cn/" ]; };

  # Nix flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  # nix.package = pkgs.nixUnstable;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh = {
  #   enable = true;
  #   # permitRootLogin = "yes";
  #   forwardX11 = true;
  #   passwordAuthentication = true;
  # };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 7890 ];
  #   25565 8123 # mc
  #   # 1935 # owncast
  #   9090 # clash
  #   # 3001 3005 # shapez
  #   2344 2345 # arma3
  #   # 7500 # frps dashboard
  #   5900 # vnc
  #   10308 # dcs
  #   8088 # dcs web
  #   # 5201 # iperf
  #   # 7890 7891 # clash
  # ];
  # networking.firewall.allowedUDPPorts = [
  #   2302 2303 2304 2305 2306 2344 # arma3
  #   # 27015 27016 # barotrauma
  #   10308 # dcs
  #   # 7890 7891 # clash
  # ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
