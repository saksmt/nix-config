{ whenAndroidDev, ... } : { config, pkgs, ... }:

whenAndroidDev {
    services.udev.packages = [ pkgs.android-udev-rules ];
    programs.adb.enable = true;
}
