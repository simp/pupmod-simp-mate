# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-mate` is a small SIMP Puppet module that installs a **minimal, hardened
MATE desktop environment** on Enterprise Linux. It installs the MATE packages
(caja, marco, mate-session-manager, mate-screensaver, mate-settings-daemon,
etc.) and applies a set of hardened `dconf` defaults — disabling media
automount/autorun, neutralising the power button and Ctrl-Alt-Del, and enabling
a locking screensaver.

The module is a **thin orchestration layer over `simp/dconf`**: it does not
write dconf databases itself. It declares `dconf::profile` and `dconf::settings`
resources, and `simp/dconf` does the actual enforcement. All of the real
configuration lives in `data/common.yaml` as data, not in code.

### Business logic

Two classes, both driven entirely by module data:

- **`mate` (`manifests/init.pp:36-55`)** — Public entry class (consumers
  `include 'mate'`). Its four data-bound parameters have **no manifest
  defaults** — they are supplied from `data/common.yaml` via the module's
  Hiera:
  - `$configure` (`Boolean`, `init.pp:37`) — whether to apply configuration
    (default `true` in data).
  - `$dconf_hash` (`Hash[String[1], Dconf::SettingsHash]`, `init.pp:38`) — the
    dconf settings, keyed by profile name.
  - `$dconf_profile_hierarchy` (`Dconf::DBSettings`, `init.pp:39`) — the dconf
    DB priority (`simp_mate`, type `system`, order `10`).
  - `$packages` (`Hash[String[1], Optional[Hash]]`, `init.pp:40`) — package
    list; **setting this overrides the default list** (docstring `init.pp:23`).
  - `$package_ensure` (`Simplib::PackageEnsure`, `init.pp:41`) — the seam;
    used as the `simplib::install` default `ensure`.

  It calls `simplib::assert_metadata` (`init.pp:43`), installs the packages via
  `simplib::install { 'mate' }` (`init.pp:45-48`), and — when `$configure` —
  includes `mate::config` ordered after the install (`init.pp:50-54`).

- **`mate::config` (`manifests/config.pp:4-17`)** — **Private**
  (`@api private` + `assert_private()` at `config.pp:5`). Declares one
  `dconf::profile { 'mate_user' }` from `$mate::dconf_profile_hierarchy`
  (`config.pp:7-9`) and iterates `$mate::dconf_hash` to emit a
  `dconf::settings` resource per profile (`config.pp:11-16`). That is the whole
  class — no templates, no files, no execs.

The hardened dconf keys set in `data/common.yaml` (`common.yaml:32-68`):
`org/mate/media-handling` `automount`/`automount-open` → `false`,
`autorun-never` → `true`; `org/mate/SettingsDaemon/plugins/media-keys` `logout`
→ `''` (Ctrl-Alt-Del ignored); `org/mate/power-manager` `button-power` →
`'nothing'`; `org/mate/session` `idle-delay` → `uint32 900` (15 min);
`org/mate/screensaver` `idle-activation-enabled`/`lock-enabled` → `true`,
`lock-delay` → `0`.

### Gotchas / non-obvious details

- **`config.pp` sets no polkit rules.** `simp/polkit` is a declared dependency
  and `mate-polkit` is in the package list (`common.yaml:20`), but this module
  installs the mate-polkit *package* only — it declares **no**
  `polkit::*` resources. Any policy rules must be managed separately via
  `simp/polkit`.
- **The dconf keys are values, not locks.** None of the `dconf_hash` entries
  set `locked: true` (`common.yaml:32-68`), so these are hardened *defaults* a
  user can still change — MATE is treated as a desktop front-end, not a locked
  appliance. If you need them enforced immutably, add locks.
- **Everything is data, not code.** To change packages or dconf settings, edit
  `data/common.yaml` (or override in site Hiera) — the manifests carry no
  defaults. Both `mate::packages` and `mate::dconf_hash` use a **deep merge with
  `--` knockout prefix** (`common.yaml:2-10`), so site overlays can extend or
  remove individual entries without replacing the whole hash.
- **Setting `$packages` replaces the default list** rather than merging at the
  parameter level (`init.pp:23`) — rely on the Hiera deep-merge to add/remove
  packages instead of passing `$packages` directly.
- **`Dconf::SettingsHash` and `Dconf::DBSettings` come from `simp/dconf`**, and
  `Simplib::PackageEnsure` / `simplib::install` come from `simp/simplib` — this
  module defines no custom types.

## The `simp_options` / `simplib::lookup` seam

The module's only lookup seam (the natural target for a lookup-path unit test):

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:41` | `simp_options::package_ensure` | `'installed'` |

Keep routing package state through `simplib::lookup('simp_options::package_ensure',
{ 'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included. No `assert_optional_dependency` calls exist in this
module.

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/dconf` `>= 0.0.1 < 2.0.0` (provides `dconf::profile`,
  `dconf::settings`, and the `Dconf::SettingsHash` / `Dconf::DBSettings` types —
  the actual enforcement engine)
- `simp/polkit` `>= 6.1.0 < 8.0.0` (declared; `mate-polkit` is installed but no
  polkit resources are declared here)
- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup`,
  `simplib::assert_metadata`, `simplib::install`, `Simplib::PackageEnsure`)
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0`

No optional dependencies (`metadata.json` declares no
`simp.optional_dependencies`).

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9; RedHat 8/9;
OracleLinux 8/9; Rocky 8/9; AlmaLinux 8/9. (Note: no EL10 — a narrower matrix
than most SIMP modules.)

## Repository layout

- `manifests/init.pp` — the `mate` class: `simplib::install` + optional
  `mate::config`.
- `manifests/config.pp` — the private `mate::config` class (dconf profile +
  settings).
- `data/common.yaml` — **all** of the module's real configuration: the package
  list, the `simp_mate` dconf profile hierarchy, and the hardened `dconf_hash`
  settings (plus the deep-merge `lookup_options`).
- `hiera.yaml` — module data hierarchy (v5): OS family + major.minor → OS family
  + major → common.
- `metadata.json` — deps, OS matrix, OpenVox requirement.
- `spec/classes/` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/` — beaker acceptance suite; nodesets under
  `spec/acceptance/nodesets/`.
- No `types/`, `lib/`, or `templates/` — the module defines no custom data
  types, Ruby types/providers/functions/facts, or templates; every type it uses
  comes from `simp/dconf` and `simp/simplib`.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job whose final step runs
  `bundle exec rake beaker:suites[default,<node>]`. Unlike most SIMP modules
  this suite runs under **podman/Docker** (nodes `docker_alma8`, `docker_alma9`,
  `docker_centos9`, `docker_oel8`, `docker_oel9`, `docker_rocky8`,
  `docker_rocky9`) rather than `vagrant_libvirt`.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run the single class spec
bundle exec rspec spec/classes/init_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite (podman)
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`, `rubocop ~> 1.88.0`. `spec/spec_helper.rb`
requires `puppetlabs_spec_helper/module_spec_helper`.

## Conventions

- Change packages and dconf settings in `data/common.yaml` (or site Hiera via
  the deep-merge), not in the manifests — this module is data-driven.
- Keep `mate::config` private and let `simp/dconf` do the enforcement; don't
  write dconf files directly from this module.
- Preserve the `@summary` / `@param` puppet-strings docstrings — they drive
  `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or parameters.
- Continue routing package state through
  `simplib::lookup('simp_options::package_ensure', { 'default_value' => ... })`
  rather than assuming `simp_options` is included.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in `manifests/`.
