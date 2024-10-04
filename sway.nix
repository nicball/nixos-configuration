{ lib, pkgs, config, ... }:

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
        screenshot pavucontrol dex swaylock rofi-wayland waybar swayimg xorg.xrdb mako acpilight alsa-utils adwaita-icon-theme nautilus glib
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
}
