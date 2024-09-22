{
  lib,
  test,
  ...
}:
let
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
  sample-valid-feature = mk-feature {
    is-enabled = true;
    feature-path = [ "path" ];
    includes = [ ];
  };
  ok = d: { ok = d; };
in
{
  "private-lib" = {
    "sameFeature should" = {
      "return true on features with same path" = test {
        expr =
          internalLib.sameFeature
            (mk-feature {
              is-enabled = false;
              feature-path = [
                "some"
                "path"
              ];
              includes = [
                (mk-feature {
                  is-enabled = true;
                  feature-path = [ "other" ];
                  includes = [ ];
                })
              ];
            })
            (mk-feature {
              is-enabled = true;
              feature-path = [
                "some"
                "path"
              ];
              includes = [ ];
            });
        expected = true;
      };

      "return false if paths differ" = test {
        expr =
          internalLib.sameFeature
            (mk-feature {
              is-enabled = true;
              feature-path = [
                "some"
                "other-path"
              ];
              includes = [ ];
            })
            (mk-feature {
              is-enabled = true;
              feature-path = [
                "some"
                "path"
              ];
              includes = [ ];
            });
        expected = false;
      };

      "not break if provided arguments arent features in" = {

        "both arguments" = test {
          expr = internalLib.sameFeature false { };
          expected = false;
        };
        "first argument given" = {
          "invalid feature object" = test {
            expr = internalLib.sameFeature { } sample-valid-feature;
            expected = false;
          };
          "string" = test {
            expr = internalLib.sameFeature "invalid" sample-valid-feature;
            expected = false;
          };
          "boolean" = test {
            expr = internalLib.sameFeature false sample-valid-feature;
            expected = false;
          };
          "number" = test {
            expr = internalLib.sameFeature 123 sample-valid-feature;
            expected = false;
          };
          "array" = test {
            expr = internalLib.sameFeature [
              1
              2
              3
            ] sample-valid-feature;
            expected = false;
          };
        };
        "second argument" = {
          "invalid feature object" = test {
            expr = internalLib.sameFeature sample-valid-feature { };
            expected = false;
          };
          "string" = test {
            expr = internalLib.sameFeature sample-valid-feature "invalid";
            expected = false;
          };
          "boolean" = test {
            expr = internalLib.sameFeature sample-valid-feature false;
            expected = false;
          };
          "number" = test {
            expr = internalLib.sameFeature sample-valid-feature 321;
            expected = false;
          };
          "array" = test {
            expr = internalLib.sameFeature sample-valid-feature [
              1
              2
              3
            ];
            expected = false;
          };
        };
      };
    };

    "isFeature should" = {
      "return true for valid feature" = test {
        expr = internalLib.isFeature sample-valid-feature;
        expected = true;
      };
      "return false for" = {
        "invalid feature object" = test {
          expr = internalLib.isFeature { };
          expected = false;
        };
        "string" = test {
          expr = internalLib.isFeature "invalid";
          expected = false;
        };
        "boolean" = test {
          expr = internalLib.isFeature false;
          expected = false;
        };
        "number" = test {
          expr = internalLib.isFeature 321;
          expected = false;
        };
        "array" = test {
          expr = internalLib.isFeature [
            1
            2
            3
          ];
          expected = false;
        };
      };
    };

    "mapTreeWithPath should" = {
      "return empty object and never call function for" = {
        "invalid tree in the form of" = {
          "string" = test {
            expr = internalLib.mapTreeWithPath (_: throw "should've never been called") "str";
            expected = { };
          };
          "boolean" = test {
            expr = internalLib.mapTreeWithPath (_: throw "should've never been called") false;
            expected = { };
          };
          "number" = test {
            expr = internalLib.mapTreeWithPath (_: throw "should've never been called") 123;
            expected = { };
          };
          "array" = test {
            expr = internalLib.mapTreeWithPath (_: throw "should've never been called") [
              1
              2
              3
            ];
            expected = { };
          };
        };
        "empty tree" = test {
          expr = internalLib.mapTreeWithPath (_: throw "should've never been called") { };
          expected = { };
        };
      };
      "return result of applying given function for each feature in the tree" = test {
        expr = internalLib.mapTreeWithPath (p: v: v.sample // { given-path = p; }) {
          a = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [ "a" ];
            sample = {
              v = 1;
            };
          };
          b.c = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [
              "b"
              "c"
            ];
            sample = {
              v = 2;
            };
          };
        };
        expected = {
          a = {
            v = 1;
            given-path = [ "a" ];
          };
          b.c = {
            v = 2;
            given-path = [
              "b"
              "c"
            ];
          };
        };
      };
    };

    "mapTree should" = {
      "return empty object and never call function for" = {
        "invalid tree in the form of" = {
          "string" = test {
            expr = internalLib.mapTree (_: throw "should've never been called") "str";
            expected = { };
          };
          "boolean" = test {
            expr = internalLib.mapTree (_: throw "should've never been called") false;
            expected = { };
          };
          "number" = test {
            expr = internalLib.mapTree (_: throw "should've never been called") 123;
            expected = { };
          };
          "array" = test {
            expr = internalLib.mapTree (_: throw "should've never been called") [
              1
              2
              3
            ];
            expected = { };
          };
        };
        "empty tree" = test {
          expr = internalLib.mapTree (_: throw "should've never been called") { };
          expected = { };
        };
      };

      "return result of applying given function for each feature in the tree" = test {
        expr = internalLib.mapTree (v: v.sample) {
          a = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [ "a" ];
            sample = 1;
          };
          b.c = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [
              "b"
              "c"
            ];
            sample = 2;
          };
        };
        expected = {
          a = 1;
          b.c = 2;
        };
      };
    };

    "treeValues should" = {
      "return empty list when given" = {
        "invalid tree in the form of" = {
          "string" = test {
            expr = internalLib.treeValues "str";
            expected = [ ];
          };
          "boolean" = test {
            expr = internalLib.treeValues false;
            expected = [ ];
          };
          "number" = test {
            expr = internalLib.treeValues 123;
            expected = [ ];
          };
          "array" = test {
            expr = internalLib.treeValues [
              1
              2
              3
            ];
            expected = [ ];
          };
        };
        "empty tree" = test {
          expr = internalLib.treeValues { };
          expected = [ ];
        };
      };

      "return all features of tree as list" =
        let
          feature-a = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [ "a" ];
            sample = 1;
          };
          feature-b-c = mk-feature {
            is-enabled = true;
            includes = [ ];
            feature-path = [
              "b"
              "c"
            ];
            sample = 2;
          };
        in
        test {
          expr = builtins.sort (a: b: a.sample > b.sample) (
            internalLib.treeValues {
              a = feature-a;
              b.c = feature-b-c;
            }
          );
          expected = builtins.sort (a: b: a.sample > b.sample) [
            feature-a
            feature-b-c
          ];
        };
    };

    "mkUserFacingFeature should" =
      let
        enabled-feature = mk-feature {
          is-enabled = true;
          feature-path = [ "a" ];
        };
        disabled-feature = mk-feature {
          is-enabled = false;
          feature-path = [ "b" ];
        };
        strip-down-to-ops =
          feature:
          builtins.removeAttrs feature [
            "feature-path"
            "disabled"
            "disable"
          ];
        mkUserFacingFeature = internalLib.mkUserFacingFeature {
          modules = {
            mkIf = c: v: {
              MK_IF = {
                condition = c;
                value = v;
              };
            };
          };
        };
        genAttributeTests =
          {
            attribute,
            invert ? false,
          }:
          {
            "enabled feature" = test {
              expr = (mkUserFacingFeature enabled-feature).${attribute};
              expected = !invert;
            };
            "disabled feature" = test {
              expr = (mkUserFacingFeature disabled-feature).${attribute};
              expected = invert;
            };
          };
        genIfTest =
          {
            attribute,
            invert ? false,
          }:
          {
            "enabled feature" = test {
              expr = (mkUserFacingFeature enabled-feature).${attribute} "ENABLED FEATURE VALUE";
              expected = {
                MK_IF = {
                  condition = !invert;
                  value = "ENABLED FEATURE VALUE";
                };
              };
            };

            "disabled feature" = test {
              expr = (mkUserFacingFeature disabled-feature).${attribute} "DISABLED FEATURE VALUE";
              expected = {
                MK_IF = {
                  condition = invert;
                  value = "DISABLED FEATURE VALUE";
                };
              };
            };
          };

        genBoolTest =
          { attribute, op }:
          let
            feature-expr-type = {
              _type = "feature-expression";
            };
            materialize_conditions =
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
              };
            materialize_operators =
              f:
              (builtins.removeAttrs f [
                "or'"
                "and"
                "or_"
                "And"
                "Or"
              ])
              // {
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
              };
            # materialize all lambdas, for and/or materialize to booleans
            materialize_once = f: materialize_conditions (materialize_operators f);
            # materializing all lambdas, for and/or going one level deep (i.e call once normally and then materialize to boolean)
            materialize =
              f:
              materialize_conditions (
                (builtins.removeAttrs f [
                  "or'"
                  "and"
                  "or_"
                  "And"
                  "Or"
                ])
                // {
                  or'_enabled = materialize_once (f.or' { is-enabled = true; });
                  or__enabled = materialize_once (f.or_ { is-enabled = true; });
                  Or_enabled = materialize_once (f.Or { is-enabled = true; });
                  and_enabled = materialize_once (f.and { is-enabled = true; });
                  And_enabled = materialize_once (f.And { is-enabled = true; });

                  or'_disabled = materialize_once (f.or' { is-enabled = false; });
                  or__disabled = materialize_once (f.or_ { is-enabled = false; });
                  Or_disabled = materialize_once (f.Or { is-enabled = false; });
                  and_disabled = materialize_once (f.and { is-enabled = false; });
                  And_disabled = materialize_once (f.And { is-enabled = false; });
                }
              );
          in
          {
            "enabled feature that" = {
              "works with other enabled" = test {
                expr = materialize (
                  strip-down-to-ops ((mkUserFacingFeature enabled-feature).${attribute} enabled-feature)
                );
                expected = materialize (
                  strip-down-to-ops (
                    mkUserFacingFeature (if (op true true) then enabled-feature else disabled-feature)
                  )
                  // feature-expr-type
                );
              };
              "works with other disabled" = test {
                expr = materialize (
                  strip-down-to-ops ((mkUserFacingFeature enabled-feature).${attribute} disabled-feature)
                );
                expected = materialize (
                  strip-down-to-ops (
                    mkUserFacingFeature (if (op true false) then enabled-feature else disabled-feature)
                  )
                  // feature-expr-type
                );
              };
            };

            "disabled feature that" = {
              "works with other enabled" = test {
                expr = materialize (
                  strip-down-to-ops ((mkUserFacingFeature disabled-feature).${attribute} enabled-feature)
                );
                expected = materialize (
                  strip-down-to-ops (
                    mkUserFacingFeature (if (op false true) then enabled-feature else disabled-feature)
                  )
                  // feature-expr-type
                );
              };
              "works with other disabled" = test {
                expr = materialize (
                  strip-down-to-ops ((mkUserFacingFeature disabled-feature).${attribute} disabled-feature)
                );
                expected = materialize (
                  strip-down-to-ops (
                    mkUserFacingFeature (if (op false false) then enabled-feature else disabled-feature)
                  )
                  // feature-expr-type
                );
              };
            };
          };
      in
      {
        "provide object with attribute" = {
          "is-enabled for" = genAttributeTests { attribute = "is-enabled"; };
          "isEnabled for" = genAttributeTests { attribute = "isEnabled"; };
          "are-enabled for" = genAttributeTests { attribute = "are-enabled"; };
          "areEnabled for" = genAttributeTests { attribute = "areEnabled"; };

          "is-disabled for" = genAttributeTests {
            attribute = "is-disabled";
            invert = true;
          };
          "isDisabled for" = genAttributeTests {
            attribute = "isDisabled";
            invert = true;
          };
          "are-disabled for" = genAttributeTests {
            attribute = "are-disabled";
            invert = true;
          };
          "areDisabled for" = genAttributeTests {
            attribute = "areDisabled";
            invert = true;
          };
        };

        "provide object with method" = {
          "if-enabled for" = genIfTest { attribute = "if-enabled"; };
          "when-enabled for" = genIfTest { attribute = "when-enabled"; };

          "ifEnabled for" = genIfTest { attribute = "ifEnabled"; };
          "whenEnabled for" = genIfTest { attribute = "whenEnabled"; };

          "if-disabled for" = genIfTest {
            attribute = "if-disabled";
            invert = true;
          };
          "when-disabled for" = genIfTest {
            attribute = "when-disabled";
            invert = true;
          };

          "ifDisabled for" = genIfTest {
            attribute = "ifDisabled";
            invert = true;
          };
          "whenDisabled for" = genIfTest {
            attribute = "whenDisabled";
            invert = true;
          };
        };

        "provide object with boolean-like operator" = {
          "or' for" = genBoolTest {
            attribute = "or'";
            op = a: b: a || b;
          };
          "or_ for" = genBoolTest {
            attribute = "or_";
            op = a: b: a || b;
          };
          "Or for" = genBoolTest {
            attribute = "Or";
            op = a: b: a || b;
          };

          "and for" = genBoolTest {
            attribute = "and";
            op = a: b: a && b;
          };
          "And for" = genBoolTest {
            attribute = "And";
            op = a: b: a && b;
          };
        };
      };
  };
}
