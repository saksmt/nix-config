{
  lib,
  config,
  pkgs,
  utils,
  ...
}:
{
  services.xserver.displayManager.xserverArgs = ["$DPI_OPT"];
  # handle custom kernel params:
  #  - livecd.set_dpi - set DPI
  boot.postBootCommands = ''
  dpi=
  xserver_dpi_opt=
  for o in $(</proc/cmdline); do
        case "$o" in
          livecd.set_dpi=*)
            set -- $(IFS==; echo $o)
            dpi="''${2}"
            ;;
        esac
  done
  if [[ n"$dpi" != n ]]; then
    echo "Setting DPI to $dpi"
    xserver_dpi_opt="-dpi ''${dpi}"
    font_size=
    if (( $dpi <= 96 )); then
      font_size=16
    elif (( $dpi <= 120 )); then
      font_size=20
    elif (( $dpi <= 144 )); then
      font_size=24
    elif (( $dpi <= 168 )); then
      font_size=28
    else
      font_size=32
    fi
    echo "Computed font size based on DPI: $font_size"
    # only support for "scaling" terminus font in tty
    echo "Loading existing vconsole.conf"
    echo "--------------------"
    cat /etc/vconsole.conf
    echo "--------------------"
    source /etc/vconsole.conf
    font_path=
    font_ext=
    if [[ "''${FONT:0:1}" = "/" ]] || [[ "''${FONT:0:2}" == "./" ]]; then
      font_path="$(dirname "$FONT")"
      if [[ "''${font_path}" == "." ]]; then
        font_path=""
      else
        font_path="$font_path/"
      fi
      FONT="$(basename "$FONT")"

      font_ext="$(echo "$FONT" | cut -d. -f2-)"
      if [[ n"''${font_ext}" != "n" ]]; then
        font_ext=".$font_ext"
      fi

      FONT="$(echo "$FONT" | cut -d. -f1)"
    fi
    if [[ "''${FONT:0:4}" = 'ter-' ]]; then
      echo 'Setting "scaled" variant of terminus font for tty'
      encoding="''${FONT:4:1}"
      variant="''${FONT:7:1}"
      tty_font="''${font_path}ter-$encoding$font_size$variant$font_ext"
      echo "Setting tty font to $tty_font"
      setfont "$tty_font"
      echo 'Replacing font in vconsole.conf with "scaled" version'
      # removing symlink to store
      rm -f /etc/vconsole.conf
      # copying content from store over as a normal file
      cat /etc/static/vconsole.conf > /etc/vconsole.conf
      # adding override
      echo "# Overridden by kernel boot option:" >> /etc/vconsole.conf
      echo "FONT=$tty_font" >> /etc/vconsole.conf
      # dropping symlink to store from /etc/static
      rm -f /etc/static/vconsole.conf
      # restoring file in /etc/static as a symlink to freshly generated file
      ln -s /etc/vconsole.conf /etc/static/vconsole.conf
    else
      echo '"Scaling" of tty fonts is only supported for terminus fonts'
    fi
  fi
  if [ -f /etc/systemd/system/display-manager.service ]; then
    echo "Passing DPI to xserver"
    mkdir -p /run/systemd/system/display-manager.service.d
    echo '[Service]' > /run/systemd/system/display-manager.service.d/override.conf
    echo "Environment='DPI_OPT=$xserver_dpi_opt'" >> /run/systemd/system/display-manager.service.d/override.conf
    echo "Setting FONT_SIZE to $font_size for display manager"
    echo "Environment='FONT_SIZE=$font_size'" >> /run/systemd/system/display-manager.service.d/override.conf
    echo "Setting FONT_SIZE environment variable to $font_size for the rest of the world"
    echo >> /etc/profile.local
    echo "export FONT_SIZE=$font_size" >> /etc/profile.local
    chmod +x /etc/profile.local
  fi
'';
}
