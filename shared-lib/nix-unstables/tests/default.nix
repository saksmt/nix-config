{ test, ... }:
with (import ../overlay.nix);
let
  mk-source-raw = path: value: value // { ${__PRIVATE__.sourceLocationKey} = path; };
in
{
  "make-source-tree should" = {
    "produce correct tree when" = {
      "empty input" = test {
        expr = make-source-tree { };
        expected = { };
      };

      "input without sources" = test {
        expr = make-source-tree {
          a = 123;
          b.c = 321;
        };
        expected = {
          a = 123;
          b.c = 321;
        };
      };

      "input without nesting" = test {
        expr = make-source-tree {
          unstable = define-source { value = 123; };
          forked = define-source { value = 321; };
        };
        expected = {
          unstable = mk-source-raw [ "unstable" ] { value = 123; };
          forked = mk-source-raw [ "forked" ] { value = 321; };
        };
      };

      "input with nesting" = test {
        expr = make-source-tree {
          nixpkgs.unstable = define-source { value = 123; };
          nixpkgs.forked = define-source { value = 321; };

          moz-overlay.stable = define-source { value = "123"; };
          moz-overlay.unstable = define-source { value = "321"; };

          some-other-source = define-source { value = false; };
        };

        expected = {
          nixpkgs = {
            unstable = mk-source-raw [
              "nixpkgs"
              "unstable"
            ] { value = 123; };
            forked = mk-source-raw [
              "nixpkgs"
              "forked"
            ] { value = 321; };
          };

          moz-overlay = {
            stable = mk-source-raw [
              "moz-overlay"
              "stable"
            ] { value = "123"; };
            unstable = mk-source-raw [
              "moz-overlay"
              "unstable"
            ] { value = "321"; };
          };

          some-other-source = mk-source-raw [ "some-other-source" ] { value = false; };
        };
      };

    };
  };

  "compile-unstables-config should" =
    let
      sample-tree = {
        unstable = mk-source-raw [ "unstable" ] {
          attr-a = 321;
          nested.attr-b = 123;
        };
        nixpkgs.unstable =
          mk-source-raw
            [
              "nixpkgs"
              "unstable"
            ]
            {
              attr-b = "321";
              nested.attr-a = "123";
            };
      };
    in
    {
      "work on complex case" = test {
        expr =
          let
            compiled = compile-unstables-config sample-tree (
              {
                unstable,
                nixpkgs,
                from,
                copy-of
              }:
              {
                new-attr = from unstable.nested.attr-b;
                nested.attr-a = from nixpkgs.unstable;
                attr-a = from unstable;
              }
            );
          in
          {
            new-attr = compiled.new-attr.get [ "new-attr" ];
            nested.attr-a = compiled.nested.attr-a.get [
              "nested"
              "attr-a"
            ];
            attr-a = compiled.attr-a.get [ "attr-a" ];
          };

        expected = {
          new-attr = 123;
          nested.attr-a = "123";
          attr-a = 321;
        };
      };

      "work with empty config" = test {
        expr = compile-unstables-config sample-tree (_: { });
        expected = { };
      };

      "return reference throwing error for invalid attr paths" = test {
        expr =
          (compile-unstables-config sample-tree (
            { unstable, from, ... }:
            {
              nested.attr-a = from unstable;
            }
          )).nested.attr-a.get
            [
              "nested"
              "attr-a"
            ];

        expectedError.type = "ThrownError";
        expectedError.msg = "Can not find nested\.attr-a in unstable";
      };
    };

  "overlaying should" =
    let
      mk-package-set = source: {
        jetbrains = {
          idea-ultimate = {
            name = "idea-ultimate";
            inherit source;
          };
          rust-rover = {
            name = "rust-rover";
            inherit source;
          };
        };
        scala-cli = {
          name = "scala-cli";
          inherit source;
        };
      };
      sample-tree = {
        nixpkgs.unstable = mk-source-raw [
          "nixpkgs"
          "unstable"
        ] (mk-package-set "unstable");
        nixpkgs.master = mk-source-raw [
          "nixpkgs"
          "unstable"
        ] (mk-package-set "master");
      };
      existing = mk-package-set "default";
    in
    {
      "work in simple case" = test {
        expr = overlay (compile-unstables-config sample-tree (
          { nixpkgs, from, ... }:
          {
            scala-cli = from nixpkgs.unstable;
            idea-master = from nixpkgs.master.jetbrains.idea-ultimate;
          }
        )) existing existing;
        expected = existing // {
          scala-cli = existing.scala-cli // {
            source = "unstable";
          };
          idea-master = existing.jetbrains.idea-ultimate // {
            source = "master";
          };
        };
      };
      "work correctly on overriding part of existing set" = test {
        expr = overlay (compile-unstables-config sample-tree (
          { nixpkgs, from, ... }:
          {
            jetbrains.rust-rover = from nixpkgs.master;
          }
        )) existing existing;
        expected = existing // {
          jetbrains = existing.jetbrains // {
            rust-rover = existing.jetbrains.rust-rover // {
              source = "master";
            };
          };
        };
      };
      "work correctly with copy function for" = {
        "entire sources" = test {
          expr = overlay (compile-unstables-config sample-tree (
            { nixpkgs, copy-of, ... }:
            {
              master = copy-of nixpkgs.master;
            }
          )) existing existing;

          expected = existing // {
            master = mk-package-set "master";
          };
        };
        "subsets" = test {
          expr = overlay (compile-unstables-config sample-tree (
            { nixpkgs, copy-of, ... }:
            {
              jetbrains-master = copy-of nixpkgs.master.jetbrains;
            }
          )) existing existing;

          expected = existing // {
            jetbrains-master = (mk-package-set "master").jetbrains;
          };
        };
      };
      "work with empty configs" = test {
        expr = overlay (compile-unstables-config sample-tree (_: { })) existing existing;
        expected = existing;
      };

      "fail if forgotten to call from on" = {
        "package" = test {
          expr = overlay (compile-unstables-config sample-tree (
            { nixpkgs, ... }:
            {
              scala-cli = nixpkgs.master.scala-cli;
            }
          )) existing existing;
          expectedError.type = "ThrownError";
          expectedError.msg = "Unexpected value of type string at scala-cli\.name\. Did you forget to call from\?";
        };
        "source" = test {
          expr = overlay (compile-unstables-config sample-tree (
            { nixpkgs, ... }:
            {
              scala-cli = nixpkgs.master;
            }
          )) existing existing;
          expectedError.type = "ThrownError";
          expectedError.msg = "Unexpected value of type <package source: \\(nixpkgs\\.unstable in source tree\\)> at scala-cli\\. Did you forget to call from\?";
        };
      };
    };
}
