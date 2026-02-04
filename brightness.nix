{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ddcutil ];
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    KERNEL=="i2c-7", MODE="0660", GROUP="video"
  '';
}
