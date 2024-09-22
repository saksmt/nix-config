module 'nix-features#nixLibs.default' {
    import {Tree, UninitializedFeature, Result, Feature, NixpkgsLib, UserFacingFeature} from "common-types";
    import {FeatureConstructorLib, FeatureDefinitionError} from "nix-features#nixLibs._PRIVATE";

    const exports: (nixpkgs: { lib?: NixpkgsLib }) => {
        /**
         * Define features, throws an error if there are invalid definitions in argument
         * requires full-blown lib of nixpkgs in file arguments to be present!
         */
        'define-features-or-throw': (
            definitions: (lib: FeatureConstructorLib) => Tree<UninitializedFeature>
        ) => Tree<Feature>,
        /**
         * Define features
         */
        'define-features': (
            definitions: (lib: FeatureConstructorLib) => Tree<UninitializedFeature>
        ) => Result<FeatureDefinitionError[], Tree<Feature>>,
        /**
         * Resolve enabled features and build final tree (with same structure as in definition)
         * of features enriched with helpful methods (more details on those in {@linkcode UserFacingFeature}
         */
        'assign-features': (defined: Tree<Feature>) => (includedInRoot: Feature[]) => Tree<UserFacingFeature>,
        /** Build user-friendly message from definition errors, requires full-blown lib of nixpkgs in file arguments to be present */
        'format-definition-error-message': (definitionErrors: FeatureDefinitionError[]) => string
    }
    export = exports
}

module 'common-types' {
    /** Result or error encoding */
    export type Result<E, A> = ({ ok: A } | { fail: E })
    /** Key name in attr set */
    export type PathSegment = string;
    /** Tree of unspecified depth encoded as nested attr sets */
    export type Tree<a> = a | { [P in any]: a }

    /** Initialized feature */
    export type Feature = _Feature & {
        'is-enabled': boolean
    }

    /** Uninitialized feature as returned from feature constructor */
    export type UninitializedFeature = symbol; // private implementation details

    /** Feature meant to face user of the library, exposed as result of resolution */
    export type UserFacingFeature = Feature & {
        'is-disabled': boolean,
        'if-enabled': <T> (code: T) => NixpkgsMkIfResult<T>,
        and: (other: Feature) => UserFacingFeature,
        "or'": (other: Feature) => UserFacingFeature,
        // + + aliases in camel case, with "when" instead of "if" prefix, with "are" instead of "is" prefix
    }

    // nixpkgs lib.modules.mkIf return value
    export type NixpkgsMkIfResult<T> = undefined
    export type NixpkgsLib = undefined
    export type Nixpkgs = undefined

    /** Private feature type description, set with some attributes */
    type _Feature = symbol; // private implementation details
}


module "nix-features#nixLibs._PRIVATE" {
    import {PathSegment, Result, Feature, Tree, UninitializedFeature, NixpkgsLib, UserFacingFeature} from 'common-types'

    namespace exports {
        /** Error describing failure on attempt to construct feature from definition */
        export type FeatureDefinitionError = {
            /** path in definition tree where problematic data was encountered */
            path: PathSegment[],
            /** value that led to this failure */
            value: any,
            reason: string
        }
        /** Feature definition arguments */
        export type FeatureConstructorArguments = {
            'default-enabled'?: boolean,
            includes?: Feature[]
        }
        /** Feature definition library */
        export type FeatureConstructorLib = {
            /** reference to result of construction, needed for proper usage of {@link FeatureConstructorArguments#includes} */
            self: Tree<Feature>,
            feature: (args: FeatureConstructorArguments) => UninitializedFeature
        }
    }

    const exports: (nixpkgs: { lib?: NixpkgsLib }) => {
        /**
         * Construct features from definitions
         * Used as following:
         * ```
         * construct-definitions ({ feature, self }: {
         *   my-feature = feature {};
         *   my-other-feature = feature { default-enabled = true; };
         *   yet.another.feature = feature { includes = [ self.my-feature ]; };
         * })
         * ```
         */
        'construct-definitions': (_: {
            'feature-definitions': (lib: exports.FeatureConstructorLib) => Tree<UninitializedFeature>
        }) => Result<exports.FeatureDefinitionError[], Tree<Feature>>
        /** check whether given argument is a feature */
        isFeature: (v: unknown) => boolean,
        /** check whether two arguments are essentially representing the same feature */
        sameFeature: (a: Feature) => (b: Feature) => boolean,
        /** Traverse tree applying function {@linkcode f} to each element passing path in the tree alongside said element */
        mapTreeWithPath: <T> (f: (path: [PathSegment]) => (feature: Feature) => T) => (featureTree: Tree<Feature>) => Tree<T>,
        /** Traverse tree applying function {@linkcode f} to each element */
        mapTree: <T> (f: (feature: Feature) => T) => (featureTree: Tree<Feature>) => Tree<T>
        /** Get flat list of features from given feature tree */
        treeValues: (featureTree: Tree<Feature>) => Feature[],
        /** List all features that given one pulls in through dependencies, filter out according to {@linkcode filter} */
        resolveDependencies: (filter: ((feature: Feature) => boolean)) => (feature: Feature) => Feature[],
        /** List all features that given ones pulls in through dependencies, filter out according to {@linkcode filter} */
        resolveAllDependencies: (filter: ((feature: Feature) => boolean)) => (feature: Feature[]) => Feature[],
        /**
         * Resolve all dependencies returning full tree with correctly applied enablings.
         * Logic is as following: enabled features in input list will transitively pull
         * all their includes and make them enabled as well, disabled features in the input list
         * will restrict includes of those features and also make feature disabled if it was enabled
         * by default.
         */
        resolveTree: (includedFeatures: Feature[]) => (definedFeatures: Tree<Feature>) => Tree<Feature>,
        /**
         * Merge some useful and convenient methods into {@link feature}
         * @see UserFacingFeature
         *
         * @param libOverride - a way to override (or even provide for the first time) nixpkgs lib (the one in os module arguments, or nixpkgs.lib)
         */
        mkUserFacingFeature: (libOverride: NixpkgsLib) => (feature: Feature) => UserFacingFeature
    }
    export = exports;
}
