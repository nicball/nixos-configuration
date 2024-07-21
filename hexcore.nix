{ ... }:

{
  services.udev.extraRules = ''
    SUBSYSTEM=="input", GROUP="input", MODE="0666"
    # For ANNE PRO
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710",MODE="0666", GROUP="plugdev"
    # For ANNE PRO 2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008",MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009",MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292",MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293",MODE="0666", GROUP="plugdev"
    # For HEXCORE
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3311", MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3311", MODE="0666", GROUP="plugdev"
    # BLE
    KERNELS=="*:000D:F0E0.*" SUBSYSTEMS=="hid" DRIVERS=="hid-generic", MODE="0666", GROUP="plugdev"
    KERNELS=="*:07D7:0000.*" SUBSYSTEMS=="hid" DRIVERS=="hid-generic", MODE="0666", GROUP="plugdev"
  '';
}
