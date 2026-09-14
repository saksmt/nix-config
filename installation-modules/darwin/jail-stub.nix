{ self, ... }@inputs:
with (import (self.outPath + "/installation-modules/lib.nix"));

includeAllRelative self
  [
    "/installation-modules/common/jail-nix.nix"
  ]
  (
    inputs
    // {
      jail-nix = {
        lib.extend = (
          extensionFunction:
          let
            apiToStub = [
              "compose"
              "try-readonly"
              "add-runtime"
              "add-cleanup"
              "try-ro-bind"
              "try-rw-bind"
              "noescape"
              "add-pkg-deps"
              "bind-pkg"
              "write-text"
              "set-env"
              "set-hostname"
              "fake-passwd"
              "mount-cwd"
              "time-zone"
              "readonly-paths-from-var"
              "no-new-session"
              "defer"
              "wrap-entry"
              "try-fwd-env"
              "unsafe-add-raw-args"
              "network"
              "try-readwrite"
              "set-argv"
            ];

            # return value does not matter
            mkStub =
              _: _: _: _: _:
              { };
            jailNixLibStubs = builtins.listToAttrs (
              builtins.map (name: {
                name = name;
                value = mkStub;
              }) apiToStub
            );
            extended = extensionFunction jailNixLibStubs;
            extensionCombinators = builtins.attrNames extended;
            extendedStubs = builtins.listToAttrs (
              builtins.map (name: {
                name = name;
                value = mkStub;
              }) extensionCombinators
            );
            jailFunction =
              name: pkg: combinators:
              pkg;
          in
          jailFunction // { combinators = jailNixLibStubs // extendedStubs; }
        );
      };
    }
  )
