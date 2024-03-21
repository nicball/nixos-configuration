{ pkgs, config, ... }:

{
  # Switch CapsLock and Left Ctrl
  ## evdev:atkbd:dmi:bvnLENOVO:bvrJ6CN40WW:bd*:svnLENOVO:pn21D1:pvr*:*
  services.udev.extraHwdb = ''
    evdev:atkbd:*
     KEYBOARD_KEY_3a=leftctrl
     KEYBOARD_KEY_1d=capslock
  '';

  ## For keyboard patch
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  ## For realtek wifi
  boot.extraModulePackages = [ (pkgs.rtw89.override { linux = config.boot.kernelPackages.kernel; }) ];
  # hardware.enableRedistributableFirmware = true;
  boot.blacklistedKernelModules = [ "rtw89_8852be" ];
}
