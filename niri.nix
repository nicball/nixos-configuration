{ lib, config, pkgs, ... }:

{
  options.nic.window-managers.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf config.nic.window-managers.niri.enable {
    nic.window-managers.start-command = "niri-session";
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk gnome-keyring ];
      configPackages = [ pkgs.niri ];
    };
    environment.systemPackages = with pkgs; [ niri xwayland-satellite (waybar.override { wm = "niri"; }) ];
  };
}
