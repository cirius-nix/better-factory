# spec-site-render: The site project and the derived feature order

**Master:** [Specifications](README.md)
**Covers:** req-browsable-docs
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The delivery renders the docs tree as one browsable site. The site project lives at
`apps/documentation/`. The factory owns the site project files. The site configuration reads
one data file, `site.json`, and renders the `docs/` tree at the site root. The reader opens any
docs page and reads the same content as the source file in the docs tree.

The sidebar feature order derives from the feature index. The factory reads the feature index
of the repository under generation and writes the order into `site.json.featureOrder`. The
factory holds no hand list of feature names.

The static asset extension is the option `factory.project.site.staticDirectories`. A project
adds a static directory without an edit of a factory-owned file. A typed build step
(spec-ci-options) can write the files of the directory before the site build.

The blueprint records the site settings, the site file set, and the derived feature order.

## Contract

### The option group

```nix
factory.project.site = {
  enable = true;                     # bool; default false
  title = "Documentation";           # string; default "Documentation"
  url = "https://owner.github.io";   # string; default ""
  baseUrl = "/repository/";          # string; default "/"
  staticDirectories = [ "static" ];  # list of strings; default [ ]
};
```

1. `enable` is a bool. Another type fails evaluation. An absent value gives `false`.
2. `title`, `url`, and `baseUrl` are strings. Another type fails evaluation. An absent value
   gives the default.
3. `staticDirectories` is a list of strings. Each entry is a non-empty relative POSIX path.
   The entry does not start with `/`. No segment is empty, `.`, or `..`. The entry holds no
   backslash. An invalid entry fails evaluation.
4. The group joins the modeled-key list and the root option definitions of the facade root in
   the same change (spec-presets, C-30). `evalFactory` accepts the group and returns it with
   the other settings.
5. `enable` is the gate of the site. `false` gives no site file. `true` gives the site project
   of the emitted-files table.
6. The site project of the emitted repository is one site. The factory emits one site and no
   second site.

### The emitted files

| Emitted path | Content source | Copy mode |
| --- | --- | --- |
| `apps/documentation/package.json` | `assets/delivery/site/package.json` | `managed` |
| `apps/documentation/docusaurus.config.js` | `assets/delivery/site/docusaurus.config.js` | `managed` |
| `apps/documentation/sidebars.js` | `assets/delivery/site/sidebars.js` | `managed` |
| `apps/documentation/site.json` | a rendered JSON store path of the run | `managed` |
| `apps/documentation/.gitignore` | `assets/delivery/site/.gitignore` | `managed` |
| `apps/documentation/src/css/custom.css` | `assets/delivery/site/custom.css` | `seed` |
| `apps/documentation/README.md` | `assets/delivery/site/README.md` | `seed` |

1. The factory emits each file of the table when `enable = true`.
2. The factory emits no file of the table when `enable = false`.
3. The delivery module writes the content of each asset file of the table to a store path with
   `builtins.toFile`. The module renders the file `site.json` with `builtins.toJSON`. Each site
   file joins the file plan as an `extraFiles` entry. The `source` of the entry is the store
   path. The rendered-source list of the run holds the same store path. The file-plan check
   accepts the rendered-source list of the run (spec-harness-merge of feat-orchestration
   1.0.0). The same rule covers the CI file (spec-ci-options, C-33) and the notifier file
   (spec-notify-fanout, C-33). The file-plan allowlist stays the base tree, the active overlay
   tree, and the rendered-source list of the run. A direct path under `assets/delivery/` is
   not the `source` of a plan entry; the file-plan check rejects it.
4. The site files join the one transaction that holds the base files, the overlay files, the
   role files, the MCP files, the design files, the skill file, the CI file, and the notifier
   file. The transaction reads the effective settings after the preset bundle (spec-presets,
   C-39).
5. The site project pins its dependencies in `package.json`. The factory owns `package.json`.
   The project does not edit it. The copy mode `managed` fails the drift check on a hand edit
   (spec-copymode of feat-foundation 1.0.0). The factory emits no `package-lock.json`. The
   emitted repository generates the lock file with `npm install` (spec-ci-options).
6. `custom.css` and `README.md` use the copy mode `seed`. The author owns the style and the
   guide. The factory never replaces them after the first write.
7. The emitted `README.md` states the manual steps of the azure-static-web-app target
   (spec-publish).

### The `site.json` data contract

The delivery module writes this value with `builtins.toJSON`:

```nix
{
  title = site.title;
  url = site.url;
  baseUrl = site.baseUrl;
  staticDirectories = site.staticDirectories;
  featureOrder = <the derived feature order>;
}
```

1. The module always writes the five fields. It keeps each list value and its order.
2. The JSON object key order has no contract meaning.
3. `site.json` is the settings boundary between Nix and the site configuration. The factory
   copy of `docusaurus.config.js` reads the five fields and no other site setting.
4. The module does not normalize and does not create a static directory. The site build
   resolves each relative directory from `apps/documentation/`. A project source or a typed
   build step supplies the directory and its files.

### The derived feature order

1. The source is the feature index `docs/artifact/README.md` of the repository under
   generation. The delivery module takes the repository root as one argument, `repoRoot`. The
   project passes its own root. A check passes the root of its fixture index.
2. The module reads the rows of the `## Features` table in order. The derived list holds the
   `feat-<name>` folder basename of each row.
3. An absent index, an absent table, or an empty table gives an empty order list. A feature
   folder that the index does not list follows the listed folders in alphabetical order. A
   repository without an index holds the alphabetical order of its feature folders.
4. The site group holds no feature-order option. The factory holds no hand list of feature
   names.

### The site configuration

1. `docusaurus.config.js` reads `./site.json` for `title`, `url`, `baseUrl`,
   `staticDirectories`, and `featureOrder`.
2. The docs path is `../../docs`. The docs route is `/`. The reader reaches each page of the
   docs tree below the route.
3. The sidebar path is `./sidebars.js`. Number-prefix parsing is off.
4. The exclude list holds the Docusaurus defaults and `**/templates/**`.
5. A folder without an index gets a generated index page.
6. `trailingSlash` is `true`. Both broken-link settings are `warn`. The markdown format is
   `detect`. The classic preset disables the blog. The classic theme reads
   `./src/css/custom.css`. The navbar title is `site.title`.
7. The configuration holds the one comparator of the sidebar. The comparator applies to each
   sibling level in this priority order:
   - A feature folder uses its zero-based position in `featureOrder`. A listed folder precedes
     an unlisted folder. Two unlisted folders continue to the next rule.
   - An `index` or `README` document precedes each other item in its parent folder.
   - An artifact phase folder uses this rank: `requirements`, `specifications`, `decisions`,
     `tasks`.
   - Under a `versions` folder, semantic-version folders descend by major, minor, and patch
     number. A valid version precedes an invalid version folder.
   - Under a `changes` folder, `change-initial` precedes the other change folders.
   - The fallback compares display labels without letter case. Two equal labels compare the
     original labels. Two equal original labels compare the source identities.
8. The comparator applies each special rule only to its specified item type and parent folder.

### The check

The site check renders one fixture with `enable = true` and one fixture with `enable = false`.
It proves:

- the `false` fixture holds no site file of the emitted-files table;
- the `true` fixture holds each file of the table with its content source and copy mode;
- the site files join the plan as `extraFiles` entries with rendered sources, and the plan
  holds no direct source under `assets/delivery/`;
- the `site.json` round-trip value equals the fixture settings and the derived order;
- the check calls the delivery module with the root of a fixture index, and the derived order
  equals the row order of that fixture index;
- a fixture index without a row for a feature folder puts that folder after the listed folders
  in alphabetical order;
- the factory holds no hand list of feature names;
- the config asset holds the read of `site.featureOrder` and a marker of each comparator rule;
- the check runs no `npm` command and no JavaScript file; the comparator proof reads the
  required text of the config asset only;
- a `seed` site file keeps the edits of the author after a second copy step.

## Errors

- An `enable` value that is not a bool fails evaluation.
- A `title`, `url`, or `baseUrl` value that is not a string fails evaluation.
- A `staticDirectories` entry that is not a valid relative path fails evaluation.
- A missing content source file fails evaluation.
- A site file in the plan when the site is disabled fails the check.
- A missing site file in the plan when the site is enabled fails the check.
- A plan entry with a direct `source` under `assets/delivery/` fails the file-plan check.
- A `site.json` value that differs from the fixture settings fails the check.
- A feature order that differs from the index row order fails the check.
- A derived order that puts an unlisted feature folder before a listed folder fails the check.
- A hand list of feature names in the factory fails the check.
- A missing comparator-rule marker or a missing `site.featureOrder` read in the config asset
  fails the check.
- A seed check that runs `npm` or a JavaScript file fails the check.
- A `seed` site file that the factory replaces fails the copy-mode check.
- The site build fails when `site.json`, the style file, or a configured static directory is
  absent.
- Broken markdown links give warnings. They do not stop the site build.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-20 | The site project lives at `apps/documentation/`. One name serves the site project, the CI watch paths, and the publish flows. The site is one application of the repository, so it lives below `apps/`. | services/factory |
| C-21 | Each site file joins the plan as an `extraFiles` entry with a store path of the run. An asset file uses a `builtins.toFile` store path of the asset content. The file `site.json` uses the rendered JSON store path. The same store paths join the rendered-source list of the run. The file-plan allowlist stays the base tree, the active overlay tree, and the rendered-source list. A direct path under `assets/delivery/` fails the check. | services/factory |
| C-22 | The sidebar feature order derives from the feature index of the repository under generation. The factory holds no feature-order option and no hand list. The comparator keeps the alphabetical fallback for an unlisted folder. | services/factory |
| C-23 | The site check reads the config asset for the required text and does not run JavaScript. A site build proves the comparator order. The site check proves the `site.json` round-trip value and the derived order. | services/factory |
| C-32 | The delivery module takes the repository root as one argument, `repoRoot`, for the feature-index read. The check supplies a fixture index and calls the module with the fixture root. The check proves the row order of the fixture index and the alphabetical fallback of an unlisted folder. | services/factory |
| C-33 | The site files, the CI file, and the notifier file join the plan as `extraFiles` entries. Each `source` is a `builtins.toFile` store path of the asset content or of the rendered text. The file `site.json` uses a `builtins.toJSON` store path. Each store path joins the rendered-source list of the run. The file-plan allowlist stays the base tree, the active overlay tree, and the rendered-source list. A direct path under `assets/delivery/` fails the file-plan check. | services/factory |
| C-36 | The factory owns `apps/documentation/package.json` with the copy mode `managed`; a hand edit fails the drift check. The factory emits no `package-lock.json`, and the emitted repository generates the lock file with `npm install`. The seed check runs no `npm` command. The site check proves the comparator by the required text markers of the config asset and runs no JavaScript. | services/factory |
| C-37 | The site check fixtures prove the site file set and the derived feature order. The factory repository holds no site project. The check does not build the site content. | services/factory |
