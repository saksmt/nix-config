{
  features,
  config,
  ...
}:
with features;
{
  module-for = [
    "hm"
  ];

  home.file.".config/opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/opencode/opencode.generated.json";
}