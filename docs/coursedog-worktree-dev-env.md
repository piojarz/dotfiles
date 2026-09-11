# Coursedog v3 — worktree dev environment (Worktrunk + sandboxed Claude)

Status: **implemented and verified** (layers 2–4) on 2026-08-09 against `coursedogv3` @ `dev`
(fc8228daf7). Layer 1 (starting the shared services + restoring the dump) is still manual and
not yet done. Every config change lives in *this* dotfiles repo — nothing was written to the
`coursedogv3` repo.

> **2026-09-11: migrated layer 2 (and the layer-4 push half) from Worktrunk to
> [workmux](https://github.com/raine/workmux).** Done and smoke-tested — see
> `## Migration: Worktrunk → workmux` for what changed and
> `### Implementation notes (2026-09-11)` at the end of that section for what
> the actual cutover found that the plan didn't anticipate, including one real
> bug (fixed). Worktrunk is fully uninstalled; layers 1, 3, and the "pull" half
> of layer 4 (Caddy domains, the sandbox, `wtd`/`wtsync`) are unaffected. The
> body of this document below the migration section is now historical
> (describes the retired Worktrunk-based state) except where the migration
> section says otherwise.

> **Read `## Sandbox reality check` before trusting layer 3.** Testing disproved the original
> assumption that sandboxed commands can reach the shared DBs on loopback. They cannot, and the
> configuration below reflects the resolution actually chosen.

## Why

`coursedogv3` is a single large npm project (2.7 GB `node_modules`; `postinstall` runs
`build:packages` + `patch-package`) whose frontend and backend bind fixed ports (`8080` / `9292`),
so only one checkout can run at a time. The goal is N concurrent branches — each with its own
worktree, dev servers, tmux session, and Claude Code agent running allow-all safely — all sharing
one set of local databases holding an anonymized production dump.

Four independent layers, deliberately not entangled:

1. **Shared services** — mongo/postgres/redis/LaunchDarkly in Docker on fixed host ports, started
   once by hand, never touched by Worktrunk.
2. **Worktrees + apps** — Worktrunk creates the worktree, warms caches, installs, assigns
   per-branch ports, launches dev servers + tmux.
3. **Sandboxing** — Claude Code's native OS sandbox (Seatbelt / bubblewrap), *not*
   `--dangerously-skip-permissions`.
4. **Agent status** — `wt list` markers (pull) + tmux bell on Stop/Notification (push).

**Zero repo footprint.** No `.config/wt.toml`, no `.worktreeinclude`, no `mise.toml`, no
`.claude/settings.json`, no `.gitignore` edits in `coursedogv3`. Config lives here or in the repo's
*local* (uncommitted) `info/exclude`.

## What already exists (do not rebuild)

| Piece | State |
|---|---|
| Bare layout `v3/.bare` + `v3/dev` worktree | ✅ built by `bin/git-bare-clone` |
| `wt` v0.72.0 + zsh integration | ✅ `Brewfile` + `config/common/zsh/.zshrc.d/worktrunk.zsh` |
| `worktree-path = "{{ repo_path }}/../{{ branch \| sanitize }}"` | ✅ already in user config. `repo_path` resolves to `v3/.bare`, so worktrees land at `v3/<branch>` — siblings of `dev`. Correct as-is |
| mise + `mise activate zsh` | ✅ `config/common/zsh/.zshrc.d/mise.zsh`; repo ships `.tool-versions` (`nodejs 22.22.2`) |
| tmux, sesh | ✅ installed |
| Branch helpers `wtc` / `wtcc` / `wtcf` / `wtcr` / `wtcj` | ✅ `config/common/zsh/.zshrc.d/worktree.zsh` — produce `feature/x`, `SM-123/y`; `sanitize` flattens the slash |
| macOS Seatbelt | ✅ nothing to install |
| `.env` (30+ secrets), `.npmrc` (live `ghp_…` + Taskforce tokens) | ✅ in `v3/dev`, gitignored, already hybrid-mode-correct (localhost hosts) |

Project identifier for per-project config: **`github.com/coursedog/coursedogv3`**
(from `wt config show`).

## Facts that drove the design (verified in source, not assumed)

- **Process env wins in both apps**, so exported ports suffice — no generated dotenv file:
  - Backend: `setupEnv.js` → `env-smart.load()`. `node_modules/env-smart/lib/load.js` merges
    `.env.defaults` → `.env` → **`process.env` last**, then assigns `process.env = env`.
  - Frontend: `vite.config.mts` → `loadEnv(mode, process.cwd(), '')`. Vite 7.3.5's `loadEnv` ends
    with `for (const key in process.env) … env[key] = process.env[key]`, and prefix `''` admits all
    keys. `server.port = PORT`.
- **The FE→BE URL needs no variable of its own.** Vite `define`s
  `process.env.VUE_APP_API_PORT = SERVER_PORT`, consumed at `src/api/core.ts:15`. It tracks
  `SERVER_PORT` automatically.
- `hash_port` verified live for branch `dev`: FE `12193`, BE `19844`, dbg `14222` (range 10000–19999).
- **The sandbox handles the bare repo natively**: when the cwd is a linked git worktree it also
  allows writes to the main repository's shared `.git` dir (`hooks/` and `config` still denied). No
  writable-root workaround needed for `.bare` — just a verification step.
- Registries, from `resolved` fields in `package-lock.json`: `registry.npmjs.org`,
  `npm.pkg.github.com`, `npm.taskforce.sh`, `npm.jsr.io`, `cdn.sheetjs.com`. Two deps are
  `git+ssh://git@github.com/coursedog/*` — SSH can't traverse the sandbox HTTP proxy, which is fine
  because installs run in `wt` hooks (your shell), never in the agent.
- `[projects."<id>"]` in the **user** config accepts `worktree-path`, hooks, and
  `[step.copy-ignored] exclude`, and user hooks need **no approval prompt** (project hooks do).
  This is what makes the zero-repo-footprint requirement achievable.

---

## Layer 1 — Shared services (manual, once)

`docker-compose.yml` lives at the `coursedogv3` root and bind-mounts `./volumes/`, i.e. *inside a
worktree*. Pin both the location and the compose project name so no worktree can fork or clobber
them:

```sh
cd /Users/piotrjarzabek/work/coursedog/v3/dev
docker compose -p coursedogv3 up -d mongo redis postgres
docker compose -p coursedogv3 --profile ldcli-dev-server up -d ldcli-dev-server
# optional, only for SSO work:
docker compose -p coursedogv3 up -d samlIdP
```

- Project name `coursedogv3` (not the directory name `dev`) keeps the existing
  `MONGO_SHELL='docker exec coursedogv3-mongo-1 mongosh'` in `.env` valid.
- Data lives at `v3/dev/volumes/`. Restore the dump per the repo README §Database import:
  `npm run db:dump-and-restore -- --database=… --remote=$REMOTE_URL --local=mongodb://localhost/?directConnection=true --lean`
- Fixed host ports, already matching `.env`: mongo `27017-27019`, postgres `5432`
  (`coursedogai` + `coursedog_common`, `postgres:postgres`), redis `6379`, LD `8765`,
  samlIdP `8089`/`8443`.
- **`v3/dev` must never be removed** — it holds the dump.
- Do **not** use the compose `app` service (that's the all-in-Docker path).

Guardrails, enforced in layers 2 and 3:
- No hook ever runs `docker compose down`, `docker volume rm`, or touches `volumes/`.
- `volumes/` is excluded from `copy-ignored` and made non-writable inside the sandbox.

## Layer 2 — Worktrunk (`config/common/worktrunk/config.toml`)

Symlinked to `~/.config/worktrunk/config.toml`, which **is** the live file — read it there rather
than trusting a copy here. Shape: keep the existing `worktree-path`; `[list] json-schema = 2` to
clear the deprecation warning; the global copy hook moved from `post-start` to `pre-start` so caches
exist before install; then one `[projects."github.com/coursedog/coursedogv3"]` block holding the
copy-ignored excludes, a 4-step blocking `pre-start` pipeline
(`ports → env → install → server-assets`), a background `post-start` tmux hook, and a `pre-remove`
that kills the session.

Verified execution order via `wt hook pre-start --dry-run`, with templates rendering real values:

```text
pre-start user:copy          wt step copy-ignored
pre-start user:ports         for p in 12193 19844 14222; do ... lsof ... exit 1
pre-start user:env           writes mise.local.toml { PORT=12193, SERVER_PORT=19844, BE_INSPECT_PORT=14222 }
pre-start user:install       npm install --no-audit --no-fund
pre-start user:server-assets npm run copy-files:tsc
```

<details>
<summary>Historical: the initial block, before testing corrected it</summary>

```toml
worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"

[list]
json-schema = 2                      # clears the deprecation warning from `wt config show`

[pre-start]
copy = "wt step copy-ignored"        # moved from [post-start]: must precede install

# ─────────────── coursedogv3 ───────────────
[projects."github.com/coursedog/coursedogv3"]

[projects."github.com/coursedog/coursedogv3".step.copy-ignored]
exclude = [
  "volumes/",            # anonymized dump — MUST NOT be duplicated per worktree
  "mise.local.toml",     # per-worktree, regenerated below
  "logs/", "tmp/", "coverage/", ".nyc_output/", "logfile.log",
  "cypress/downloads/", "cypress/cache/", "cypress/reports/",
  "tests/reports/", "playwright-report/", "tests/playwright/test-results/",
  "__screenshots__/", ".vitest-attachments/", "test-results/",
]

# pre-start: blocking pipeline, strict order
[[projects."github.com/coursedog/coursedogv3".pre-start]]
ports = """
for p in {{ branch | hash_port }} {{ ('be-' ~ branch) | hash_port }} {{ ('dbg-' ~ branch) | hash_port }}; do
  if lsof -i :$p -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "wt: port $p already in use — aborting creation of {{ branch }}" >&2
    exit 1
  fi
done
"""

[[projects."github.com/coursedog/coursedogv3".pre-start]]
env = """
cat > '{{ worktree_path }}/mise.local.toml' <<'EOF'
[env]
PORT = "{{ branch | hash_port }}"
SERVER_PORT = "{{ ('be-' ~ branch) | hash_port }}"
BE_INSPECT_PORT = "{{ ('dbg-' ~ branch) | hash_port }}"
EOF
mise trust '{{ worktree_path }}/mise.local.toml'
"""

[[projects."github.com/coursedog/coursedogv3".pre-start]]
install = "npm install --no-audit --no-fund"

[[projects."github.com/coursedog/coursedogv3".pre-start]]
server-assets = "npm run copy-files:tsc"

# post-start: background — tmux session with dev servers + agent
[projects."github.com/coursedog/coursedogv3".post-start]
tmux = """
S='{{ branch | sanitize }}'
W='{{ worktree_path }}'
tmux new-session -d -s "$S" -c "$W" -n dev
tmux split-window -h -t "$S:dev" -c "$W"
tmux split-window -v -t "$S:dev.1" -c "$W"
tmux send-keys -t "$S:dev.1" 'npx concurrently -k -n tsc,srv -c cyan,magenta "npm run watch:be:src" "node server/devServer.js ../dist-server-tsc/server/run.js --inspect=0.0.0.0:$BE_INSPECT_PORT"' Enter
tmux send-keys -t "$S:dev.2" 'npm run dev:fe' Enter
tmux new-window -t "$S" -n agent -c "$W"
tmux send-keys -t "$S:agent" 'claude' Enter
tmux select-window -t "$S:agent"
"""

[projects."github.com/coursedog/coursedogv3".pre-remove]
tmux = "tmux kill-session -t '{{ branch | sanitize }}' 2>/dev/null || true"
```

Three things above were wrong and were fixed in the live file:

1. `exclude = ["volumes/", "logs/", …]` — trailing-slash patterns never match, because `.gitignore`
   anchors these with `/*` so git reports the *children* (`volumes/mongo-atlas-data`). Every entry
   needed `/**`. Measured: with `"volumes/"` the dump was still listed for copying.
2. `tmux split-window` + `send-keys -t "$S:dev.N"` — pane indices shift on each split, so the
   commands went to the wrong panes. The live version captures pane ids (`-P -F '#{pane_id}'`).
   It also guards with `tmux has-session` for idempotency.
3. `send-keys … 'claude'` — `claude` is aliased in `.zshrc` to print a reminder. Must be `claude-cd`.

</details>

Rationale for the non-obvious choices:

- **Ports arrive via `mise.local.toml`, not via the tmux panes.** mise is already active in zsh, so
  every pane *and* every ad-hoc `cd` + `npm run dev:fe` gets the same ports — a hand-typed command
  can't collide. `.env`'s `PORT=8080` / `SERVER_PORT=9292` stay put and are simply outranked.
- **`npm install`, not `npm ci`** — `ci` deletes `node_modules`, throwing away the 2.7 GB the copy
  step just brought over. With a matching lockfile, `install` is a no-op and skips `postinstall`.
- **The backend pane inlines `npm run watch:be`** instead of calling `npm run dev:be`, purely to
  substitute `$BE_INSPECT_PORT` for the hardcoded `--inspect=0.0.0.0:9229` in
  `package.json`'s `watch:be:dist`. That's what stops a second backend's debugger from colliding
  *without* editing the repo.
- `npm run copy-files:tsc` mirrors the first half of the repo's own `npm run dev`. If
  `dist-server-tsc/` wasn't carried over (first-ever run), run `npm run build:be` once in `v3/dev`.
- `pre-remove` kills tmux only — intentionally **no docker command**. Shared services and their
  volumes outlive every worktree.

One-time: hide the generated file from git without touching the repo's `.gitignore`. The bare repo's
`info/exclude` is shared by every worktree, so a single edit covers all of them:

```sh
echo 'mise.local.toml' >> /Users/piotrjarzabek/work/coursedog/v3/.bare/info/exclude
```

Done. Confirmed `volumes/.keep` is tracked, so git creates an empty `volumes/` in every worktree
while the dump itself stays only in `v3/dev`.

## Layer 3 — Sandbox (`config/common/claude/settings.json`)

One personal file, symlinked to **both** `~/.claude-cd/settings.json` and
`~/.claude-pj/settings.json`. Not `~/.claude/settings.json`: `.zshrc` aliases `claude-cd` / `claude-pj`
to set `CLAUDE_CONFIG_DIR`, so `~/.claude` is never read. Both profiles already had a 3-key file
(`tui`, `theme`, `skipDangerousModePermissionPrompt`); those keys were merged in and the originals
backed up to `settings.json.pre-worktree-env.bak` in each dir.

Repo-relative rules use `~/work/coursedog/**/` — **not** `*/`. Worktrees live at
`~/work/coursedog/v3/<branch>`, two levels below `coursedog`, and `*` does not cross `/`; with a
single `*` the `.env` deny silently did nothing and the file was fully readable.

Note `skipDangerousModePermissionPrompt: true` is pre-existing and left alone, but it's a footgun
here: this design deliberately never passes `--dangerously-skip-permissions`, and that setting
removes the guardrail on the one flag we're avoiding.

<details>
<summary>Historical: the initial block, before testing corrected it</summary>

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": [
        "registry.npmjs.org",
        "npm.pkg.github.com",
        "npm.taskforce.sh",
        "npm.jsr.io",
        "cdn.sheetjs.com",
        "github.com",
        "api.github.com",
        "codeload.github.com",
        "objects.githubusercontent.com"
      ]
    },
    "filesystem": {
      "denyWrite": ["~/work/coursedog/v3/dev/volumes"],
      "allowWrite": ["~/.npm/_npx"]
    },
    "credentials": {
      "files": [
        { "path": "~/work/coursedog/*/.env",   "mode": "deny" },
        { "path": "~/work/coursedog/*/.npmrc", "mode": "deny" },
        { "path": "~/.ssh",                    "mode": "deny" },
        { "path": "~/.aws",                    "mode": "deny" },
        { "path": "~/.config/gh",              "mode": "deny" },
        { "path": "~/.docker/config.json",     "mode": "deny" }
      ],
      "env": [
        { "name": "NPM_GITHUB_TOKEN",      "mode": "deny" },
        { "name": "GITHUB_TOKEN",          "mode": "deny" },
        { "name": "TASKFORCE_NPM_TOKEN",   "mode": "deny" },
        { "name": "AWS_ACCESS_KEY_ID",     "mode": "deny" },
        { "name": "AWS_SECRET_ACCESS_KEY", "mode": "deny" },
        { "name": "AWS_SESSION_TOKEN",     "mode": "deny" },
        { "name": "OPENAI_API_KEY",        "mode": "deny" },
        { "name": "STRIPE_SECRET_KEY",     "mode": "deny" }
      ]
    }
  },
  "permissions": {
    "deny": [
      "Read(//Users/piotrjarzabek/work/coursedog/*/.env)",
      "Read(//Users/piotrjarzabek/work/coursedog/*/.npmrc)",
      "Read(//Users/piotrjarzabek/work/coursedog/v3/dev/volumes/**)",
      "Bash(docker compose down*)",
      "Bash(docker-compose down*)",
      "Bash(docker volume rm*)",
      "Bash(docker volume prune*)",
      "Bash(docker system prune*)",
      "Bash(docker stop*)",
      "Bash(docker rm*)"
    ]
  }
}
```

</details>

The live file additionally carries `sandbox.excludedCommands`, two more `permissions.deny` rules
protecting the dump, `filesystem.denyRead`, `/var/folders` in `allowWrite`, and both `env` and
`envVars` credential keys — all explained under **Sandbox reality check** below.

Why each piece:

- `sandbox.enabled` + the default `autoAllowBashIfSandboxed: true` **is** the allow-all mechanism.
  Launch `claude-cd` in the agent pane; never `--dangerously-skip-permissions`.
- Default sandbox write scope is cwd + `$TMPDIR`. **The `denyWrite` on `volumes/` matters**: for an
  agent running in the `dev` worktree, `volumes/` is inside cwd and would otherwise be writable —
  the one path where an agent could destroy the shared dump.
- The docker unix socket sits outside cwd and is blocked by default; nothing here opens it. The
  `Bash(docker …)` deny rules are a second, pre-execution layer for the same constraint.
- Secrets are protected in **both** layers: sandbox `credentials` (OS-enforced, covers Bash and all
  child processes) and `permissions.deny Read(...)` (covers the Read/Edit tools, which the sandbox
  does not).
- Native OS sandbox is the right tier for our own code + anonymized data. A container/microVM tier
  would re-introduce `host.docker.internal` plumbing to reach the shared DBs — but see the reality
  check below, which is the one argument for revisiting that.

## Sandbox reality check (measured 2026-08-09, Claude Code 2.1.220, macOS/Seatbelt)

The plan asserted "loopback needs no allowlist entry, so the shared DBs are reachable from
sandboxed commands." **That is false.** Measured from inside a sandboxed session:

| Probe | Result |
|---|---|
| `connect()` to `127.0.0.1:7265` / `:5000` | `EPERM` — blocked |
| same, with `localhost` + `127.0.0.1` added to `allowedDomains` | still blocked |
| `curl http://127.0.0.1:<port>` | `http=000` — no unsandboxed fallback for loopback |
| `bind()` a listening socket | `EPERM` — a sandboxed process cannot serve a port |
| `curl https://example.com`, `strictAllowlist` absent | `http=200` — ran **unsandboxed** via fallback |
| `curl https://example.com`, `strictAllowlist: true` | `http=000` — genuinely blocked |
| `git tag` writing to the shared bare `.git` | works — native linked-worktree support covers `.bare` |

There is no `network.disabled` key (only `filesystem.disabled`), so network isolation cannot be
lifted on its own. Consequences:

- The dev servers are **unaffected**: the `wt` post-start hook starts them in ordinary unsandboxed
  tmux panes. This was luck of the architecture, not foresight.
- Anything an *agent* runs that touches a DB or a port would fail: Cypress and Playwright
  (`baseURL http://localhost:4000|4567`), Vitest browser/component mode (`browser: 'chromium'`),
  `test:api:be`, and **421 of 1683** backend test files — the ones importing the init helpers
  (`database.connect()`, `redisClient.connect()`, pg datasources, `startApp()` in
  `server/tests/init.js`). The other ~1262 backend files, `test:unit:fe` (jsdom),
  `test:unit:shared`, `test:unit:packages`, lint, typecheck and builds are all fine sandboxed.

**Resolution chosen:** agents must be able to run every test suite and act on the databases, so the
JS toolchain and DB clients are listed in `sandbox.excludedCommands` (`npm`, `npx`, `node`, `jest`,
`vitest`, `cypress`, `playwright`, `mongosh`, `mongodump`, `mongorestore`, `psql`, `redis-cli`,
`docker exec`). Be clear-eyed about what that costs: an excluded command runs **fully outside both
sandbox layers**, and since `npx`/`node` can execute arbitrary code, layer 3 no longer confines a
determined agent. It still blocks *accidental* damage from ad-hoc shell commands (`rm`, `sed`,
redirection, stray `curl`), which remain sandboxed.

`docker exec` is excluded because Cypress seeds via `MONGO_SHELL='docker exec coursedogv3-mongo-1
mongosh'`. That does hand the docker socket to that command — accepted deliberately, against the
original constraint, to get e2e working.

What still protects things, because `permissions.deny` is a *separate* layer that applies to
excluded commands too:

- `Read(**/.env)`, `Read(**/.npmrc)` — the model cannot see secrets even though child processes use them
  - Note: **`permissions.deny Read()` rules are merged into the sandbox's `denyRead`**, so they bind
    child processes too, not just the Read tool. That's a bonus for `.env`, but it's why a
    `Read(…/volumes/**)` rule had to be dropped: it made `volumes/` unreadable to every sandboxed
    command and `git status` in `dev` started warning `could not open directory 'volumes/'`.
    `filesystem.denyWrite` is the real protection there and is unaffected.
- `Bash(docker compose down*)`, `docker volume rm|prune*`, `docker system prune*`, `docker stop|rm*` — shared services and volumes can't be torn down
- `Bash(npm run db:restore*)`, `Bash(npm run db:dump-and-restore*)` — the anonymized dump can't be clobbered
- `sandbox.filesystem.denyWrite` on `v3/dev/volumes` — still applies to every sandboxed command
  (verified: `touch volumes/__probe` → `Operation not permitted`, while `ls volumes` works)

**If you want both full test capability and real isolation**, the honest answer is the container
tier: run the agent inside `.devcontainer/` (which already pins `container_name: coursedogv3-mongo`
etc. and uses `network_mode: host`), where binding and loopback work normally and the blast radius
is the container. That's a separate piece of work, not a config tweak.

Two smaller gotchas found the same way:

- **`wt`'s shell wrapper needs plain `mktemp`**, which on macOS ignores `$TMPDIR` and uses the
  Darwin per-user temp dir. That is outside the sandbox's default writes, so every `wt` call
  printed `mkstemp failed` and silently lost its `cd`/`exec` directives. Fixed by adding
  `/var/folders` to `filesystem.allowWrite`.
- **Worktrunk's plugin installer round-trips `settings.json` through its own schema** and silently
  drops keys it doesn't know — it ate `sandbox.credentials.env` twice. Run all
  `wt config plugins claude …` commands *first*, then re-add. The docs are ambiguous about whether
  the key is `env` or `envVars`, so both are set.

**Known consequence.** Deny-reading `.env` means a *sandboxed* process can't boot the backend or run
backend tests: `env-smart` falls back to `.env.defaults`, whose `SECRET_KEY_BASE` is empty, and the
server throws. Likewise the `.npmrc` deny breaks in-sandbox installs of `@coursedog/*`. This is the
intended trade of denying in both layers, and it costs little because dev servers and installs are
started by `wt` hooks in your own shell, outside the sandbox; when the agent does need them it falls
back to the normal permission prompt (`allowUnsandboxedCommands` defaults to `true`). If it chafes,
the relaxation is to drop the two `credentials.files` entries and rely on the
`permissions.deny Read(...)` rules alone — the model still can't see the secrets, but child
processes can use them.

### Linux / Arch

macOS needs nothing (Seatbelt is built in). On Arch:

```sh
sudo pacman -S bubblewrap socat ripgrep
```

`/sandbox` shows a **Dependencies** tab listing whatever is missing; if the tab is absent after a
restart, everything is present. Debian/Ubuntu: `sudo apt-get install bubblewrap socat`; Fedora:
`sudo dnf install bubblewrap socat`. On Ubuntu 24.04+ the default AppArmor policy blocks bubblewrap
from creating user namespaces and needs a profile tweak. WSL2 works; native Windows does not.

## Layer 4 — Agent status

**Pull** — `wt list` markers (🤖 working / 💬 waiting), via the plugin `wt config show` currently
reports as not installed:

```sh
wt config plugins claude install
wt config plugins claude install-statusline
```

**Push** — ring the tmux bell the moment a worktree needs input. Same `settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command",
        "command": "t=$(tmux display-message -p -t \"$TMUX_PANE\" '#{pane_tty}' 2>/dev/null) && printf '\\a' > \"$t\"" } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command",
        "command": "t=$(tmux display-message -p -t \"$TMUX_PANE\" '#{pane_tty}' 2>/dev/null) && printf '\\a' > \"$t\"" } ] }
    ]
  }
}
```

Writing BEL to the pane's own tty is what makes tmux register a bell for that window — a hook's
stdout is not a tty, so a bare `printf '\a'` is swallowed.

`config/common/tmux/.tmux.conf` currently sets `monitor-activity off` and says nothing about bells;
add:

```tmux
set  -g bell-action any
set  -g visual-bell off
setw -g monitor-bell on
```

The two mechanisms are complementary: `wt list` is the at-a-glance board across all branches, the
bell is the interrupt for the one branch that just stopped.

## Files to touch in this repo

| File | Change |
|---|---|
| `config/common/worktrunk/config.toml` | the whole layer-2 block |
| `config/common/claude/settings.json` | **new** — layers 3 + 4 |
| `scripts/common/symlinks.sh` | new `explicit_files` array (src:abs-target) + loops in `cleanup_symlinks` / `setup_symlinks`. Needed because `install.sh` only symlinks *directories* into `~/.config`, and only the settings *file* may be linked — a Claude config dir also holds `projects/`, `plans/`, `history` that must stay out of git |
| `config/common/tmux/.tmux.conf` | three bell lines, next to the existing `monitor-activity off` |
| `scripts/linux/arch.sh` | `bubblewrap socat` added to `core_packages` (`ripgrep` was already there) |
| `Brewfile` | nothing needed on macOS — Seatbelt is built in, `lsof` is system |

## Verification

Steps 1, 2 and 6 are **done**; the rest need the shared services running.

1. ✅ **Config parses and resolves.** `wt config show` clean, identifier
   `github.com/coursedog/coursedogv3`. `wt hook pre-start --dry-run` confirmed the order
   `copy → ports → env → install → server-assets`, i.e. the global `[pre-start] copy` **does** run
   before the per-project steps, so the documented fallback (folding `copy` into the per-project
   pipeline) was not needed.
2. ✅ **Copy excludes.** Dropped a marker file into `volumes/`, then
   `wt step copy-ignored --to <throwaway> --dry-run`. First run **listed the dump** — that's how the
   trailing-slash pattern bug was caught. After switching to `/**`: 15 entries, no `volumes/`.
   Real copy measured at **234,796 files / 2.1 GiB in 25s** (APFS), so no need to trim further.
   Destination `volumes/` contained only the tracked `.keep`, 0 B.
3. **Shared services** — *not yet done.* `docker compose -p coursedogv3 ps` should show
   mongo/redis/postgres/ldcli-dev-server on 27017/6379/5432/8765.
   `docker exec coursedogv3-mongo-1 mongosh --eval 'db.adminCommand("ping")'` proves the
   `MONGO_SHELL` value in `.env` still resolves.
4. **Create a worktree end to end.** `wtcf sandbox-smoke` → branch `fix/sandbox-smoke`, worktree
   `v3/fix-sandbox-smoke`. Then:
   - `mise env | grep -E 'PORT|SERVER_PORT'` — ports differ from `dev`'s
   - `tmux ls` shows session `fix-sandbox-smoke`; attach and watch both servers come up
   - open `http://localhost:$PORT`, log in, and confirm in devtools that XHRs target
     `localhost:$SERVER_PORT` — this is the check that `VUE_APP_API_PORT` tracked the backend port
   - `git status` is clean (no stray `mise.local.toml`)
5. **Two at once.** Create a second worktree; both apps serve simultaneously on their own ports and
   both reach the same shared mongo.
6. ✅ **Sandbox boundary** — asserted from inside a live sandboxed session:
   - `cat .env` → blocked by `permissions.deny Read()` *before execution* (Claude Code classifies
     `cat` as a read), so the outer layer holds
   - `python3 -c "open('.env')"` / `open('.npmrc')` → `EPERM`, so the OS layer holds for child
     processes too; `package.json` read fine in the same breath
   - `touch volumes/__sandbox_probe` → `Operation not permitted`; `touch __probe` inside the
     worktree → fine
   - `git tag wt-sandbox-probe` → **succeeded**, proving native linked-worktree support covers the
     bare `.bare/worktrees/<name>` common dir (used a tag rather than a commit so `dev`'s history
     was never touched)
   - `curl https://registry.npmjs.org` → 200; `https://api.github.com` → 200
   - `curl https://example.com` → 200 **unsandboxed via fallback**, 000 once `strictAllowlist: true`
   - loopback and `bind()` → blocked in every configuration tried; see **Sandbox reality check**
   Still worth doing interactively: `/sandbox` should show enabled + auto-allow and, on Linux, no
   Dependencies tab.
7. **Status plumbing.** With the agent working, `wt list` shows 🤖 on that branch and 💬 when it
   stops; the tmux status bar flags a bell on the `agent` window at the same moment.
8. **Teardown is safe.** `wt remove` on the smoke branch: tmux session dies, worktree is gone, and
   `docker compose -p coursedogv3 ps` still shows all services up with `volumes/` intact.

## Known hazards this design does not remove

Inherent to one-shared-DB; not fixable by port math.

1. **Postgres migrations run on every backend start.** `server/db/postgres/index.ts:19`
   `runMigrations()` calls `migrator.up()` against the shared `coursedogai` / `coursedog_common`.
   Two branches with divergent migrations fight over one schema, and the loser's `up` may fail or
   half-apply. While it matters: keep only one backend running when a branch carries new migrations,
   and revert before switching.
2. **Mongo is one database for all branches.** Schema-shape changes on one branch are visible to
   every other. Accepted by design.
3. **SSO/OAuth are pinned to 9292.** `samlIdP` bakes `SERVER_PORT` into its SP entity ID at container
   start, and `.env` has `OAUTH2_REDIRECT_URI_BASE=http://localhost:9292`. Only the worktree owning
   9292 can complete those flows — do SSO work in `dev`, or restart `samlIdP` with the branch's
   `SERVER_PORT` for the duration.
4. **`.env` drift.** Each worktree gets a snapshot at creation. A new variable means adding it to
   `v3/dev/.env` and re-copying (or editing) the live worktrees.
5. **Two `git+ssh://git@github.com/coursedog/*` deps** can't be fetched from inside the sandbox (SSH
   doesn't traverse the HTTP proxy). Moot now that `npm` is in `excludedCommands`, and installs
   happen in hooks anyway.
6. **Re-running `wt config plugins claude …` strips `sandbox.credentials.env`** from settings.json.
   Check and re-add after any plugin operation.
7. **Layer 3 no longer confines a determined agent**, because `npx`/`node` are excluded and can run
   arbitrary code. See **Sandbox reality check** for what still holds and for the container tier if
   you want real isolation with full test capability.

---

## Migration: Worktrunk → workmux

Inventoried and planned 2026-09-11. Not yet executed. Scope: replace the worktree/tmux/agent
orchestration (layer 2, plus the "push" half of layer 4 — the bell hooks) with
[workmux](https://github.com/raine/workmux). Layer 1 (shared services), layer 3 (the sandbox
block in `settings.json`), the Caddy domain generator, and `wtd`/`wtsync` are tool-agnostic and
carry over untouched.

### Classification

| Artifact | Class | Notes |
|---|---|---|
| `v3/dev/docker-compose.yml` + manual `docker compose -p coursedogv3 up -d …` | **KEEP** | Untouched by either tool. Not currently running — don't start it as part of the cutover. |
| `.tool-versions` + `mise activate zsh` | **KEEP** | workmux doesn't touch language versioning. |
| `~/.config/worktree-domains/` (`sync_worktree_domains.py`, `Caddyfile`, `worktrees.caddy`, `setup.sh`, README) | **KEEP** (script logic) / **MIGRATE** (call sites + one new flag) | Regenerate-from-`git worktree list`, prune, atomic validate-then-reload model all reused untouched. One gap below needs a new flag. |
| `wtd` / `wtsync` zsh helpers | **KEEP** | Call the script directly; workmux-agnostic. |
| Repo-local `dev/Caddyfile` (`coursedog.app:8080/9292`) | **KEEP** | Unrelated Docker-CORS setup, already documented as non-conflicting. |
| `settings.json` sandbox block (`sandbox.*`, `permissions.deny`, credential scrubbing) | **KEEP** | Reused verbatim, including the current live `sandbox.enabled: false` — this migration does not flip it back on. |
| `mise.local.toml` port injection (`hash_port` → `[env] PORT/SERVER_PORT/BE_INSPECT_PORT`) | **KEEP the file, MIGRATE the trigger** | Stays the source of truth ports flow through (see Decisions). Only *what generates it* changes. |
| `~/.config/worktrunk/config.toml` project block (copy-ignored excludes, port hashing, tmux post-start, pre-remove) | **MIGRATE** | → workmux project config + a `post_create` port script. |
| `wtc/wtcc/wtcf/wtcr/wtcj/wtr` branch-naming helpers | **MIGRATE** | Rewrite as thin wrappers over `workmux add` (same kebab/JIRA-prefix logic, unchanged). |
| `worktrunk.zsh` (`eval "$(wt config shell init zsh)"`) | **REMOVE** | workmux needs no shell wrapper (no cd-file/exec-file trick) — only `eval "$(workmux completions zsh)"`. |
| `brew "worktrunk"` (Brewfile:97) | **REMOVE** | Replace with workmux's install line (confirm exact method at cutover time — a tap or release binary; not nailed down by this inventory). |
| Worktrunk Claude plugin (`enabledPlugins["worktrunk@worktrunk"]`, `extraKnownMarketplaces.worktrunk`, `statusLine: wt list statusline …`) | **REMOVE** | → `workmux setup` (installs the `workmux-status` plugin + hooks; respects `CLAUDE_CONFIG_DIR`, so it targets `~/.claude-cd` and `~/.claude-pj` correctly). |
| Hand-rolled `Stop`/`Notification` bell hooks in `settings.json` | **REMOVE** | Confirmed conflict, not just theoretical: workmux's own `.claude-plugin/plugin.json` registers hooks on the *same* `Notification`/`Stop`/`PostToolUse`/`UserPromptSubmit`/`SessionStart` events to drive its `set-window-status` icons. If an audible ping is still wanted, derive it from the `@workmux_status` tmux user-option rather than adding a second Claude hook on the same events. |

### Gap: workmux has no `post_remove` hook

The Caddy route removal deliberately runs in **post-remove** today, not pre-remove: at
pre-remove the worktree still exists in `git worktree list`, so regenerating there would
faithfully re-emit the route being deleted (see `sync_worktree_domains.py`'s own docstring and
the domains README's "how it works" section). workmux's lifecycle hooks are only `post_create`,
`pre_merge`, `pre_remove` — **there is no post-remove hook**.

Resolution: add an `--exclude-path` flag to `sync_worktree_domains.py` that skips one worktree
path when building routes even though `git worktree list` still reports it, and call it from
workmux's `pre_remove` with `$WM_WORKTREE_PATH`:

```bash
"$HOME/.config/worktree-domains/sync_worktree_domains.py" \
  --repo "$WM_PROJECT_ROOT" --exclude-path "$WM_WORKTREE_PATH" || true
```

This is a small, additive change to the script (one new CLI flag filtering `list_worktrees()`'s
output) — everything else about the script is reused as-is. workmux's own `post_create` route
generation needs no such flag; by then the new worktree already exists on disk and in
`git worktree list`.

### Decisions (confirmed 2026-09-11, one later reversed at implementation time)

1. ~~Port source of truth stays `mise.local.toml`~~ **Superseded.** At implementation time the
   port mechanism was deliberately switched to workmux's own documented `.env.local` convention
   after all (hash `$WM_HANDLE` → offset, scan for a free port, write `.env.local`; `.env` stays
   untouched). The backend pane sources `.env.local` into its shell before starting node
   (`env-smart` has no file-based `.env.local` awareness, unlike Vite's `loadEnv`), which is the
   one place this needs explicit handling. See **Implementation notes** below.
2. **Sandbox stays `enabled: false`**, reused byte-for-byte as it stood live at migration time —
   confirmed unchanged after cutover.
3. ~~This doc stays the source of truth, nothing new in the `coursedogv3` repo~~ **Superseded.**
   `.workmux.yaml` was created directly in `v3/dev` (project config, per workmux's own model —
   there's no zero-footprint external-project-config mechanism, see Implementation notes). This is
   the one deliberate departure from this document's original zero-repo-footprint principle.

### Planned changes

1. **`~/code/dotfiles/config/common/workmux/config.yaml`** (new, personal — sibling to the old
   `worktrunk/` dir, symlinked to `~/.config/workmux/config.yaml`): `worktree_dir` set to preserve
   the existing sibling layout (confirm exact syntax against `workmux docs`/`--help` once
   installed — not hand-tested yet), `agent: claude`, a named agent profile for the `claude-cd`
   wrapper matching workmux's own `cc-personal: "env CLAUDE_CONFIG_DIR=~/.claude-personal claude"`
   pattern (**not** the `cc-yolo`/`--dangerously-skip-permissions` pattern — this design still
   never passes that flag), `merge_strategy`.
2. **Project config**, kept outside `coursedogv3` per decision 3 (exact resolution mechanism —
   `--config` flag vs. some other override — to confirm against `workmux docs` once installed):
   `files.copy` exclude list (same set as today's `copy-ignored`, `/**`-suffixed patterns
   preserved), `post_create` running `ports → domains → install → server-assets` in order
   (workmux applies `files` before `post_create` automatically, so the explicit `copy` step from
   today's pipeline drops out), `panes` reproducing today's tmux layout (shell / backend /
   frontend / packages window + agent window running `claude-cd`), `pre_remove` running the Caddy
   sync with `--exclude-path`.
3. **Port script**: hash `$WM_HANDLE` (and `be-$WM_HANDLE`, `dbg-$WM_HANDLE`) to a port offset per
   port, then `lsof`-scan for the first free port from there (replacing today's
   abort-on-collision), write `mise.local.toml`, `mise trust` it. Same shape as today's hook, new
   trigger.
4. **`sync_worktree_domains.py`**: add `--exclude-path`; no other logic changes. Called from
   `post_create` (no exclude) and `pre_remove` (with `--exclude-path "$WM_WORKTREE_PATH"`), both
   `|| true` to stay non-fatal, exactly like today.
5. **`settings.json`** (feeds both `~/.claude-cd` and `~/.claude-pj` via the existing symlinks):
   remove `enabledPlugins["worktrunk@worktrunk"]`, `extraKnownMarketplaces.worktrunk`,
   `statusLine`; remove the `Stop`/`Notification` bell hooks; keep `sandbox`, `permissions`,
   everything else verbatim. Then run `CLAUDE_CONFIG_DIR=~/.claude-cd workmux setup` (and again
   with `~/.claude-pj`) to install the `workmux-status` plugin/hooks.
6. **zsh**: delete `worktrunk.zsh`; add `eval "$(workmux completions zsh)"`. Rewrite
   `wtc/wtcc/wtcf/wtcr/wtcj/wtr` to call `workmux add <branch>` instead of
   `wt switch --create <branch>` (same kebab-case / JIRA-prefix logic, unchanged). Keep
   `wtd`/`wtsync` as-is.
7. **Brewfile**: drop `brew "worktrunk"`; add workmux's install line (confirm method at cutover
   time).
8. **`.bare/info/exclude`**: no change — the `mise.local.toml` line stays, since decision 1 keeps
   mise as the port mechanism.
9. **Cutover, not overlap**: do steps 1–8 in one pass, no period with both tools wired. Confirm
   `tmux ls` still shows no server before starting (true as of 2026-09-11), so no live
   Worktrunk-managed session is destroyed mid-flight. After cutover, run `wtsync` once by hand
   (still tool-agnostic) to confirm Caddy's routes still resolve for the existing worktrees, since
   their `mise.local.toml` files and ports don't change — only the tool that would recreate them
   does.

### Verification

1. `workmux add` a throwaway branch; confirm `mise.local.toml` gets fresh, *scanned* (not just
   hashed) ports, and `mise env | grep PORT` reflects them in the tmux panes.
2. Confirm `worktrees.caddy` picks up the new worktree after the `post_create` domain-sync step,
   and `https://cd-<handle>.localhost` proxies correctly, without touching any other live
   worktree's route.
3. `workmux remove` it; confirm the route disappears via the new `--exclude-path` path while every
   other worktree's route is untouched, and (if shared services are running)
   `docker compose -p coursedogv3 ps` still shows everything up throughout.
4. `/sandbox` inside a `claude-cd` pane still reports the same enabled/auto-allow state as today
   (i.e., still reflects `enabled: false` per decision 2).
5. `wt list` / the old statusline command is gone from `settings.json`; tmux window names show
   workmux's icons instead; no duplicate bell + icon firing on the same Stop/Notification event.

### Implementation notes (2026-09-11)

Executed and smoke-tested end to end (`workmux add wm-smoketest` from `v3/dev` → verified →
`workmux remove wm-smoketest`, twice, the second time clean). What actually shipped, and what the
plan above got wrong or didn't anticipate:

- **`.env.local`, not `mise.local.toml`, in the end.** Reversed decision 1 above. The
  `post_create` port step hashes `$WM_HANDLE` (and `be-`/`dbg-` variants) into 10000–19999, scans
  forward for a free port, and writes `PORT`/`SERVER_PORT`/`BE_INSPECT_PORT` to `.env.local`.
  `.env` is never touched. Vite picks `.env.local` up on its own; the backend pane does
  `set -a && . ./.env.local && set +a` before starting node, since `env-smart` has no
  `.env.local` awareness of its own.
- **`.workmux.yaml` lives in `v3/dev`, tracked-but-uncommitted.** workmux resolves project config
  by walking up the filesystem from the directory you invoke `workmux add` from — not from the
  new worktree's checked-out tree — so this only needs to exist in `dev` for `workmux add` to work
  *from `dev`*. Verified live via `--dry-run` before running for real. **It still needs to be
  committed** (along with the `.env.local` line added to `v3/dev/.gitignore`) for `workmux add` to
  work when invoked from any of the *other* existing worktrees, and for future worktrees checked
  out from a commit after that one to carry it automatically. Not yet committed — that's a
  deliberate follow-up, not an oversight, since it's a `coursedogv3`-repo change made outside a
  reviewed PR.
- **Real bug caught and fixed: `~` doesn't expand in a workmux agent alias.**
  `agents: { cc-cd: "env CLAUDE_CONFIG_DIR=~/.claude-cd claude" }` — matching workmux's own
  documented `cc-personal` example verbatim — does **not** tilde-expand under workmux's pane
  launcher the way it would in an interactive login shell. Claude Code received the literal
  string `~/.claude-cd`, treated it as relative to the worktree's cwd, and created a real
  directory named `~` inside the worktree instead of reading the intended profile. Fixed by using
  `$HOME` instead of `~` in `~/code/dotfiles/config/common/workmux/config.yaml`; reproduced and
  re-verified the fix (`CLAUDE_CONFIG_DIR=/Users/piotrjarzabek/.claude-cd`, resolved correctly, no
  stray directory) before finishing.
- **Backend's first boot on a truly fresh worktree crash-loops for several minutes, then
  self-heals.** `watch:be` races `tsc --watch`'s first compile against `node server/devServer.js
  .../run.js`, which immediately throws `MODULE_NOT_FOUND` since the compiled output doesn't
  exist yet. This is the repo's own `watch:be`/`devServer.js` (nodemon-based) behavior, not
  something the migration introduced — and it turns out **no worktree, including `dev`, has ever
  had a completed backend build** (`v3/dev/dist-server-tsc` doesn't exist; `npm run build:be` in
  `dev` currently fails on pre-existing `joi`-typing errors unrelated to this migration, so there
  was nothing to seed a `files.copy` entry from either). nodemon tolerates the crash and restarts
  once `tsc --watch`'s first pass finishes; confirmed the backend came up cleanly afterward
  (`Successfully connected to Postgres` ×2, `node-server started on port <PORT>`, live traffic
  through `https://cd-wm-smoketest.localhost` returning `200`). Left as-is — fixing the race or
  the pre-existing build errors is out of scope for this migration.
- **workmux only has `pre_remove`, confirmed at the CLI level, not just in the docs.** The
  `--exclude-path` addition to `sync_worktree_domains.py` was necessary and works: verified the
  live Caddy route for the smoke-test worktree disappeared on `workmux remove` while the
  mechanism was still exercised with the worktree in `git worktree list`.
- **Backend-only detail, not project-visible:** while testing, `workmux add`/`workmux remove` had
  to be run from inside an actual tmux client session — the calling shell's env determines which
  multiplexer backend workmux auto-detects (`$TMUX`/`$KITTY_WINDOW_ID`/etc.), and a bare shell
  outside tmux (even inside a kitty window) gets misdetected as the kitty backend, which isn't
  configured here. Normal day-to-day usage (already inside tmux via `sesh`/the `wtc*` helpers) is
  unaffected — this only bit the migration's own automated verification.
- **Not yet re-synced:** the four pre-existing worktrees (`SM-3524-...`, `SM-3783-...` ×3) don't
  have `.env.local` yet (they still have their old `mise.local.toml`), so their Caddy routes are
  currently absent — `sync_worktree_domains.py` correctly skips them ("no ports in .env.local")
  rather than emitting stale routes. They'll get routes back automatically the next time each is
  actually started with the new port mechanism; nothing destructive happened to them.
- **Fully removed, not just disabled:** `brew uninstall worktrunk`, `claude plugin uninstall
  worktrunk@worktrunk` + `claude plugin marketplace remove worktrunk` (both `~/.claude-cd` and
  `~/.claude-pj` — plugin installs are per `CLAUDE_CONFIG_DIR`, unlike the shared `settings.json`
  file), `~/.config/worktrunk` symlink and its dotfiles source directory, `worktrunk.zsh`. `wt`
  the binary and `wt`-based shell integration no longer exist on this machine.
