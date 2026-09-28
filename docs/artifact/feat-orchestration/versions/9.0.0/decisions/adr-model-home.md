# adr-model-home: The home of the role models

**Relates to:** spec-capability-ship, spec-harness-merge
**Context:** context-factory

## Context

Each built-in role holds one capability of the kind `model`. The value is a model name in
`provider/model#variant` form. The factory cannot know which providers and which models a
downstream project holds. The feasibility review FCL-01-04 finds that a repo-local capability
holds no defined path. The change must select the home of the role models and the path of a
repo-local model.

## Options

1. The home `shipped`. The factory gives each role a default model, and the author overrides the
   value in the project layer or in the local layer. Pro: a generated project works with a known
   model. Con: the factory fixes one provider and one model, so a project without that provider
   fails or falls back; the shipped value can age.
2. The home `repo-local`. The factory source repository owns the model of each role. A generated
   project receives no factory model, and the author declares the model. Pro: no provider
   assumption reaches a generated project; the author selects the model of the project. Con: a
   generated project starts with no factory model and inherits the session model.
3. No model capability. The model is an author declaration only. Pro: the simplest model. Con:
   the requirement asks for the role models as a capability; a capability of the kind `model` is
   then dead, so the kind is not live.

## Decision

Option 2. The model capability is repo-local. The factory source repository owns the model of
each built-in role. A generated project receives no `agents.<role>.model` value from the factory.
The author declares the model of a role in the project layer or in the local layer.

The declaration sits in the capability entry of the role-contract table with the home
`repo-local` (adr-capability-home). A repo-local config kind uses the existing user-wins
declaration path `factory.project.agents.opencode.extraAgents.<role>.model` (FCL-01-04). The path
is user-wins, so it lands in `agents.<role>.model` of the factory source repository render. The
managed layer holds no value for it, so the merge writes no log line (FCL-01-05). The key
`agents.<role>.model` is the render target when a later decision ships a model.

## Consequences

Easier: no provider assumption in a generated project; the author selects the model; the kind
`model` is live; the repo-local path is the existing extra key.

Harder: a generated project starts with no factory model; the factory source repository declares
its own model through the extra key.
