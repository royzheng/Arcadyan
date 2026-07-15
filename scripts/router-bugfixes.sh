#!/bin/sh

# OpenWrt router bug-fix aggregator.
#
# Purpose
# -------
# Keep small, device-specific fixes in one repeatable script instead of
# scattering one-off sed commands across the router. Running `apply` multiple
# times must always be safe and must converge to the same fixed state.
#
# Design rules for future maintainers (including AI assistants)
# --------------------------------------------------------------
# 1. Put every bug fix in its own `fix_*()` function.
# 2. A fix must first detect the current state and do nothing when already fixed.
# 3. Match the smallest possible, well-known source text. Stop with an error if
#    the target file has an unexpected layout instead of editing it blindly.
# 4. Add a matching `status_*()` and `verify_*()` function for every new fix.
# 5. Register new functions in apply_all(), status_all(), and verify_all().
# 6. Do not create persistent backup/state files. This is a one-way bug-fix
#    aggregator; it intentionally does not provide an action that restores bugs.
# 7. Keep this script compatible with BusyBox /bin/sh used by OpenWrt 19.07.
#
# Commands
# --------
#   apply   Apply every registered fix (default).
#   status  Show whether each registered fix is pending or already applied.
#   verify  Fail unless every registered fix is present and target syntax is OK.
#
# Testing support
# ---------------
# Set ROOT to an extracted test root to test file edits without touching the
# live router, for example: ROOT=/tmp/router-root ./router-bugfixes.sh apply

set -eu

ACTION="${1:-apply}"
ROOT="${ROOT:-}"

log() {
	printf '%s\n' "$*"
}

die() {
	printf 'ERROR: %s\n' "$*" >&2
	exit 1
}

count_matching_lines() {
	# Arguments: file, basic regular expression
	# `grep -c` exits 1 when there are no matches, so always return the count.
	grep -c -e "$2" "$1" 2>/dev/null || true
}

###############################################################################
# Fix: fibo_rndis.init permanently blocks LuCI's Startup page
#
# Root cause:
#   The vendor script sets USE_PROCD=1 but implements only boot(), not the
#   procd start_service() contract. Sourcing procd.sh takes FD 1000 as a lock.
#   A daemon started from boot() (observed as `wapp`) inherits that descriptor
#   and keeps /tmp/lock/procd_fibo_rndis.init.lock held forever. LuCI's
#   luci.getInitList RPC then blocks on `fibo_rndis.init enabled`.
#
# Why this fix is safe for the inspected firmware:
#   Removing USE_PROCD=1 does not remove boot() and does not change the RNDIS
#   configuration performed by /usr/bin/mtk_usb_tether_on.sh. The script does
#   not define start_service(), so procd was not supervising the service anyway.
###############################################################################

FIBO_RNDIS_INIT="${ROOT}/etc/init.d/fibo_rndis.init"
FIBO_PROCD_RE='^[[:space:]]*USE_PROCD[[:space:]]*=[[:space:]]*1[[:space:]]*$'

status_fibo_rndis_procd_lock() {
	[ -f "$FIBO_RNDIS_INIT" ] || die "missing $FIBO_RNDIS_INIT"

	count="$(count_matching_lines "$FIBO_RNDIS_INIT" "$FIBO_PROCD_RE")"
	case "$count" in
		0) log "[fixed]   fibo_rndis procd lock" ;;
		1) log "[pending] fibo_rndis procd lock" ;;
		*) die "unexpected USE_PROCD=1 count in $FIBO_RNDIS_INIT: $count" ;;
	esac
}

cleanup_fibo_rndis_waiters() {
	# Existing LuCI/RPC status checks may already be blocked in `flock 1000`.
	# Kill only processes whose exact command is the read-only `enabled` query;
	# never kill wapp, RNDIS, network, or other service processes.
	[ -z "$ROOT" ] || return 0

	for pid in $(ps w | awk '$0 ~ /\/etc\/rc\.common \/etc\/init\.d\/fibo_rndis\.init enabled[[:space:]]*$/ { print $1 }'); do
		children="$(cat "/proc/$pid/task/$pid/children" 2>/dev/null || true)"
		[ -z "$children" ] || kill $children 2>/dev/null || true
		kill "$pid" 2>/dev/null || true
	done
}

fix_fibo_rndis_procd_lock() {
	[ -f "$FIBO_RNDIS_INIT" ] || die "missing $FIBO_RNDIS_INIT"

	count="$(count_matching_lines "$FIBO_RNDIS_INIT" "$FIBO_PROCD_RE")"
	case "$count" in
		0)
			log "[skip]    fibo_rndis procd lock (already fixed)"
			;;
		1)
			# BusyBox sed supports -i without a backup suffix. The exact active
			# assignment is removed; commented examples and other settings remain.
			sed -i "/$FIBO_PROCD_RE/d" "$FIBO_RNDIS_INIT"
			sh -n "$FIBO_RNDIS_INIT" || die "shell syntax validation failed: $FIBO_RNDIS_INIT"
			cleanup_fibo_rndis_waiters
			log "[applied] fibo_rndis procd lock"
			;;
		*)
			die "unexpected USE_PROCD=1 count in $FIBO_RNDIS_INIT: $count"
			;;
	esac
}

verify_fibo_rndis_procd_lock() {
	[ -f "$FIBO_RNDIS_INIT" ] || die "missing $FIBO_RNDIS_INIT"
	sh -n "$FIBO_RNDIS_INIT" || die "shell syntax validation failed: $FIBO_RNDIS_INIT"
	count="$(count_matching_lines "$FIBO_RNDIS_INIT" "$FIBO_PROCD_RE")"
	[ "$count" = "0" ] || die "fibo_rndis procd lock fix is not applied"
	log "[verified] fibo_rndis procd lock"
}

###############################################################################
# Fix registry
#
# When adding a future fix, register its three functions below. Keeping this
# list explicit makes the execution order and verification coverage obvious.
###############################################################################

apply_all() {
	fix_fibo_rndis_procd_lock
}

status_all() {
	status_fibo_rndis_procd_lock
}

verify_all() {
	verify_fibo_rndis_procd_lock
}

case "$ACTION" in
	apply)
		apply_all
		verify_all
		log "All router bug fixes are applied."
		;;
	status)
		status_all
		;;
	verify)
		verify_all
		log "All router bug fixes passed verification."
		;;
	-h|--help|help)
		log "Usage: $0 {apply|status|verify}"
		;;
	*)
		die "usage: $0 {apply|status|verify}"
		;;
esac
