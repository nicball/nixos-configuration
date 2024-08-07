{ pkgs, lib, config, ... }:

{
  # Do nothing when closing the lid with wall power
  services.logind.lidSwitchExternalPower = "ignore";

  # Greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd fish";
      };
      initial_session = {
        command = "dbus-run-session -- sway";
        user = "nicball";
      };
    };
  };

  # Sway
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    extraOptions =
      let
        sway-config = pkgs.substituteAll {
            src = ./sway-config;
            wallpaper = ./wallpaper.png;
        };
      in
      [ "'--config ${sway-config}'" ];
      extraPackages = with pkgs; [
        screenshot pavucontrol dex swaylock rofi-wayland waybar swayimg xorg.xrdb mako acpilight alsa-utils gnome.adwaita-icon-theme gnome.nautilus glib
      ];
  };
  xdg = {
    portal.wlr.enable = true;
  };

  # Scaling
  environment.variables.QT_WAYLAND_FORCE_DPI = "144";
  nic.scale-factor = 1.5;
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = with lib.gvariant; {
        "org/gnome/desktop/interface" = {
          cursor-size = mkInt32 (builtins.ceil (24 * config.nic.scale-factor));
          cursor-theme = mkString "Adwaita";
          text-scaling-factor = mkDouble config.nic.scale-factor;
        };
      };
    }
  ];

  # Steam
  programs.steam = {
    enable = true;
    package = pkgs.steam.override { extraArgs = "-forcedesktopscaling ${toString config.nic.scale-factor}"; };
    fontPackages = with pkgs; [ source-han-sans ];
  };

  # kde-connect
  programs.kdeconnect.enable = true;

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
  fonts.fontconfig.defaultFonts = {
    serif = [ "DejaVu Serif" "Source Han Serif SC" ];
    sansSerif = [ "DejaVu Sans" "Source Han Sans SC" ];
    monospace = [ "Monaco" "DejaVu Sans Mono" "Source Han Sans SC" ];
  };
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

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };
  hardware.bluetooth = {
    enable = true;
  };
}
