{
  features,
  lib,
  flake-inputs,
  ...
}:
with features;
let
  forFeature = feature: lib.optionalAttrs feature.isEnabled;
  magicless-agents = flake-inputs.magicless-agents;
  agents = "${magicless-agents}/agents";
  skills = "${magicless-agents}/skills";
in
forFeature dev.common {
  module-for = [ "hm" ];

  home.file = builtins.foldl' (a: b: a // b) { } (
    builtins.map (skill: {
      ".config/opencode/skills/${skill}/SKILL.md".source = "${skills}/${skill}/SKILL.md";
    }) (builtins.attrNames (builtins.readDir skills))
  );
  opencode.confd."000-shared/agents" =
    let
      planPaths = {
        "./**/plans/**" = "allow";
        "./**/plan/**" = "allow";
        "./**/brainstorming/**" = "allow";
        "./**/thoughts/**" = "allow";
        "./**/notes/**" = "allow";
        "./**/drafts/**" = "allow";
        "./**/ideas/**" = "allow";
        "./**/thought/**" = "allow";
        "./**/note/**" = "allow";
        "./**/draft/**" = "allow";
        "./**/idea/**" = "allow";
        "./**/specs/**" = "allow";
        "./**/spec/**" = "allow";
        "./**/specification/**" = "allow";
        "./**/specifications/**" = "allow";
        "./**/handoff/**" = "allow";
      };
    in
    {
      agent = rec {
        brainstorm = {
          description = ''Turns vague feature ideas into an approved high-level feature spec through structured interviewing. Use for vague or large features, "let's design X", unclear requirements.'';
          mode = "primary";
          prompt = "{file:${agents}/brainstorm.md}";
          temperature = 0.7;
          permission = {
            edit = planPaths;
            write = planPaths;
            submit_plan = "allow";
            bash = "allow";
            task = {
              "implementer" = "deny";
              "implementer-flash" = "deny";
              "reviewer" = "deny";
            };
          };
        };
        decompose = {
          description = "Decomposes an approved specification into architecture decisions and isolated implementation steps with verifiable DoD. Use after brainstorming, or when a specification exists and needs an implementation plan.";
          mode = "primary";
          prompt = "{file:${agents}/decompose.md}";
          temperature = 0.3;
          permission = {
            edit = planPaths;
            write = planPaths;
            submit_plan = "allow";
            bash = "allow";
            task = {
              "implementer" = "deny";
              "implementer-flash" = "deny";
              "reviewer" = "deny";
            };
          };
        };
        orchestrate = {
          description = "Drives implementation of a spec directory step by step — schedules steps, spawns implementer/reviewer subagents, runs gates, manages feedback files, proposes commits. Use when a decomposition is approved and ready to build.";
          mode = "primary";
          prompt = "{file:${agents}/orchestrate.md}";
          temperature = 0.1;
          permission = {
            edit = {
              "./**" = "allow";
            };
            write = {
              "./**" = "allow";
            };
            submit_plan = "deny";
            bash = "allow";
          };
        };
        implementer = {
          description = "Implements a single implementation step, verifies its DoD with real command output, and reports structured results. Spawned by the orchestrate agent";
          mode = "subagent";
          prompt = "{file:${agents}/implementer.md}";
          temperature = 0.2;
          steps = 50;
          permission = {
            edit = {
              "./**" = "allow";
              "./.git/**" = "deny";
              "./.ignoreme/specs/**" = "deny";
            };
            write = {
              "./**" = "allow";
              "./.git/**" = "deny";
              "./.ignoreme/specs" = "deny";
            };
            submit_plan = "deny";
            bash = "allow";
            task = {
              "*" = "deny";
              "explore" = "allow";
            };
          };
        };
        implementer-flash = implementer // {
          steps = 25;
        };
        reviewer = {
          description = "Reviews one implemented step in phases — mechanical gate, decomposition compliance, code quality — and returns a structured severity-tagged report. Spawned by the orchestrate agent";
          mode = "subagent";
          prompt = "{file:${agents}/reviewer.md}";
          temperature = 0.2;
          steps = 30;
          permission = {
            edit = "deny";
            write = "deny";
            submit_plan = "deny";
            bash = "allow";
            task = {
              "*" = "deny";
              "explore" = "allow";
              "researcher" = "allow";
            };
          };
        };
        researcher = {
          description = ''Deep codebase/SDK/API investigation with judgment — answers "explain/assess" questions with evidence-cited findings. Use for questions grep can't answer (API surfaces, behavior verification, impact assessment).'';
          mode = "subagent";
          prompt = "{file:${agents}/researcher.md}";
          temperature = 0.2;
          steps = 30;
          permission = {
            edit = "deny";
            write = "deny";
            submit_plan = "deny";
            bash = "allow";
            task = {
              "*" = "deny";
              "explore" = "allow";
            };
          };
        };
      };
    };
}
