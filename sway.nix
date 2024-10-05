{ lib, config, pkgs, ... }:

{
  options = {
    nic.window-managers.sway = {
      enable = lib.mkEnableOption "sway";
    };
  };

  config = lib.mkIf config.nic.window-managers.sway.enable {
    nic.window-managers.start-command = "sway";
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraOptions =
        let
          sway-config = pkgs.substituteAll {
              src = ./sway-config;
              wallpaper = ./wallpaper.png;
              xresources = config.nic.window-managers.x-resources.source;
          };
        in
        [ "'--config ${sway-config}'" ];
        extraPackages = with pkgs; [
          screenshot dex xorg.xrdb
          (waybar.override { wm = "sway"; })
        ];
    };
    xdg.portal.wlr.enable = true;
  };
}
