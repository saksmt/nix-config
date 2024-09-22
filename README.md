# nixos & home-manager config

Opinionated nixos & home-manager configuration with gentoo/emerge concepts of use-flags and package-sets.

Use at your own risk, no guarantees provided whatsoever.

To install run `./install <NAME_OF_CONFIG>`

After install to update use either `os switch` or `home switch` depending on whether you're on nixos or using home
manager.

General configuration concepts:

- installation recipe - world + use-flags, high-level description of what result should be;
- package-set - package-set, set of packages and options to provide some functionality/role;
- feature - use-flag, minor or cross package-set behaviour switch;
- installation-module & installation recipe processor - mostly internal concept for separation of concerns, idea is to
  provide multitude of installation modules all providing their view on what should be done to make recipe a reality.

Dir structure:

- `shared-lib` - reusable sub-flakes intended as shareable and at least more useful for community at large than other
  stuff in this repo
- `custom-packages` - custom packages
- `overlays` - custom overlays
- `installation-modules` - modules providing their view on what result of recipe should be (refer
  to [types](./installation-modules/typedefs.d.ts))
- `installation-modules/common` - modules intended for either hm or nixos
- `installation-modules/nixos` - modules intended exclusively for nixos
- `installation-modules/hm` - modules intended exclusively for home-manager
- `hosts` - host installation recipes
- `hosts/no-host` - non-nixos home-manager installation recipes
- `package-sets` - NixOS modules
