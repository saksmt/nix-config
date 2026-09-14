This is a dirty hack to support both linux and darwin in one flake.

It also allows for some modularization of flake

Use `./regenerate` to update the flake.nix file in the root of repo.

Use `./lock` as an alias to `nix flake` with lock file options properly set
