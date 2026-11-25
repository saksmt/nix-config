{
  module-for = [
    "hm"
    "nixos"
    "darwin"
  ];
  # one of "latte", "frappe", "macchiato", "mocha" (light -> dark)
  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "macchiato";
  };
}
