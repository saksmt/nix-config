{ config, pkgs, ... }:

{
  boot.extraModulePackages = [ pkgs.linuxPackages.nvidia_x11 ];
  boot.extraModprobeConfig = ''
      options nvidia-drm modeset=1
      options bbswitch load_state=1
  '';
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "bbswitch" ];

  # TODO: try to disable display manager and check if GPU powered on after startup

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

}
