[{ name = "Home"; value = "home"; extends = [ "home-like" ]; }
 { name = "HomeLike"; value = "home-like"; }
 { name = "PC"; value = "pc"; }
 { name = "Work"; value = "work"; extends = ["work-like"]; }
 { name = "WorkLike"; value = "work-like"; }
 { name = "Laptop"; value = "laptop"; }
 { name = "EFI"; value = "efi"; }
 { name = "DevOracle"; value = "dev/oracle"; }
 { name = "Dev"; value = "dev"; extends = [ "dev/oracle" ]; }
 { name = "NoX"; value = "no-x"; }
 { name = "Server"; value = "server"; }
 { name = "MediaServer"; value = "media-server"; extends = ["no-x" "server"]; }
 { name = "Nvidia"; value = "nVidia"; }
 { name = "NvidiaPrimeOffload"; value = "nVidia-prime-offload"; extends = [ "laptop" "nVidia" ]; }
 { name = "NvidiaPrimeSync"; value = "nVidia-prime-sync"; extends = [ "laptop" "nVidia" ]; }
 { name = "IntelGpu"; value = "intel-gpu"; }
 { name = "Guitar"; value = "guitar"; }
 { name = "HiDPI"; value = "hidpi"; }
 { name = "AndroidDev"; value = "android-dev"; }
 { name = "Gaming"; value = "gaming"; }
 { name = "Bluetooth"; value = "bluetooth"; }
]
