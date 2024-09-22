{
  lib,
  test,
  ...
}:
let
  featuresLib = import ../as-lib.nix { inherit lib; };
  internalLib = import ../private-lib.nix { inherit lib; };
  append-disable =
    feature:
    feature
    // rec {
      disable = feature // {
        is-enabled = false;
      };
      disabled = disable;
    };
  mk-feature =
    f:
    append-disable (
      f
      // {
        _type = "feature";
      }
    );
  ok = d: { ok = d; };
in
{
  "define-features should" = {
    "return successful result when" = {

      "given empty input" = test {
        expr = featuresLib.define-features ({ self, feature }: { });
        expected = {
          ok = { };
        };
      };

      "given simple input" = test {
        expr = featuresLib.define-features (
          { self, feature }:
          {
            simple-feature = feature { };
          }
        );
        expected = ok {
          simple-feature = mk-feature {
            default-enabled = false;
            includes = [ ];
            feature-path = [ "simple-feature" ];
            is-enabled = true;
          };
        };
      };

      "given tree input" = test {
        expr = featuresLib.define-features (
          { self, feature }:
          {
            toplevel = feature { };
            inner.level = feature { default-enabled = true; };
            deeper.inner.level = feature { };
          }
        );
        expected = ok {
          toplevel = mk-feature {
            default-enabled = false;
            includes = [ ];
            feature-path = [ "toplevel" ];
            is-enabled = true;
          };
          inner.level = mk-feature {
            default-enabled = true;
            includes = [ ];
            feature-path = [
              "inner"
              "level"
            ];
            is-enabled = true;
          };
          deeper.inner.level = mk-feature {
            default-enabled = false;
            includes = [ ];
            feature-path = [
              "deeper"
              "inner"
              "level"
            ];
            is-enabled = true;
          };
        };
      };

      "given input with inclcudes" = test {
        expr = featuresLib.define-features (
          { feature, self }:
          {
            dependency = feature { };
            dependency-usage = feature { includes = [ self.dependency ]; };
          }
        );
        expected = ok {
          dependency = mk-feature {
            default-enabled = false;
            includes = [ ];
            feature-path = [ "dependency" ];
            is-enabled = true;
          };
          dependency-usage = mk-feature {
            default-enabled = false;
            includes = [
              (mk-feature {
                default-enabled = false;
                includes = [ ];
                feature-path = [ "dependency" ];
                is-enabled = true;
              })
            ];
            feature-path = [ "dependency-usage" ];
            is-enabled = true;
          };
        };
      };

    };

    "fail when" = {

      "given anything else aside from features" = test {
        expr = featuresLib.define-features (
          { feature, self }:
          {
            some = {
              nested = {
                path = {
                  with-invalid = [ "value" ];
                };
              };
            };
          }
        );
        expected = {
          fail = [
            {
              path = [
                "some"
                "nested"
                "path"
                "with-invalid"
              ];
              value = [ "value" ];
              reason = "invalid feature definition";
            }
          ];
        };
      };

    };
  };

  "define-features-or-throw should" = {
    "succeed on correct input" = test {
      expr = featuresLib.define-features-or-throw ({ feature, self }: { });
      expected = { };
    };

    "fail on invalid input" = test {
      expr = featuresLib.define-features-or-throw (
        { feature, self }:
        {
          invalid = "invalid value";
        }
      );
      expectedError.type = "ThrownError";
      expectedError.msg = "invalid feature definition at path \\[invalid\\] with value: \"invalid value\"";
    };
  };

  "assign-features should" = rec {
    libOverride = {
      modules = {
        mkIf = x: c: if x then c else { not = c; };
      };
    };
    assign-features = featuresLib._assign-features libOverride;

    sample-features = featuresLib.define-features-or-throw (
      { feature, self }:
      {
        enabled-by-default = feature { default-enabled = true; };
        sample-a = feature { };
        sample-b = feature { };
        with-dependencies = feature {
          includes = [
            self.sample-a
            self.sample-b
          ];
        };
      }
    );

    userFacing = internalLib.mapTree (internalLib.mkUserFacingFeature libOverride);
    materialize = internalLib.mapTree (
      f:
      (builtins.removeAttrs f [
        "if-enabled"
        "if-disabled"
        "ifEnabled"
        "ifDisabled"
        "when-enabled"
        "when-disabled"
        "whenEnabled"
        "whenDisabled"

        "or'"
        "and"
        "or_"
        "And"
        "Or"
      ])
      // {
        if-enabled_result = f.if-enabled { source = "if-enabled"; };
        if-disabled_result = f.if-disabled { source = "if-disabled"; };
        ifEnabled_result = f.ifEnabled { source = "ifEnabled"; };
        ifDisabled_result = f.ifDisabled { source = "ifDisabled"; };
        when-enabled_result = f.when-enabled { source = "when-enabled"; };
        when-disabled_result = f.when-disabled { source = "when-disabled"; };
        whenEnabled_result = f.whenEnabled { source = "whenEnabled"; };
        whenDisabled_result = f.whenDisabled { source = "whenDisabled"; };

        or'_result_true = (f.or' { is-enabled = true; }).is-enabled;
        and_result_true = (f.and { is-enabled = true; }).is-enabled;
        or__result_true = (f.or_ { is-enabled = true; }).is-enabled;
        And_result_true = (f.And { is-enabled = true; }).is-enabled;
        Or_result_true = (f.Or { is-enabled = true; }).is-enabled;

        or'_result_false = (f.or' { is-enabled = false; }).is-enabled;
        and_result_false = (f.and { is-enabled = false; }).is-enabled;
        or__result_false = (f.or_ { is-enabled = false; }).is-enabled;
        And_result_false = (f.And { is-enabled = false; }).is-enabled;
        Or_result_false = (f.Or { is-enabled = false; }).is-enabled;
      }
    );

    "include defaults" = test {
      expr = materialize (assign-features sample-features (with sample-features; [ ]));
      expected = materialize (
        userFacing (
          sample-features
          // {
            enabled-by-default = sample-features.enabled-by-default // {
              is-enabled = true;
            };
            sample-a = sample-features.sample-a // {
              is-enabled = false;
            };
            sample-b = sample-features.sample-b // {
              is-enabled = false;
            };
            with-dependencies = sample-features.with-dependencies // {
              is-enabled = false;
            };
          }
        )
      );
    };

    "include dependencies" = test {
      expr = materialize (assign-features sample-features (with sample-features; [ with-dependencies ]));
      expected = materialize (
        userFacing (
          sample-features
          // {
            enabled-by-default = sample-features.enabled-by-default // {
              is-enabled = true;
            };
            sample-a = sample-features.sample-a // {
              is-enabled = true;
            };
            sample-b = sample-features.sample-b // {
              is-enabled = true;
            };
            with-dependencies = sample-features.with-dependencies // {
              is-enabled = true;
            };
          }
        )
      );
    };

    "include explicitly enabled" = test {
      expr = materialize (assign-features sample-features (with sample-features; [ sample-a ]));
      expected = materialize (
        userFacing (
          sample-features
          // {
            enabled-by-default = sample-features.enabled-by-default // {
              is-enabled = true;
            };
            sample-a = sample-features.sample-a // {
              is-enabled = true;
            };
            sample-b = sample-features.sample-b // {
              is-enabled = false;
            };
            with-dependencies = sample-features.with-dependencies // {
              is-enabled = false;
            };
          }
        )
      );
    };

    "include disable default if explicitly disabled" = test {
      expr = materialize (
        assign-features sample-features (with sample-features; [ enabled-by-default.disabled ])
      );
      expected = materialize (
        userFacing (
          sample-features
          // {
            enabled-by-default = sample-features.enabled-by-default // {
              is-enabled = false;
            };
            sample-a = sample-features.sample-a // {
              is-enabled = false;
            };
            sample-b = sample-features.sample-b // {
              is-enabled = false;
            };
            with-dependencies = sample-features.with-dependencies // {
              is-enabled = false;
            };
          }
        )
      );
    };

    "exclude explicitly disabled from dependencies dependencies" = test {
      expr = materialize (
        assign-features sample-features (
          with sample-features;
          [
            with-dependencies
            sample-a.disabled
          ]
        )
      );
      expected = materialize (
        userFacing (
          sample-features
          // {
            enabled-by-default = sample-features.enabled-by-default // {
              is-enabled = true;
            };
            sample-a = sample-features.sample-a // {
              is-enabled = false;
            };
            sample-b = sample-features.sample-b // {
              is-enabled = true;
            };
            with-dependencies = sample-features.with-dependencies // {
              is-enabled = true;
            };
          }
        )
      );
    };

  };

}
