with builtins;

configFiles: env: stdNix@{ config, pkgs, lib, ... }:
  let
    utils = import ./pure-utils;
    toPath = path: if isPath path then path else ./. + (if utils.string.startsWith "/" path then path else ("/" + path));
    dynImport = path: import (toPath path);
    tryImport = path:
      let p = toPath path;
      in if lib.pathExists p then
        utils.Either.Right { inherit path; component = (dynImport p); }
      else utils.Either.Left { inherit path; error = "no such path"; }
    ;

    validateComponent = { component, path }:
      if isAttr component then
        let
          validated =
            if hasAttr "component" component
            then utils.Either.Right component
            else Left { inherit component path; error = "Component object has no component field (wrong type)"; };
        in utils.Either.map (it: { priority = 0; } // it) validated
      else if isFunction component then
        utils.Either.Right { inherit component path; priority = -1; }
      else
        utils.Either.Left { inherit component path; error = "Component is neither object nor function (wrong type)"; }
    ;

    defaultComponentResolver = scope: { component, ... }:
      let loaded = component scope;
      in {
        addToNix = utils.attrs.attrOr "nixConfig" {} loaded.nixConfig;
        addToScope = utils.attrs.attrOr "globalScope" {} loaded.globalScope;
      }
    ;

    componentLoader = rec {
      load = globalScope: name: let
        attempts = map (it: tryImport (it + name)) globalScope.componentSearchPaths;
        # validate, find right
        result = ???;
      in utils.Either.map (it: {
        resolveComponent = globalScope.resolveComponent;
        loaded = it;
      }) result;
      resolve = defaultComponentResolver;
    };

    loadComponent = globalScope: componentName:
      utils.Either.mapLeft (it: it // { inherit componentName; }) (globalScope.componentLoader.load globalScope)
    ;

    addComponents = globalScope: addToNix: componentNames:
      let
        loaded = map (loadComponent globalScope) componentNames;

        imported = partition utils.Either.isRight (map tryImport componentNames);
        loaded = map (it: it.right) imported.right;
        failed = map (it: it.left.path) imported.wrong;
        componentNames = map (compose utils.Either.flatMap validateComponent) loaded;
        allFailed = failed ++ (filter utils.Either.isLeft componentNames);
        toBeLoaded = utils.reverseSortBy (it: it.priority) (utils.Either.collectRight componentNames);
        result = foldl' ({ currentScope, addToNix }: component: let
          loadedComponent = currentScope.resolveComponent currentScope component;
        in {
          currentScope = utils.attrs.merge currentScope loadedComponent.addToScope;
          addToNix = addToNix ++ loadedComponent.addToNix;
        }) { currentScope = globalScope; inherit addToNix; } toBeLoaded;
      in if length allFailed > 0 then
        if length allFailed == length componentNames then
          let componentFailures = concatStringsSep "\n" (map (it: " - ${it.left.error} (${it.left.path})") allFailed);
          in throw "Failed to load components: ${componentFailures}"
        else
          addComponents result.globalScope result.addToNix (map (it: it.left.path) allFailed)
      else result
    ;
    scopeLoad = rec {
      loaded = addComponents {
        conf = removeAttrs env [ "additionalConfiguration" ];
        include = path:
          if isPath path then (import path) g
          else g.include (./. + path)
        ;
        includeAll = map g.include;
      } [] env.enabled;
      globalScope = loaded.
    }.g;
  in {
    imports = [] ++ (includeAll configFiles) ++ [ env.additionalConfiguration ];
  }
