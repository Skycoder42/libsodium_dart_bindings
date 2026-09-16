#!/usr/bin/env bash
#
# Branch resolver, update runner and package scanner for the dart-test-tools-auto-update
# skill.
#
# Works out whether this is a *new* dependency update (default branch) or a *fix* for an
# existing one (the auto-update PR branch), puts the worktree on the matching branch, and
# — for a new update — reproduces locally what the shared auto-update workflow does in CI.
# In both cases it then describes the package (or workspace) so the caller knows which
# checks to run where.
#
# It never commits, pushes, merges or rebases. The only mutation it performs on the
# repository itself is switching branches, and only on a clean worktree.
#
set -euo pipefail

readonly SELF="${0##*/}"
readonly UPDATE_BRANCH='automatic-dependency-updates'
readonly AUTO_UPDATE_WORKFLOW='Skycoder42/dart_test_tools/.github/workflows/auto-update.yml'
readonly AUTO_UPDATE_PATTERN='^Skycoder42/dart_test_tools/\.github/workflows/auto-update\.yml@'
readonly CI_PATTERN='^Skycoder42/dart_test_tools/\.github/workflows/(dart|flutter)\.yml@'
readonly OUT_DIR="${TMPDIR:-/tmp}/dart-test-tools-auto-update"

# ASCII unit separator. Used instead of TAB because `read` folds runs of TAB together —
# which would silently shift the fields of a job that sets `unitTestPaths: ""`.
readonly US=$'\x1f'

# Accumulated `warning:` lines. They are collected rather than printed as they happen so
# that the record stays one contiguous block on stdout.
declare -a WARNINGS=()
# Jobs calling the shared auto-update workflow, filled by scan_auto_update_workflows:
#   <file>US<job>US<uses>US<workingDirectory>US<flutterCompat>
declare -a MATCHES=()
# Jobs calling the shared dart/flutter CI workflow, filled by scan_ci_workflows:
#   <absolute workingDirectory>US<unitTestPaths>US<integrationTestPaths>US<buildRunner>
declare -a CI_ENTRIES=()
# One entry per package, filled by scan_packages:
#   <name>US<path>US<tool>US<publishable>US<unitTests>US<integrationTests>US<testSource>US<buildRunner>
declare -a PACKAGE_INFO=()

note() {
	printf '%s: %s\n' "$SELF" "$*" >&2
}

warn() {
	WARNINGS+=("$*")
	printf '%s: warning: %s\n' "$SELF" "$*" >&2
}

# Emits an `error` record and exits non-zero. Reserved for failures of the script itself:
# a bad invocation, an unusable git state, a missing tool. A failing auto_update run is a
# result, not a script failure, and is reported through `update_exit_code` instead.
die() {
	printf '%s: error: %s\n' "$SELF" "$*" >&2
	printf '>>> auto-update-prepare\n'
	printf 'status: error\n'
	local w
	for w in ${WARNINGS[@]+"${WARNINGS[@]}"}; do
		printf 'warning: %s\n' "$w"
	done
	printf 'error: %s\n' "$*"
	printf '<<< auto-update-prepare\n'
	exit 1
}

usage() {
	cat >&2 <<-EOF
		usage: $SELF [<mode>] [ignore-branch]

		  <mode>          'new' (start a fresh dependency update, on the default branch)
		                  or 'existing' (fix the update that is already open on
		                  '$UPDATE_BRANCH'). Optional — when omitted the
		                  mode is derived from the branch that is currently checked out.
		  ignore-branch   Trust that the correct branch is already checked out and skip
		                  every git inspection and branch switch. Requires <mode>.

		Output is a single machine readable record on stdout:

		  >>> auto-update-prepare
		  <key>: <value>
		  ...
		  <<< auto-update-prepare

		Keys are lowercase and may be dotted and indexed ('package.1.name'), values are
		single-line, and everything after the first ': ' belongs to the value. 'warning'
		may appear any number of times, every other key at most once. Progress and
		diagnostics go to stderr and are not part of the record.
	EOF
	exit 64
}

# --- git helpers -----------------------------------------------------------------------

# These are called from command substitutions, so they must never call `die` themselves:
# the error record would be captured by the substitution instead of reaching stdout. They
# report failure through their exit status and let the caller do the dying.

repo_root() {
	git rev-parse --show-toplevel 2>/dev/null
}

current_branch() {
	git rev-parse --verify --quiet HEAD >/dev/null || return 1
	git rev-parse --abbrev-ref HEAD 2>/dev/null
}

worktree_is_clean() {
	[[ -z "$(git status --porcelain --untracked-files=no)" ]]
}

branch_exists() {
	git show-ref --verify --quiet "refs/heads/$1"
}

remote_branch_exists() {
	git show-ref --verify --quiet "refs/remotes/origin/$1"
}

# The default branch, normally 'main'. Falls back to whatever origin/HEAD points at so the
# skill still works in a repository that named its default branch differently.
main_branch() {
	if branch_exists main || remote_branch_exists main; then
		printf 'main\n'
		return
	fi
	local head
	if head="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"; then
		printf '%s\n' "${head#origin/}"
		return
	fi
	printf 'main\n'
}

branch_for_mode() {
	case "$1" in
		new) main_branch ;;
		existing) printf '%s\n' "$UPDATE_BRANCH" ;;
	esac
}

# Reports how far the local branch trails its upstream, if at all. Purely informational —
# the script deliberately does not merge or rebase on the user's behalf.
check_up_to_date() {
	local branch="$1"
	remote_branch_exists "$branch" || return 0
	local behind
	behind="$(git rev-list --count "$branch..origin/$branch" 2>/dev/null || echo 0)"
	((behind > 0)) &&
		warn "local '$branch' is $behind commit(s) behind 'origin/$branch' — it may not reflect the state of the open pull request"
	return 0
}

switch_branch() {
	local branch="$1"

	worktree_is_clean ||
		die "the worktree has uncommitted changes — refusing to switch to '$branch'. Commit or stash them first."

	# Best effort: an offline run must still work as long as the branch exists locally.
	git fetch --quiet origin "$branch" 2>/dev/null ||
		warn "could not fetch 'origin/$branch' — working with the local state only"

	note "switching to '$branch'"
	if branch_exists "$branch"; then
		git switch --quiet "$branch" || die "failed to check out '$branch'"
	elif remote_branch_exists "$branch"; then
		git switch --quiet --create "$branch" --track "origin/$branch" ||
			die "failed to create a local '$branch' tracking 'origin/$branch'"
	else
		die "branch '$branch' exists neither locally nor on origin"
	fi
}

# --- mode resolution -------------------------------------------------------------------

# Sets MODE, BRANCH and BRANCH_CHECK.
resolve_mode() {
	local requested="$1" ignore_branch="$2"

	if [[ $ignore_branch == true ]]; then
		MODE="$requested"
		# Record values have to stay on one line, and `rev-parse` prints 'HEAD' *and*
		# fails when the repository has no commits yet.
		BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
		BRANCH="${BRANCH%%$'\n'*}"
		BRANCH="${BRANCH:-unknown}"
		BRANCH_CHECK=ignored
		warn "branch checks skipped on request — assuming '$MODE' is correct for the current worktree"
		return
	fi

	local branch main
	branch="$(current_branch)" || die "the repository has no commits yet — nothing to resolve a mode from"
	[[ $branch != HEAD ]] || die "HEAD is detached — check out a branch first"
	main="$(main_branch)"

	if [[ -n $requested ]]; then
		local want
		want="$(branch_for_mode "$requested")"
		MODE="$requested"
		if [[ $branch == "$want" ]]; then
			BRANCH_CHECK=matched
		else
			switch_branch "$want"
			BRANCH_CHECK=switched
		fi
		BRANCH="$want"
	else
		case "$branch" in
			"$main") MODE=new ;;
			"$UPDATE_BRANCH") MODE=existing ;;
			*)
				die "branch '$branch' is neither '$main' nor '$UPDATE_BRANCH' — check out one of them, or pass an explicit mode"
				;;
		esac
		BRANCH="$branch"
		BRANCH_CHECK=derived
	fi

	check_up_to_date "$BRANCH"
}

# --- workflow discovery ----------------------------------------------------------------

# `| tostring` turns an absent input into the literal string `null`, which distinguishes
# "not set" from "explicitly set to the empty string" — the two mean different things for
# unitTestPaths. Both scanners run in the current shell so warnings survive.

# Fills MATCHES with one record per job that calls the shared auto-update workflow.
scan_auto_update_workflows() {
	local root="$1" dir="$1/.github/workflows" file rel out line
	MATCHES=()
	[[ -d $dir ]] || return 0

	for file in "$dir"/*.yml "$dir"/*.yaml; do
		[[ -f $file ]] || continue
		rel="${file#"$root"/}"

		if ! out="$(
			yq -r '(.jobs // {}) | to_entries[]
			       | select((.value.uses // "") | test("'"$AUTO_UPDATE_PATTERN"'"))
			       | [.key, .value.uses, (.value.with.workingDirectory | tostring), (.value.with.flutterCompat | tostring)]
			       | join("\t")' "$file" 2>/dev/null | tr '\t' '\037'
		)"; then
			warn "could not parse '$rel' as YAML — skipped"
			continue
		fi

		while IFS= read -r line; do
			[[ -n ${line//[[:space:]]/} ]] || continue
			MATCHES+=("$rel$US$line")
		done <<<"$out"
	done
}

# Fills CI_ENTRIES with the test paths each CI caller job declares, keyed by the absolute
# directory it operates on. Parse failures are silent here — scan_auto_update_workflows
# walks the same files and has already warned about them.
scan_ci_workflows() {
	local root="$1" dir="$1/.github/workflows" file out line
	local wd unit integration build_runner abs
	CI_ENTRIES=()
	[[ -d $dir ]] || return 0

	for file in "$dir"/*.yml "$dir"/*.yaml; do
		[[ -f $file ]] || continue

		out="$(
			yq -r '(.jobs // {}) | to_entries[]
			       | select((.value.uses // "") | test("'"$CI_PATTERN"'"))
			       | [.key, .value.uses, (.value.with.workingDirectory | tostring), (.value.with.unitTestPaths | tostring), (.value.with.integrationTestPaths | tostring), (.value.with.buildRunner | tostring)]
			       | join("\t")' "$file" 2>/dev/null | tr '\t' '\037'
		)" || continue

		while IFS= read -r line; do
			[[ -n ${line//[[:space:]]/} ]] || continue
			IFS=$US read -r _ _ wd unit integration build_runner <<<"$line"
			[[ $wd != null && -n $wd ]] || wd=.
			abs="$(cd "$root/$wd" 2>/dev/null && pwd)" || continue
			CI_ENTRIES+=("$abs$US$unit$US$integration$US$build_runner")
		done <<<"$out"
	done
}

# --- target resolution -----------------------------------------------------------------

# Sets WORKFLOW_FILE, WORKFLOW_JOB, FLUTTER_COMPAT and TARGET from the job that calls the
# shared auto-update workflow. Runs in both modes: `existing` does not update anything,
# but still needs to know which directory the update applies to.
resolve_target() {
	local root="$1"
	WORKFLOW_FILE=none
	WORKFLOW_JOB=none
	FLUTTER_COMPAT=null
	local working_directory=.

	scan_auto_update_workflows "$root"

	if ((${#MATCHES[@]} == 0)); then
		warn "no workflow in .github/workflows calls '$AUTO_UPDATE_WORKFLOW' — falling back to the repository root and the auto_update defaults"
	else
		((${#MATCHES[@]} == 1)) ||
			warn "${#MATCHES[@]} jobs call '$AUTO_UPDATE_WORKFLOW' — using the first one"
		IFS=$US read -r WORKFLOW_FILE WORKFLOW_JOB _ working_directory FLUTTER_COMPAT <<<"${MATCHES[0]}"
		[[ $working_directory != null && -n $working_directory ]] || working_directory=.
	fi

	# In CI the workflow checks out the repository root and points auto_update at
	# `workingDirectory` inside it, so the same relative path applies here.
	TARGET="$(cd "$root/$working_directory" 2>/dev/null && pwd)" ||
		die "workingDirectory '$working_directory' from '$WORKFLOW_FILE' does not exist under '$root'"
	[[ -f $TARGET/pubspec.yaml ]] ||
		die "no pubspec.yaml in '$TARGET' — auto_update needs a dart package"
}

# --- update run ------------------------------------------------------------------------

# Runs auto_update the way the workflow's `Update dependencies` step does.
run_update() {
	# The workflow hardcodes --mode, --bump-version and --report around the two inputs it
	# forwards, so a faithful local run has to pass those too.
	local -a args=(-t "$TARGET" --mode update)
	case "$FLUTTER_COMPAT" in
		false) args+=(--no-flutter-compat) ;;
		*) args+=(--flutter-compat) ;;
	esac
	args+=(--bump-version --report "$UPDATE_REPORT")

	UPDATE_COMMAND="dart run dart_test_tools:auto_update ${args[*]}"
	note "running: $UPDATE_COMMAND"
	note "output goes to $UPDATE_LOG"

	rm -f "$UPDATE_REPORT"
	set +e
	(cd "$TARGET" && dart run dart_test_tools:auto_update "${args[@]}") >"$UPDATE_LOG" 2>&1
	UPDATE_EXIT=$?
	set -e

	[[ -f $UPDATE_REPORT ]] || UPDATE_REPORT=none
	note "auto_update exited with $UPDATE_EXIT"
}

# --- package scanning ------------------------------------------------------------------

package_tool() {
	local sdk
	sdk="$(yq -r '.dependencies.flutter.sdk // .environment.flutter // ""' "$1/pubspec.yaml" 2>/dev/null || true)"
	if [[ -n $sdk && $sdk != null ]]; then
		printf 'flutter\n'
	else
		printf 'dart\n'
	fi
}

# Mirrors the CI's own check: only `publish_to: none` makes a package unpublishable.
package_publishable() {
	local publish_to
	publish_to="$(yq -r '.publish_to // ""' "$1/pubspec.yaml" 2>/dev/null || true)"
	if [[ $publish_to == none ]]; then
		printf 'no\n'
	else
		printf 'yes\n'
	fi
}

# Sets PKG_UNIT, PKG_INTEGRATION, PKG_TEST_SOURCE and PKG_BUILD_RUNNER for the package
# directory $1.
#
# The CI caller workflow is the authority: it splits unit from integration tests through
# the `unitTestPaths` / `integrationTestPaths` inputs, and a package may legitimately have
# a full `test/` directory that CI runs entirely as integration tests. Only when no CI
# caller covers this directory does the layout get guessed, which is flagged as such.
package_tests() {
	local dir="$1" entry path unit integration build_runner

	for entry in ${CI_ENTRIES[@]+"${CI_ENTRIES[@]}"}; do
		IFS=$US read -r path unit integration build_runner <<<"$entry"
		[[ $path == "$dir" ]] || continue
		[[ $unit != null ]] || unit='test' # the input's own default
		[[ $integration != null ]] || integration=''
		PKG_UNIT="${unit:-none}"
		PKG_INTEGRATION="${integration:-none}"
		PKG_TEST_SOURCE=workflow
		if [[ $build_runner == true ]]; then
			PKG_BUILD_RUNNER=yes
		else
			PKG_BUILD_RUNNER=no
		fi
		return
	done

	if [[ -d $dir/test ]] && [[ -n "$(find "$dir/test" -name '*_test.dart' -print -quit 2>/dev/null)" ]]; then
		PKG_UNIT='test'
	else
		PKG_UNIT=none
	fi
	PKG_INTEGRATION=none
	PKG_TEST_SOURCE=heuristic
	# Without a CI caller, fall back to whether build_runner is a dev dependency at all.
	if yq -e '.dev_dependencies.build_runner' "$dir/pubspec.yaml" >/dev/null 2>&1; then
		PKG_BUILD_RUNNER=yes
	else
		PKG_BUILD_RUNNER=no
	fi
}

# Fills PACKAGE_INFO and sets ANALYZE_ROOT and IS_WORKSPACE. `dart pub workspace list`
# needs no resolved .dart_tool, so this works before a `pub get` too.
scan_packages() {
	local target="$1" json='' name path shortest=''

	PACKAGE_INFO=()
	if ! json="$( (cd "$target" && dart pub workspace list --json) 2>/dev/null )"; then
		warn "'dart pub workspace list' failed in '$target' — treating it as a single package"
		json=''
	fi

	local -a found=()
	if [[ -n $json ]]; then
		while IFS=$US read -r name path; do
			[[ -n $name && -n $path ]] || continue
			found+=("$name$US$path")
		done < <(jq -r '.packages[] | [.name, .path] | @tsv' <<<"$json" 2>/dev/null | tr '\t' '\037')
	fi

	if ((${#found[@]} == 0)); then
		name="$(yq -r '.name // "unknown"' "$target/pubspec.yaml" 2>/dev/null || echo unknown)"
		found=("$name$US$target")
	fi

	local entry
	for entry in "${found[@]}"; do
		IFS=$US read -r name path <<<"$entry"
		# Workspace members always live below the root, so the shortest path is the root.
		[[ -n $shortest && ${#shortest} -le ${#path} ]] || shortest="$path"
		package_tests "$path"
		PACKAGE_INFO+=("$name$US$path$US$(package_tool "$path")$US$(package_publishable "$path")$US$PKG_UNIT$US$PKG_INTEGRATION$US$PKG_TEST_SOURCE$US$PKG_BUILD_RUNNER")
	done

	ANALYZE_ROOT="${shortest:-$target}"
	if ((${#PACKAGE_INFO[@]} > 1)); then
		IS_WORKSPACE=yes
	else
		IS_WORKSPACE=no
	fi
}

# --- record ----------------------------------------------------------------------------

emit_record() {
	printf '>>> auto-update-prepare\n'
	printf 'status: ok\n'
	printf 'mode: %s\n' "$MODE"
	printf 'branch: %s\n' "$BRANCH"
	printf 'branch_check: %s\n' "$BRANCH_CHECK"
	printf 'repo_root: %s\n' "$ROOT"
	printf 'workflow_file: %s\n' "$WORKFLOW_FILE"
	printf 'workflow_job: %s\n' "$WORKFLOW_JOB"
	printf 'target: %s\n' "$TARGET"

	if [[ $MODE == new ]]; then
		printf 'update_command: %s\n' "$UPDATE_COMMAND"
		printf 'update_exit_code: %s\n' "$UPDATE_EXIT"
		printf 'update_log: %s\n' "$UPDATE_LOG"
		printf 'update_report: %s\n' "$UPDATE_REPORT"
	fi

	printf 'analyze_root: %s\n' "$ANALYZE_ROOT"
	printf 'workspace: %s\n' "$IS_WORKSPACE"
	printf 'package_count: %s\n' "${#PACKAGE_INFO[@]}"

	local i=0 entry name path tool publishable unit integration source build_runner
	for entry in "${PACKAGE_INFO[@]}"; do
		i=$((i + 1))
		IFS=$US read -r name path tool publishable unit integration source build_runner <<<"$entry"
		printf 'package.%d.name: %s\n' "$i" "$name"
		printf 'package.%d.path: %s\n' "$i" "$path"
		printf 'package.%d.tool: %s\n' "$i" "$tool"
		printf 'package.%d.publishable: %s\n' "$i" "$publishable"
		printf 'package.%d.build_runner: %s\n' "$i" "$build_runner"
		printf 'package.%d.unit_tests: %s\n' "$i" "$unit"
		printf 'package.%d.integration_tests: %s\n' "$i" "$integration"
		printf 'package.%d.test_source: %s\n' "$i" "$source"
	done

	local w
	for w in ${WARNINGS[@]+"${WARNINGS[@]}"}; do
		printf 'warning: %s\n' "$w"
	done
	printf '<<< auto-update-prepare\n'
}

# --- main ------------------------------------------------------------------------------

main() {
	local requested='' ignore_branch=false

	case "${1-}" in
		-h | --help | help) usage ;;
		'' | new | existing) requested="${1-}" ;;
		*) die "invalid mode '$1' — expected 'new' or 'existing'" ;;
	esac

	case "${2-}" in
		'') ;;
		ignore-branch) ignore_branch=true ;;
		*) die "invalid second argument '$2' — the only accepted value is 'ignore-branch'" ;;
	esac

	[[ $# -le 2 ]] || die "too many arguments (expected at most 2)"
	[[ $ignore_branch == false || -n $requested ]] ||
		die "'ignore-branch' has no branch to assume — combine it with an explicit mode"

	command -v git >/dev/null || die "git is not on PATH"
	command -v dart >/dev/null || die "the dart SDK is not on PATH"
	command -v yq >/dev/null || die "yq is not on PATH (it reads the workflow files)"
	command -v jq >/dev/null || die "jq is not on PATH (it reads the workspace listing)"

	ROOT="$(repo_root)" || die "not inside a git repository"
	resolve_mode "$requested" "$ignore_branch"
	resolve_target "$ROOT"
	scan_ci_workflows "$ROOT"

	if [[ $MODE == new ]]; then
		mkdir -p "$OUT_DIR"
		UPDATE_LOG="$OUT_DIR/auto_update.log"
		UPDATE_REPORT="$OUT_DIR/update_report.md"
		run_update
	fi

	# After the update, so that the record describes the post-update state.
	scan_packages "$TARGET"
	emit_record
}

main "$@"
