# spec-layout: The layout of changes and versions

**Master:** [Specifications](README.md)
**Covers:** req-layout
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The layout gives each repository one place for the work and one place for the released states.
Each unit of work is a change below `changes/`.
Each released state is a version below `versions/`.
The factory emits this layout into a new repository.
The factory repository uses the same layout for its own artifacts.
The command `Adopt layout` records the layout and emits `Layout adopted`.

## Contract

### Directory structure

```text
docs/artifact/
    README.md                       The index of the features.
    feat-<name>/
        README.md                   The feature summary. Names the current version.
        changes/                    Required. One folder for each change.
            change-initial/         The first build of the feature.
                README.md           The change summary. From none, To 1.0.0.
                requirements/       Required in change-initial.
                specifications/     Required in change-initial.
                decisions/          Optional.
                tasks/              Required in change-initial.
            change-<name>/          One folder for each later change.
                README.md           The change summary. From, To, Type, Reason.
                requirements/       Present only if a requirement changes.
                specifications/     Present only if a specification changes.
                decisions/          Present only if a decision changes.
                tasks/              Present only if the change needs code.
        versions/                   Present after the first released version.
            <major>.<minor>.<patch>/
                requirements/       The full requirements at this version.
                specifications/     The full specifications at this version.
                decisions/          The full decisions at this version. Absent if none.
```

A feature has no root `requirements/`, `specifications/`, `decisions/`, or `tasks/` folder.
A version folder has no `tasks/` folder and no `README.md`.
The `versions/` folder has no `README.md`.

### Names

- A name uses lowercase letters, digits, and hyphens.
- The first change of a feature is `change-initial`.
- A version is `<major>.<minor>.<patch>`.
- Each part is a decimal number without a leading zero.
- The first version of a feature is `1.0.0`.
- The change README gives the version before the change in `**From:**` and the version after the
  change in `**To:**`.
- `change-initial` has `**From:** none` and `**To:** 1.0.0`.

### The version number by change type

The `**Type:**` line of the change README gives the next version.
The version before the change is `major.minor.patch`.

| Type | Meaning | To |
| --- | --- | --- |
| Requirements | A requirement is added, changed, or removed. | `major+1.0.0` |
| Specifications | Only a specification changes. No requirement changes. | `major.minor+1.0` |
| Decisions | Only a decision changes. No requirement changes. | `major.minor+1.0` |
| Correction | An artifact text is corrected. No contract changes. | `major.minor.patch+1` |

A `**Type:**` line can name two types, for example `Specifications, Decisions`.
The first type gives the bump.
The type `Requirements` is first when it is present.
The type of `change-initial` is `Requirements`.

### The version number check

The factory reads `**From:**`, the first type, and `**To:**` of the change README.
The factory calculates the expected `**To:**` from the table of the version number by change
type:

```text
From = major.minor.patch, first type = Requirements   -> To = major+1.0.0
From = major.minor.patch, first type = Specifications -> To = major.minor+1
From = major.minor.patch, first type = Decisions      -> To = major.minor+1
From = major.minor.patch, first type = Correction     -> To = major.minor.patch+1
From = none, first type = Requirements                -> To = 1.0.0
```

The check fails when `**To:**` is not the expected value.
The check is part of the Nix evaluation of the change README fields.
The layout layer of the seed check runs the same rule (spec-e2e-seed).
The repository git hooks do not check the version number.

### The artifacts of a change

- A change holds only the artifacts that change.
- Each file in `requirements/`, `specifications/`, or `decisions/` of a change is the full
  replacement file of one artifact.
- The file has the same name as the artifact that it replaces in `versions/<from>/`.
- A new name is a new artifact.
- When the list of teardown artifacts of a folder changes, the change holds the master
  `README.md` of that folder.
- The master lists every teardown artifact of the folder at the new version.
- A master README in a change has the line
  `**Change:** [<change name>](../../../changes/change-<name>/README.md)` under its title.
- A change that removes an artifact lists each path under `## Removed artifacts` in the change
  README. Each path is relative to the version folder.
- No artifact records a status or a phase-tracking field.

### The code paths of a change

The change README holds a `## Code paths` section.
The section lists the code paths of the change, one path for each line.
Each path is relative to the repository root.
A path is a file or a directory.
A change with no code lists `None`.
The factory reads the section and fails when a listed path does not exist.
`change-initial` lists the paths of the foundation code.

### The version copy check

The version copy check compares `versions/<to>/` with `versions/<from>/` and the change folder.

1. Every path of `versions/<from>/` appears at the same path in `versions/<to>/` with equal
   bytes. The exceptions are:
   - a path that the change replaces: the change holds the same path with the new bytes;
   - a path under `## Removed artifacts` of the change README: the path is absent from the new
     version.
2. Every file of `requirements/`, `specifications/`, or `decisions/` of the change appears at
   the same path in `versions/<to>/` with equal bytes.
   The rule includes the `**Change:**` line of a master README.
   The line stays as it is, and the check does not rewrite it.
3. No other path appears in `versions/<to>/`.
4. For `change-initial`, `versions/<from>/` is empty.
   The version folder equals the change artifacts.

A difference outside these rules fails the check.
The check writes the path and the reason.
The layout layer of the seed check runs this rule when the tree holds a version folder.

### The layout in a new repository

The factory emits these files into a new repository:

```text
docs/artifact/README.md
docs/artifact/feat-example/README.md
docs/artifact/feat-example/changes/change-initial/README.md
```

`feat-example` is the starter feature.
Its first change is `change-initial`.
The starter change README holds the field lines and `## Code paths` with `None`.
The author renames the starter feature for the first real feature.
The starter files use the `seed` copy mode (spec-copymode).

### The starter markdown

The emitted starter markdown follows the repository markdownlint configuration
`.markdownlint.yaml`.
The layout layer of the seed check runs the pinned markdownlint with this configuration on the
emitted starter files.
A lint error fails the layer.
The repository hook excludes `docs/.*/templates/` only.
It does not exclude `docs/artifact/`.
The emitted starter markdown passes the configuration.

## Errors

- A feature with a root `requirements/`, `specifications/`, `decisions/`, or `tasks/` folder does
  not follow this contract.
- A change README without `**From:**`, `**To:**`, or `**Type:**` does not follow this contract.
- A change README without a `## Code paths` section does not follow this contract.
- A `**To:**` that is not the expected value fails the version number check. Correct the change
  README before the release copy.
- A name with an uppercase letter, an underscore, or a space does not follow this contract.
- A version part with a leading zero does not follow this contract.
- A version folder with a `tasks/` folder or a `README.md` does not follow this contract.
- A version folder that does not follow the version copy check is an error.
  Make the version folder again by copy.
- A version folder for a change whose listed code path does not exist is an error. Delete it.
- A first change that is not `change-initial` does not follow this contract.
- An emitted starter markdown file with a markdownlint error fails the layout layer.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The change README holds a `## Code paths` section. The factory fails when a listed path does not exist. | services/factory |
| C-02 | The version copy check has one diff rule: a path under `## Removed artifacts` is absent, and the `**Change:**` line of a master README stays byte-equal. No other difference is allowed. | services/factory |
| C-03 | The version number check is part of the Nix evaluation of the change README fields and of the layout layer. The repository git hooks do not check the version number. | services/factory |
| C-04 | The emitted starter markdown follows `.markdownlint.yaml`. The layout layer runs the pinned markdownlint on the emitted starter files. | services/factory |
