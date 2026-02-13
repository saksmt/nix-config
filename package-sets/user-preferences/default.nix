{ pkgs, lib, ... }:
{
  module-for = [ "hm" ];

  # one of "latte", "frappe", "macchiato", "mocha" (light -> dark)
  catppuccin.flavor = "macchiato";
  programs.btop = {
    settings = {
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc";
      update_ms = 1500;
      proc_sorting = "cpu lazy";
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_left = false;
      proc_filter_kernel = true;
      cpu_graph_upper = "user";
      cpu_graph_lower = "total";
      show_gpu_info = "Auto";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      show_uptime = true;
      check_temp = true;
      show_coretemp = true;
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      mem_graphs = false;
      mem_below_net = false;
      show_swap = true;
      swap_disk = false;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = true;
      show_io_stat = true;
      io_mode = false;
      net_auto = true;
      net_sync = true;
      show_battery = true;
      selected_battery = "Auto";
      show_battery_watts = true;

      presets = builtins.concatStringsSep " " (
        builtins.map (builtins.concatStringsSep ",") [
          [
            "cpu:0:default"
            "mem:1:default"
            "net:0:default"
          ]
          [ "proc:0:default" ]
          [ "gpu0:0:default" ]
        ]
      );
    };
  };

  programs.git = {
    settings = {
      init.defaultBranch = "master";
    };
    ignores = [
      "test.*"
      "non-git_local-overrides.*"
      "ignoreme/"

      ".idea/"
      "*.iml"
      "*.ipr"
      "*.iws"

      "out/"
      ".bloop/"
      ".attach_pid*"

      # vim
      "*.swp"
      "*~"

      # emacs
      "\#*\#"
      ".\#*"
    ];
  };

  xdg.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "application/pdf" = [
      "firefox.desktop"
    ];

    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
  };

  # mark zsh initialized, useful when it is configured in nixos and hm has no config for it whatsoever
  shells.zsh.enable = lib.mkDefault true;
  shells.zsh.rc-extra.bottom = lib.mkDefault ''
    # part of your config may reside somewhere globally!
  '';
}
