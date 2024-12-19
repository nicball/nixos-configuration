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
  powerManagement.cpuFreqGovernor = "powersave";
  boot.kernelModules = [ "amd_pstate" ];
  boot.kernelParams = [
    "initcall_blacklist=acpi_cpufreq_init"
    "amd_pstate=active"
    "iomem=relaxed" # for ryzenadj
  ];
  services.acpid = {
    enable = true;
    acEventCommands = ''
      vals=($1)
      case ''${vals[3]} in
        00000000)
          ${set-perf-level 0}
        ;;
        00000001)
          ${set-perf-level 1}
        ;;
      esac
    '';
  };
  systemd.services.auto-set-epp =
    let script = pkgs.writeShellScript "auto-set-epp.sh" ''
      if ${pkgs.acpi}/bin/acpi -a | grep off-line > /dev/null; then
        ${set-perf-level 0}
      else
        ${set-perf-level 1}
      fi
    '';
    in {
      description = "Automatically set AMD PState EPP on startup";
      wantedBy = [ "multi-user.target" ];
      after = [ "cpufreq.service" ];
      serviceConfig = {
        ExecStart = script;
        Type = "oneshot";
      };
    };
  environment.systemPackages = with pkgs; [ ryzenadj radeontop ];
  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
}
