{ pkgs, lib, config, ... }:

{
  imports = [
    # ./kde.nix
  ];

  nic.window-managers = {
    enable = true;
    niri.enable = true;
    # sway.enable = true;
    scaling = {
      enable = true;
      factor = 1.5;
      cursor.enable = true;
    };
    wallpaper = {
      enable = true;
      source = ./wallpaper.png;
    };
  };
  nic.waybar.enable = true;
  nic.greetd = {
    enable = true;
    auto-login = {
      enable = true;
      user = "nicball";
    };
  };

  # Kitty
  nic.kitty.enable = true;

  # Notifications
  nic.dunst.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    fontPackages = with pkgs; [ source-han-sans ];
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Keyboard driver
  nic.hexcore-link.enable = true;

  # kde-connect
  # programs.kdeconnect.enable = true;

  # Input methods
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      addons = with pkgs; [ fcitx5-rime ];
      waylandFrontend = true;
    };
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.extraConfig = {
      disable-headset = {
        "wireplumber.settings"."bluetooth.autoswitch-to-headset-profile" = false;
        "monitor.bluez.properties"."bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
      };
    };
  };
  hardware.bluetooth.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    source-han-sans source-han-serif
    source-code-pro
    font-awesome_5
    mononoki
    julia-mono
  ];
  # Prefer Simplified Chinese Fonts
  fonts.fontconfig.defaultFonts = {
    serif = [ "DejaVu Serif" "Source Han Serif SC" ];
    sansSerif = [ "DejaVu Sans" "Source Han Sans SC" ];
    monospace = [ "Monaco" "DejaVu Sans Mono" "Source Han Sans SC" ];
  };
  # Monaco
  # fonts.fontconfig.localConf = ''
  #   <?xml version="1.0"?>
  #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #   <fontconfig>
  #     <match target="scan">
  #       <test name="family">
  #         <string>Monaco</string>
  #       </test>
  #       <edit name="spacing">
  #         <int>90</int>
  #       </edit>
  #     </match>
  #   </fontconfig>
  # '';

  # misc programs
  environment.systemPackages = with pkgs; [
    # GUI stuff

    ## Utility
    firefox
    wl-clipboard

    ## Multimedia
    mpv obs-studio # tigervnc
    yesplaymusic foliate

    ## Document
    libreoffice # calibre

    ## Game
    gamescope prismlauncher # lutris openttd minecraft fabric-installer
  ];

  # Default Applications
  environment.variables.BROWSER = "firefox";
}
