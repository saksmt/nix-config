# nix-features

Feature toggling (like in cargo, or like use-flags in gentoo) for nix and nixos.

Features of features:
 - Zero dependency (nixpkgs are entirely optional and are used for nixosModules integration and throwing errors)
 - Arguably easy to use
 - Support enabling/disabling by default
 - Support dependency between features
 - Don't mangle source definition tree (i.e you're free to nest your features and use `dev.low-level.c.utils.cmake` as a feature name/path)

## Usage

### 1. Import library

flake.nix:
```nix
{
  inputs = {
    nixpkgs.url = "";
    
    nix-features.url = "github:saksmt/nix-config?dir=shared-lib/nix-features";
    nix-features.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { nix-features, nixpkgs, ... }:
  let
    nix-features-lib = nix-features.nixLibs.default nixpkgs;
  in {};
}
```

### 2. Define your features/use-flags


```nix
nix-features-lib: {
  defined-features = nix-features-lib.define-features-or-throw ({feature, self}: {
    X = feature { default-enabled = true; };
    
    dev = {
      scala = feature {};
      rust = feature {};
      
      all = feature { includes = [ self.dev.scala self.dev.rust ]; };
    };
  });
}
```

Example with usage in flake:
```nix
{
  outputs = { nix-features, nixpkgs, ... }:
  let
    nix-features-lib = nix-features.nixLibs.default nixpkgs;
    defined-features = nix-features-lib.define-features-or-throw ({feature, self}: {
      X = feature { default-enabled = true; };
      
      dev = {
        scala = feature {};
        rust = feature {};
        
        all = feature { includes = [ self.dev.scala self.dev.rust ]; };
      };
    });
  in {
    nixosConfigurations.my-pc = nixpkgs.lib.nixosSystem {
      modules = [];
      specialArgs = { inherit defined-features; };
    };
  };
}
```

### 3. Use them to enable/disable stuff

```nix
{ config, pkgs, features, ... }: {
  environment.systemPackages = features.dev.scala.if-enabled [ pkgs.scala-cli ];
  networking.hostName =
    if (features.dev.scala.Or(features.dev.rust).is-enabled) 
    then "dev-machine"
    else "noob-machine";
  programs.java = features.dev.scala.whenEnabled { # convinient alias to lib.mkIf ${feature}.isEnabled
    enable = true;
  };
}
```

### 4. Configure features


```nix
{ nix-features-lib, defined-features }: {
  features = with defined-features; nix-features-lib.assign-features defined-features [
    X.disable
    dev.all
  ];
}
```

Example usage in flake (of course you can extract sections of those definitions into separate files):
```nix
{
  outputs = { nix-features, nixpkgs, ... }:
  let
    nix-features-lib = nix-features.nixLibs.default nixpkgs;
    defined-features = nix-features-lib.define-features-or-throw ({feature, self}: {
      X = feature { default-enabled = true; };
      
      dev = {
        scala = feature {};
        rust = feature {};
        
        all = feature { includes = [ self.dev.scala self.dev.rust ]; };
      };
    });
  in {
    nixosConfigurations.my-pc = let
      features = with defined-features; nix-features.lib [
        X.disable
        dev.all
      ]; 
    in nixpkgs.lib.nixosSystem {
      modules = [];
      specialArgs = { inherit features; };
    };
  };
}
```

## Docs

For more info about available methods and general logic of features refer to [type definitions](src/typedefs.d.ts)
