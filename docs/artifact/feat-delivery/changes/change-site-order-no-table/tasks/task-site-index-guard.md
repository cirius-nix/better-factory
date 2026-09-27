# task-site-index-guard: The empty heading-search guard, the fixture, and the assertion

**Plan:** [Implementation plan](README.md)
**Covers:** req-browsable-docs, spec-site-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Guard the function `indexRows` in `lib/site.nix` against an empty heading search. A feature index
with no `## Features` heading then gives the alphabetical feature order. The error
`'tail' called on an empty list` stops. Prove the guard with one fixture index and one assertion.

## Steps

1. Change `indexRows` in `services/factory/lib/site.nix`. Move the heading search of the
   function into a named value. When the value is `[ ]`, the listed part is `[ ]`. Otherwise the
   listed part is `builtins.tail` of the value. The current code applies `builtins.tail` to the
   search result directly. The empty result `[ ]` then stops the evaluation.

   ```nix
   found = find lines;
   afterHeading = if found == [ ] then [ ] else builtins.tail found;
   ```

   The empty value `[ ]` flows through the values `pipeLines`, `names`, and `dedup`. The
   function returns `[ ]`. The function `featureOrder` then gives the alphabetical order of the
   feature folders (spec-site-render, "The derived feature order" point 3).

2. Keep the change to the guard. Do not change the table parse, the name match, the dedup, or
   the row order. Existing behavior stays: the row order of a table, then each unlisted folder
   in alphabetical order (spec-site-render, "The derived feature order" point 3).

3. Add the fixture index `services/factory/assets/delivery/fixtures/no-table/`. The tree holds
   the folder `docs/artifact/` and two feature folders. The file `docs/artifact/README.md` holds
   a title, one sentence, and a bullet list. The file holds no `## Features` heading. Each
   feature folder holds a `README.md` file, so the folder exists in the repository.

   ```text
   assets/delivery/fixtures/no-table/docs/artifact/README.md
   assets/delivery/fixtures/no-table/docs/artifact/feat-alpha/README.md
   assets/delivery/fixtures/no-table/docs/artifact/feat-beta/README.md
   ```

4. Add the fixture root to `services/factory/modules/seed-check.nix`, beside the roots
   `siteIndexRoot`, `sitePartialRoot`, and `siteNoIndexRoot`:

   ```nix
   siteNoTableRoot = factoryDir + "/assets/delivery/fixtures/no-table";
   ```

5. Add the assertion `site-no-table-order` to the list `siteAssertions` of
   `services/factory/modules/seed-check.nix`, beside the assertions `site-index-order`,
   `site-partial-order`, and `site-no-index-order`. The assertion calls
   `siteLib.featureOrder siteNoTableRoot` and expects the alphabetical order of the two feature
   folders.

   ```nix
   {
     name = "site-no-table-order";
     assertion =
       siteLib.featureOrder siteNoTableRoot == [
         "feat-alpha"
         "feat-beta"
       ];
     message = "site-no-table-order: an index without a `## Features` heading does not give the alphabetical order of the feature folders";
   }
   ```

6. Do not change the seed index `services/factory/assets/base/docs/artifact/README.md`. Do not
   change another feature. The guard alone makes the seed base tree safe.

## Check

Prove the guard directly. Before the fix, the first command stops with
`error: 'tail' called on an empty list`. After the fix, the command prints the alphabetical
order.

```sh
nix eval --impure --expr '
  (import ./services/factory/lib/site.nix).featureOrder
    ./services/factory/assets/delivery/fixtures/no-table
'
```

The value is `[ "feat-alpha" "feat-beta" ]`.

Prove the seed base tree. Its index holds no `## Features` heading.

```sh
nix eval --impure --expr '
  (import ./services/factory/lib/site.nix).featureOrder
    ./services/factory/assets/base
'
```

The value is `[ "feat-example" ]`.

Prove that the existing behavior stays.

```sh
nix eval --impure --expr '
  (import ./services/factory/lib/site.nix).featureOrder
    ./services/factory/assets/delivery/fixtures/index
'
```

The value is `[ "feat-gamma" "feat-alpha" "feat-beta" ]`.

Run the seed check of both archs.

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
```

Both checks are green. The evaluation reaches the assertion `site-no-table-order`, and the
assertion passes. Each result file holds exactly five lines.
