{ lib, pkgs, config, options, ... }:

let cfg = config.nic.window-managers; in

{
  imports = [
    ./sway.nix
    ./niri.nix
  ];

  options = {
    nic.window-managers = {
      enable = lib.mkEnableOption "window managers";
      scaling = {
        enable = lib.mkEnableOption "scaling";
        factor = lib.mkOption {
          type = lib.types.numbers.between 1 100;
          default = 1;
        };
      };
      start-command = lib.mkOption {
        type = lib.types.str;
        description = "command to start the windows manager";
      };
      x-resources.text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        description = "text of .Xresources";
      };
      x-resources.source = lib.mkOption {
        type = lib.types.path;
        description = "path of .Xresources";
      };
    };
  };

  config = lib.mkIf cfg.enable
    (lib.mkMerge [

      ({
        # Do nothing when closing the lid with wall power
        services.logind.lidSwitchExternalPower = "ignore";

        nic.window-managers.x-resources.source = lib.mkIf (cfg.x-resources.text != null)
          (lib.mkDerivedConfig options.nic.window-managers.x-resources.text (pkgs.writeText ".Xresources"));

        # Greetd
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.greetd.greetd}/bin/agreety --cmd fish";
            };
            initial_session = {
              command = cfg.start-command;
              user = "nicball";
            };
          };
        };

        environment.systemPackages = with pkgs; [
          pavucontrol swaylock rofi-wayland
          swayimg mako acpilight adwaita-icon-theme nautilus glib
        ];
      })

      (lib.mkIf cfg.scaling.enable {
        environment.variables.QT_WAYLAND_FORCE_DPI = toString (builtins.ceil (96 * cfg.scaling.factor));
        nic.nicpkgs.scaling-factor = cfg.scaling.factor;
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [
          {
            settings = with lib.gvariant; {
              "org/gnome/desktop/interface" = {
                cursor-size = mkInt32 (builtins.ceil (24 * cfg.scaling.factor));
                cursor-theme = mkString "Adwaita";
                text-scaling-factor = mkDouble cfg.scaling.factor;
              };
            };
          }
        ];
        nixpkgs.overlays = [ (self: super: { steam = super.steam.override { extraArgs = "-forcedesktopscaling ${toString cfg.scaling.factor}"; }; }) ];
        nic.window-managers.x-resources.text = ''
          Xft.dpi: ${toString (builtins.ceil (96 * cfg.scaling.factor))}
          Xcursor.size: ${toString (builtins.ceil (24 * cfg.scaling.factor))}
        '';
      })

    ]);
}
