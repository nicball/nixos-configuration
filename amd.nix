{ pkgs, ... }:

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
          for i in /sys/devices/system/cpu/cpufreq/policy*; do
            echo power > $i/energy_performance_preference
          done
        ;;
        00000001)
          for i in /sys/devices/system/cpu/cpufreq/policy*; do
            echo performance > $i/energy_performance_preference
          done
        ;;
      esac
    '';
  };
  systemd.services.auto-set-epp =
    let script = pkgs.writeShellScript "auto-set-epp.sh" ''
      if ${pkgs.acpi}/bin/acpi -a | grep off-line > /dev/null; then
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo power > $i/energy_performance_preference
        done
      else
        for i in /sys/devices/system/cpu/cpufreq/policy*; do
          echo performance > $i/energy_performance_preference
        done
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
}
