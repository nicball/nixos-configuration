{ config, pkgs, lib, ... }:

let
  set-perf-level = level: assert (lib.assertOneOf "set-perf-level" level [ 1 0 ]); ''
    for i in /sys/devices/system/cpu/cpufreq/policy*; do
      echo ${if level == 1 then "performance" else "power"} > $i/energy_performance_preference
    done
    echo ${if level == 1 then "balanced" else "low-power"} > /sys/firmware/acpi/platform_profile
  '';
in

{
  # AMD PState
  powerManagement = {
    cpuFreqGovernor = "powersave";
    # cpufreq = {
    #   max = 4000000;
    #   min = 400000;
    # };
  };
  boot.kernelParams = [
    "initcall_blacklist=acpi_cpufreq_init"
    "amd_pstate=active"
    # "iomem=relaxed" # for ryzenadj
    # "amdgpu.ppfeaturemask=0xffffffff" # gpu overclock
  ];
  # services.acpid = {
  #   enable = true;
  #   acEventCommands = ''
  #     vals=($1)
  #     case ''${vals[3]} in
  #       00000000)
  #         ${set-perf-level 0}
  #       ;;
  #       00000001)
  #         ${set-perf-level 1}
  #       ;;
  #     esac
  #   '';
  # };
  # systemd.services.auto-set-epp =
  #   let script = pkgs.writeShellScript "auto-set-epp.sh" ''
  #     if ${pkgs.acpi}/bin/acpi -a | grep off-line > /dev/null; then
  #       ${set-perf-level 0}
  #     else
  #       ${set-perf-level 1}
  #     fi
  #   '';
  #   in {
  #     description = "Automatically set AMD PState EPP on startup";
  #     wantedBy = [ "multi-user.target" ];
  #     after = [ "cpufreq.service" ];
  #     serviceConfig = {
  #       ExecStart = script;
  #       Type = "oneshot";
  #     };
  #   };
  environment.systemPackages = with pkgs; [ radeontop lact ];
  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
  # hardware.amdgpu.initrd.enable = true;
  boot.kernelModules = [ "nct6687" "ryzen_smu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ nct6687d ryzen-smu ];

  systemd.services.fancontrol = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description = "fancontrol - Adjust case fans in relation to max temp of CPU and GPU";
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "fancontrol" (builtins.readFile ./fancontrol.sh);
      Restart = "on-failure";
    };
  };

}
