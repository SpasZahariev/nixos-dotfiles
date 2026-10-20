# MangoHud overlay for Steam games.
#
# * on screen: FPS, frame time, GPU/CPU load, temperatures, VRAM/RAM
# * measurement run: 97th percentile, average, 1% low and 0.1% low frame rate
#   (the 1% low is the reciprocal of the 99th percentile frame time, so a
#   99th percentile frame time of 33.3 ms is a 1% low of 30 FPS)
#
# The overlay is started per game with the Steam launch option
# "mangohud %command%" - the wrapper is put into the Steam client PATH below.
# The measurement runs automatically (autostart_log/log_duration) and shows its
# summary on screen for a few seconds when it ends. The per frame CSV of every
# run is written to ~/mangologs.
#
# Local overrides (they win over /etc/MangoHud.conf) go into
# ~/.config/MangoHud/MangoHud.conf or ~/.config/MangoHud/<game>.conf.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.mangohud;

  # Prints the frame rate percentiles of a MangoHud CSV log. The math mirrors
  # MangoHud itself (frametimes sorted descending, index = p * n - 1,
  # fps = 1000 / frametime) so the numbers match the on screen summary.
  # The 1% low is shown as both frame rate and 99th percentile frame time.
  statsScript = pkgs.writeShellScriptBin "mangohud-stats" ''
    set -euo pipefail

    log="''${1:-}"
    if [[ -z "$log" ]]; then
      log="$(ls -t "$HOME"/mangologs/*.csv 2>/dev/null | grep -v '_summary\.csv$' | head -n 1 || true)"
    fi

    if [[ -z "$log" || ! -f "$log" ]]; then
      echo "no MangoHud log found in $HOME/mangologs" >&2
      exit 1
    fi

    frametimes="$(mktemp)"
    trap 'rm -f "$frametimes"' EXIT

    # the frame data starts after the "fps,frametime,..." header line
    awk -F, '/^fps,frametime/ { data = 1; next } data && NF > 1 && $2 != "" { print $2 }' \
      "$log" | sort -n -r > "$frametimes"

    frames="$(wc -l < "$frametimes")"
    if [[ "$frames" -eq 0 ]]; then
      echo "no frame data in $log" >&2
      exit 1
    fi

    echo "log: $log"
    awk -v n="$frames" '
      { ft[NR] = $1 }
      function at(val,   idx) {
        idx = int(val * n) - 1
        if (idx < 1) idx = 1
        if (idx > n) idx = n
        return ft[idx]
      }
      END {
        printf "99th percentile / 1%% low  : %8.2f ms   %6.1f fps\n", at(0.01), 1000 / at(0.01)
        printf "99.9th percentile / 0.1%%  : %8.2f ms   %6.1f fps\n", at(0.001), 1000 / at(0.001)
      }
    ' "$frametimes"
  '';
in
{
  options.programs.mangohud = {
    enable = lib.mkEnableOption "MangoHud overlay";

    autostartLog = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = ''
        Seconds after a game started before the measurement run begins. Set to 0
        to only measure manually with the Shift+F2 keybind.
      '';
    };

    logDuration = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = ''
        Length of a measurement run in seconds. When the run ends, MangoHud
        shows the percentile summary (97th percentile, average, 1% low, 0.1%
        low) on screen and writes the CSV log.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.mangohud
      statsScript
    ];

    # puts the "mangohud" wrapper into the Steam client PATH so that it can be
    # used as a launch option ("mangohud %command%")
    programs.steam.extraPackages = [ pkgs.mangohud ];

    # MangoHud reads /etc/MangoHud.conf when the user has no
    # ~/.config/MangoHud/MangoHud.conf
    environment.etc."MangoHud.conf".text = ''
      # Managed by NixOS (nixos/nixosModules/programs/mangohud.nix)

      # always visible overlay
      fps
      frametime
      gpu_stats
      cpu_stats
      gpu_temp
      cpu_temp
      vram
      ram
      resolution

      # percentiles of the measurement run that is shown on screen when it ends
      fps_metrics=0.01,0.001

      # automatic measurement run: ${toString cfg.autostartLog}s after the game
      # started, lasting ${toString cfg.logDuration}s
      autostart_log=${toString cfg.autostartLog}
      log_duration=${toString cfg.logDuration}

      # per frame CSV logs, open them with "mangoapp <file>"
      output_folder=~/mangologs
    '';

    # ~/mangologs, MangoHud does not create it and the game has to write into it
    systemd.user.tmpfiles.rules = [ "d %h/mangologs 0755 - - -" ];
  };
}
