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
UCI_CONFIG_DIR="${ROOT}/etc/config"
UCI_WORKDIR="${ROOT}/tmp/router-bugfixes-uci.$$"
UCI_READ_SAVEDIR="${UCI_WORKDIR}/read-delta"
UCI_STAGE_CONFIG_DIR="${UCI_WORKDIR}/stage-config"
UCI_STAGE_SAVEDIR="${UCI_WORKDIR}/stage-delta"
UCI_RENDER_CONFIG_DIR="${UCI_WORKDIR}/render-config"
UCI_VALIDATE_SAVEDIR="${UCI_WORKDIR}/validate-delta"
UCI_BACKUP_CONFIG_DIR="${UCI_WORKDIR}/backup-config"
SYSTEM_INSTALL_TEMP="${UCI_CONFIG_DIR}/.router-bugfixes-system.$$"

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

cleanup_uci_workdir() {
	rm -rf "$UCI_WORKDIR"
	rm -f "$SYSTEM_INSTALL_TEMP"
}

trap cleanup_uci_workdir EXIT

prepare_uci() {
	command -v uci >/dev/null 2>&1 || die "uci command is required"
	mkdir -p "$UCI_READ_SAVEDIR"
}

uci_at() {
	local config_dir="$1"
	local savedir="$2"
	shift 2
	uci -c "$config_dir" -P "$savedir" "$@"
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
# Fix: remove the legacy ntpclient stack
#
# This firmware also installed luci-app-ntpc and ntpclient. The legacy client
# binds UDP port 123 and prevents BusyBox ntpd from starting with -l when LuCI's
# "Provide NTP server" option is enabled. sysntpd already provides both client
# and server functionality, so remove the redundant stack and its LuCI page.
###############################################################################

LEGACY_NTPC_CONFIG="${ROOT}/etc/config/ntpclient"
LEGACY_NTPC_HOTPLUG="${ROOT}/etc/hotplug.d/iface/20-ntpclient"
LEGACY_NTPC_EXECUTABLE="${ROOT}/usr/sbin/ntpclient"
LEGACY_NTPC_CONTROLLER="${ROOT}/usr/lib/lua/luci/controller/ntpc.lua"
LEGACY_NTPC_MODEL_DIR="${ROOT}/usr/lib/lua/luci/model/cbi/ntpc"
LEGACY_NTPC_ACL="${ROOT}/usr/share/rpcd/acl.d/luci-app-ntpc.json"
UHTTPD_INIT="${ROOT}/etc/init.d/uhttpd"

legacy_ntpc_packages() {
	[ -z "$ROOT" ] || return 0
	opkg list-installed 2>/dev/null | awk '
		$1 == "ntpclient" ||
		$1 == "luci-app-ntpc" ||
		$1 ~ /^luci-i18n-ntpc-/ { print $1 }
	'
}

legacy_ntpc_process_is_running() {
	[ -z "$ROOT" ] && pidof ntpclient >/dev/null 2>&1
}

legacy_ntpc_files_are_present() {
	[ -e "$LEGACY_NTPC_CONFIG" ] ||
	[ -e "$LEGACY_NTPC_HOTPLUG" ] ||
	[ -e "$LEGACY_NTPC_EXECUTABLE" ] ||
	[ -e "$LEGACY_NTPC_CONTROLLER" ] ||
	[ -d "$LEGACY_NTPC_MODEL_DIR" ] ||
	[ -e "$LEGACY_NTPC_ACL" ]
}

legacy_ntpc_is_present() {
	[ -n "$(legacy_ntpc_packages)" ] ||
	legacy_ntpc_process_is_running ||
	legacy_ntpc_files_are_present
}

status_legacy_ntpclient() {
	if legacy_ntpc_is_present; then
		log "[pending] legacy ntpclient removal"
	else
		log "[fixed]   legacy ntpclient removal"
	fi
}

remove_legacy_ntpc_files() {
	rm -f \
		"$LEGACY_NTPC_CONFIG" \
		"$LEGACY_NTPC_HOTPLUG" \
		"$LEGACY_NTPC_EXECUTABLE" \
		"$LEGACY_NTPC_CONTROLLER" \
		"$LEGACY_NTPC_ACL"
	rm -rf "$LEGACY_NTPC_MODEL_DIR"
}

refresh_luci_after_ntpc_removal() {
	if [ -z "$ROOT" ]; then
		[ -x "$UHTTPD_INIT" ] || die "missing executable $UHTTPD_INIT"
		"$UHTTPD_INIT" stop || true
	fi

	rm -f "${ROOT}/tmp/luci-indexcache" "${ROOT}"/tmp/luci-indexcache.*.json
	rm -rf "${ROOT}/tmp/luci-modulecache"

	[ -n "$ROOT" ] || "$UHTTPD_INIT" start
}

fix_legacy_ntpclient() {
	local packages

	if ! legacy_ntpc_is_present; then
		log "[skip]    legacy ntpclient removal (already fixed)"
		return 0
	fi

	if [ -z "$ROOT" ]; then
		command -v opkg >/dev/null 2>&1 || die "opkg command is required"
		killall ntpclient 2>/dev/null || true
		packages="$(legacy_ntpc_packages)"
		if printf '%s\n' "$packages" | grep -q -x ntpclient; then
			# Removing ntpclient recursively removes luci-app-ntpc and all of its
			# installed translation packages in dependency-safe order.
			opkg --force-removal-of-dependent-packages remove ntpclient
		elif [ -n "$packages" ]; then
			opkg --force-depends remove $packages
		fi
	fi

	remove_legacy_ntpc_files
	refresh_luci_after_ntpc_removal
	legacy_ntpc_is_present && die "legacy ntpclient removal did not complete"
	log "[applied] legacy ntpclient removal"
}

verify_legacy_ntpclient() {
	legacy_ntpc_is_present && die "legacy ntpclient is still present"
	log "[verified] legacy ntpclient removal"
}

###############################################################################
# Fix: configure the standard sysntpd service
#
# Use only the requested upstreams, ignore DHCP-advertised peers, enable the
# standard NTP client, and keep "Provide NTP server" enabled for LAN clients.
###############################################################################

NTP_SERVERS='ntp1.aliyun.com ntp.tencent.com ntp.ntsc.ac.cn time.apple.com'
SYSTEM_CONFIG="${UCI_CONFIG_DIR}/system"
SYSNTPD_INIT="${ROOT}/etc/init.d/sysntpd"

require_ntp_configuration() {
	[ -f "$SYSTEM_CONFIG" ] || die "missing $SYSTEM_CONFIG"
	prepare_uci
}

ntp_configuration_is_expected_at() {
	local config_dir="$1"
	local savedir="$2"

	[ "$(uci_at "$config_dir" "$savedir" -q get system.ntp.server 2>/dev/null || true)" = "$NTP_SERVERS" ] || return 1
	[ "$(uci_at "$config_dir" "$savedir" -q get system.ntp.use_dhcp 2>/dev/null || true)" = "0" ] || return 1
	[ "$(uci_at "$config_dir" "$savedir" -q get system.ntp.enable_server 2>/dev/null || true)" = "1" ] || return 1
	[ -z "$(uci_at "$config_dir" "$savedir" -q get system.ntp.enabled 2>/dev/null || true)" ]
}

ntp_configuration_is_expected() {
	ntp_configuration_is_expected_at "$UCI_CONFIG_DIR" "$UCI_READ_SAVEDIR"
}

status_ntp_servers() {
	require_ntp_configuration

	if ntp_configuration_is_expected; then
		log "[fixed]   standard sysntpd configuration"
	else
		log "[pending] standard sysntpd configuration"
	fi
}

prepare_ntp_staging() {
	mkdir -p \
		"$UCI_STAGE_CONFIG_DIR" \
		"$UCI_STAGE_SAVEDIR" \
		"$UCI_RENDER_CONFIG_DIR" \
		"$UCI_VALIDATE_SAVEDIR" \
		"$UCI_BACKUP_CONFIG_DIR"
	cp -p "$SYSTEM_CONFIG" "$UCI_STAGE_CONFIG_DIR/system"
	cp -p "$SYSTEM_CONFIG" "$UCI_BACKUP_CONFIG_DIR/system"
}

render_staged_uci_package() {
	local package="$1"
	local export_file="${UCI_WORKDIR}/${package}.export"

	uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" export "$package" > "$export_file"
	# `uci export` adds a package header used by `uci import`; remove it so the
	# result remains in the conventional /etc/config file format.
	sed '1{/^package /d;}' "$export_file" > "$UCI_RENDER_CONFIG_DIR/$package"
}

prepare_ntp_install_file() {
	local rendered="$1"
	local destination="$2"
	local reference="$3"

	# Copy the existing file first to preserve its owner and mode without relying
	# on `stat`, which is absent from this stripped-down firmware. Redirection
	# then replaces only the contents while keeping that metadata intact.
	cp -p "$reference" "$destination"
	sed -n 'p' "$rendered" > "$destination"
}

restore_ntp_configuration() {
	cp -p "$UCI_BACKUP_CONFIG_DIR/system" "$SYSTEM_CONFIG"
}

install_rendered_ntp_configuration() {
	prepare_ntp_install_file "$UCI_RENDER_CONFIG_DIR/system" "$SYSTEM_INSTALL_TEMP" "$SYSTEM_CONFIG"

	if ! mv -f "$SYSTEM_INSTALL_TEMP" "$SYSTEM_CONFIG"; then
		restore_ntp_configuration
		die "failed to install NTP configuration"
	fi

	if ntp_configuration_is_expected; then
		return 0
	fi

	restore_ntp_configuration
	die "NTP configuration validation failed after update; original file restored"
}

restart_sysntpd() {
	local attempt=0
	local pid

	[ -z "$ROOT" ] || return 0
	[ -x "$SYSNTPD_INIT" ] || die "missing executable $SYSNTPD_INIT"
	"$SYSNTPD_INIT" restart

	while [ "$attempt" -lt 5 ]; do
		pid="$(pidof ntpd 2>/dev/null | awk '{ print $1; exit }')"
		[ -z "$pid" ] || return 0
		attempt=$((attempt + 1))
		sleep 1
	done
	die "sysntpd did not start after configuration update"
}

fix_ntp_servers() {
	require_ntp_configuration

	if ntp_configuration_is_expected; then
		log "[skip]    standard sysntpd configuration (already fixed)"
		return 0
	fi

	prepare_ntp_staging
	uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" -q delete system.ntp.server || true
	for server in $NTP_SERVERS; do
		uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" add_list "system.ntp.server=$server"
	done
	uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" set system.ntp.use_dhcp=0
	uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" set system.ntp.enable_server=1
	uci_at "$UCI_STAGE_CONFIG_DIR" "$UCI_STAGE_SAVEDIR" -q delete system.ntp.enabled || true

	render_staged_uci_package system
	ntp_configuration_is_expected_at "$UCI_RENDER_CONFIG_DIR" "$UCI_VALIDATE_SAVEDIR" || \
		die "rendered NTP configuration validation failed"
	install_rendered_ntp_configuration
	restart_sysntpd
	log "[applied] standard sysntpd configuration"
}

verify_ntp_runtime() {
	local pid
	local argv
	local server

	[ -z "$ROOT" ] || return 0
	pid="$(pidof ntpd 2>/dev/null | awk '{ print $1; exit }')"
	[ -n "$pid" ] || die "sysntpd is not running"
	argv="$(tr '\000' ' ' < "/proc/$pid/cmdline")"
	case " $argv " in *' -l '*) ;; *) die "sysntpd is not providing NTP service (-l missing)" ;; esac
	for server in $NTP_SERVERS; do
		case " $argv " in *" -p $server "*) ;; *) die "sysntpd is missing upstream $server" ;; esac
	done
}

verify_ntp_servers() {
	require_ntp_configuration
	ntp_configuration_is_expected || die "standard sysntpd configuration is not applied"
	verify_ntp_runtime
	log "[verified] standard sysntpd configuration"
}

###############################################################################
# Fix registry
#
# When adding a future fix, register its three functions below. Keeping this
# list explicit makes the execution order and verification coverage obvious.
###############################################################################

apply_all() {
	fix_fibo_rndis_procd_lock
	fix_legacy_ntpclient
	fix_ntp_servers
}

status_all() {
	status_fibo_rndis_procd_lock
	status_legacy_ntpclient
	status_ntp_servers
}

verify_all() {
	verify_fibo_rndis_procd_lock
	verify_legacy_ntpclient
	verify_ntp_servers
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
