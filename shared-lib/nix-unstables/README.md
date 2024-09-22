# nix-unstables

Syntactic sugar for managing your overlaying with unstable packages in nix

Main selling point:
```nix
_: {
  installation.unstable-sources = { source }: {
    unstable = source (import "...");
    master   = source (import "...");
  };
  installation.unstables = { from, copy-of, unstable, master }: {
    jetbrains.idea-ultimate = from unstable;
    jetbrains.rust-rover    = from master;
  };
}
```

instead of:
```nix
let
  nixpkgs-unstable = import "...";
  nixpkgs-master = import "...";
in
_: {
  nixpkgs.overlays = [
    (prev: final: { # <- good luck not accidentally flipping them over
      jetbrains = final.jetbrains // { # <- you better not forget this part! (otherwise: attribute clion missing!)
        idea-ultimate = nixpkgs-unstable.jetbrains.idea-ultimate;
        rust-rover = nixpkgs-master.jetbrains.rust-rover;
      };
    })
  ];
}
```

## Usage

### 1. Import library

flake.nix:
```nix
{
  inputs = {
    nixpkgs.url = "";

    nix-unstables.url = "github:saksmt/nix-config?dir=shared-lib/nix-unstables";
    nix-unstables.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-unstables, nixpkgs, ... }:
    let
      nix-unstables-lib = nix-unstables.nixLibs.default;
    in
    { };
}
```

### 2. Define you package sources

#### As library
```nix
nixpkgs-unstable: nixpkgs-master: nix-unstables-lib:
nix-unstables-lib.make-source-tree {
  unstable = nix-unstables-lib.define-source nixpkgs-unstable;
  master = nix-unstables-lib.define-source nixpkgs-master;
}
```

### 3. Define your overlaying logic

(entire example, assuming inputs from flake)
```nix
{ inputs, config, ... }:
let
  inherit (inputs.nix-unstables-lib) define-source;
  unstablesLib = inputs.nix-unstables-lib;
  unstableSources = unstablesLib.make-source-tree {
    unstable = define-source (import inputs.nixpkgs-unstable { system = config.system; });
    master = define-source (import inputs.nixpkgs-master { system = config.system; });
  };
  unstablesConf = unstablesLib.compile-unstables-config unstableSources (
    {
      unstable,
      master,
      from,
      copy-of,
    }:
    {
      jetbrains.idea-ultimate = from master;
      my-unstable-scala-cli = from unstable.scala-cli;

      all-unstable-packages = copy-of unstable;
    }
  );
in
{
  nixpkgs.overlays = [ (unstablesLib.overlay unstablesConf) ];
}
```

### 4. Use it!

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate # will pull in idea from nixpkgs master
    jetbrains.rust-rover # will pull rust-rover from stable/default configured nixpkgs
    my-unstable-scala-cli # will pull scala-cli from unstable nixpkgs

    all-unstable-packages.stack # will pull haskell stack from unstable nixpkgs
  ];
}
```
