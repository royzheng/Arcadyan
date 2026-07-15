#!/bin/sh

set -eu

ACTION="${1:-status}"
ROOT="${ROOT:-}"
RESTART_UHTTPD="${RESTART_UHTTPD:-1}"
WIFI_FILE="${ROOT}/usr/lib/lua/luci/controller/mtkwifi.lua"
HWSYNC_FILE="${ROOT}/usr/lib/lua/luci/controller/admin/hwsync.lua"

WIFI_OLD='entry({"admin", "wifi"}, template("admin_mtk/mtk_wifi_overview"), _("WIFI"), 54).dependent = false'
WIFI_NEW='entry({"admin", "network", "mtkwifi"}, template("admin_mtk/mtk_wifi_overview"), _("WIFI"), 16).dependent = false'
WIFI_ALIAS='entry({"admin", "wifi"}, alias("admin", "network", "mtkwifi"), nil).dependent = false'
WIFI_MARKER='-- router-menu-layout: WIFI moved under Network'

HWSYNC_OLD='entry({"admin", "hwsync"}, call("action_hwsync"), _("Authorization Status"), 55).dependent = false'
HWSYNC_NEW='entry({"admin", "modem", "hwsync"}, call("action_hwsync"), _("Authorization Status"), 20).dependent = false'
HWSYNC_ALIAS='entry({"admin", "hwsync"}, alias("admin", "modem", "hwsync"), nil).dependent = false'
HWSYNC_MARKER='-- router-menu-layout: Authorization Status moved under Modem'

die() {
	echo "ERROR: $*" >&2
	exit 1
}

count_text() {
	grep -F -c -e "$2" "$1" || true
}

line_number() {
	grep -F -n -m 1 -e "$2" "$1" | cut -d: -f1
}

line_at() {
	sed -n "${2}p" "$1"
}

leading_space() {
	sed 's/[^[:space:]].*$//'
}

validate_lua() {
	LUA_FILE="$1" lua -e 'assert(loadfile(os.getenv("LUA_FILE")))'
}

clear_luci_cache() {
	# luci-indexcache stores the menu index, while luci-modulecache stores
	# compiled Lua modules. Both must be removed after editing controllers.
	rm -f "${ROOT}/tmp/luci-indexcache" "${ROOT}"/tmp/luci-indexcache.*.json
	rm -rf "${ROOT}/tmp/luci-modulecache"
}

refresh_luci() {
	if [ -z "$ROOT" ] && [ "$RESTART_UHTTPD" = "1" ]; then
		# Stop first so an in-flight LuCI CGI cannot recreate stale bytecode
		# after the cache has been removed.
		/etc/init.d/uhttpd stop
		clear_luci_cache
		/etc/init.d/uhttpd start
	else
		clear_luci_cache
	fi
}

install_entry() {
	ENTRY_CHANGED=0
	file="$1"
	old="$2"
	new="$3"
	alias_line="$4"
	marker="$5"
	old_count="$(count_text "$file" "$old")"
	new_count="$(count_text "$file" "$new")"
	alias_count="$(count_text "$file" "$alias_line")"
	marker_count="$(count_text "$file" "$marker")"

	if [ "$old_count" = "0" ] && [ "$new_count" = "1" ] && \
	   [ "$alias_count" = "1" ] && [ "$marker_count" = "1" ]; then
		return 0
	fi

	[ "$old_count" = "1" ] || die "expected one original entry in $file, found $old_count"
	[ "$new_count" = "0" ] || die "unexpected new entry already present in $file"
	[ "$alias_count" = "0" ] || die "unexpected compatibility alias already present in $file"
	[ "$marker_count" = "0" ] || die "unexpected marker already present in $file"

	n="$(line_number "$file" "$old")"
	full_old="$(line_at "$file" "$n")"
	indent="$(printf '%s\n' "$full_old" | leading_space)"

	# BusyBox sed: replace the original entry with one reversible three-line block.
	sed -i "${n}c\\
${indent}${marker}\\
${indent}${new}\\
${indent}${alias_line}" "$file"
	ENTRY_CHANGED=1
}

uninstall_entry() {
	ENTRY_CHANGED=0
	file="$1"
	old="$2"
	new="$3"
	alias_line="$4"
	marker="$5"
	old_count="$(count_text "$file" "$old")"
	new_count="$(count_text "$file" "$new")"
	alias_count="$(count_text "$file" "$alias_line")"
	marker_count="$(count_text "$file" "$marker")"

	if [ "$old_count" = "1" ] && [ "$new_count" = "0" ] && \
	   [ "$alias_count" = "0" ] && [ "$marker_count" = "0" ]; then
		return 0
	fi

	[ "$old_count" = "0" ] || die "unexpected original entry already present in $file"
	[ "$new_count" = "1" ] || die "expected one moved entry in $file, found $new_count"
	[ "$alias_count" = "1" ] || die "expected one compatibility alias in $file, found $alias_count"
	[ "$marker_count" = "1" ] || die "expected one marker in $file, found $marker_count"

	n="$(line_number "$file" "$new")"
	[ "$n" -gt 1 ] || die "invalid moved-entry position in $file"
	full_new="$(line_at "$file" "$n")"
	indent="$(printf '%s\n' "$full_new" | leading_space)"
	marker_line="$(line_at "$file" "$((n - 1))")"
	alias_current="$(line_at "$file" "$((n + 1))")"
	[ "$marker_line" = "${indent}${marker}" ] || die "marker is not adjacent to the moved entry in $file"
	[ "$alias_current" = "${indent}${alias_line}" ] || die "alias is not adjacent to the moved entry in $file"

	# Reverse the complete three-line block back to the original menu entry.
	start=$((n - 1))
	end=$((n + 1))
	sed -i "${start},${end}c\\
${indent}${old}" "$file"
	ENTRY_CHANGED=1
}

show_status() {
	if [ "$(count_text "$WIFI_FILE" "$WIFI_NEW")" = "1" ]; then
		echo "WIFI: Network submenu (modified)"
	elif [ "$(count_text "$WIFI_FILE" "$WIFI_OLD")" = "1" ]; then
		echo "WIFI: top-level menu (original)"
	else
		echo "WIFI: unknown layout"
	fi

	if [ "$(count_text "$HWSYNC_FILE" "$HWSYNC_NEW")" = "1" ]; then
		echo "Authorization Status: Modem submenu (modified)"
	elif [ "$(count_text "$HWSYNC_FILE" "$HWSYNC_OLD")" = "1" ]; then
		echo "Authorization Status: top-level menu (original)"
	else
		echo "Authorization Status: unknown layout"
	fi
}

[ -f "$WIFI_FILE" ] || die "missing $WIFI_FILE"
[ -f "$HWSYNC_FILE" ] || die "missing $HWSYNC_FILE"
command -v lua >/dev/null 2>&1 || die "lua command is required"
validate_lua "$WIFI_FILE"
validate_lua "$HWSYNC_FILE"

case "$ACTION" in
	status)
		show_status
		exit 0
		;;
	install|uninstall)
		;;
	*)
		die "usage: $0 {install|uninstall|status}"
		;;
esac

WIFI_CHANGED=0
HWSYNC_CHANGED=0
rollback_on_error() {
	rc=$?
	trap - EXIT
	set +e
	if [ "$WIFI_CHANGED" = "1" ] || [ "$HWSYNC_CHANGED" = "1" ]; then
		echo "Operation failed; reversing completed sed changes." >&2
		if [ "$ACTION" = "install" ]; then
			[ "$HWSYNC_CHANGED" = "1" ] && uninstall_entry "$HWSYNC_FILE" "$HWSYNC_OLD" "$HWSYNC_NEW" "$HWSYNC_ALIAS" "$HWSYNC_MARKER"
			[ "$WIFI_CHANGED" = "1" ] && uninstall_entry "$WIFI_FILE" "$WIFI_OLD" "$WIFI_NEW" "$WIFI_ALIAS" "$WIFI_MARKER"
		else
			[ "$HWSYNC_CHANGED" = "1" ] && install_entry "$HWSYNC_FILE" "$HWSYNC_OLD" "$HWSYNC_NEW" "$HWSYNC_ALIAS" "$HWSYNC_MARKER"
			[ "$WIFI_CHANGED" = "1" ] && install_entry "$WIFI_FILE" "$WIFI_OLD" "$WIFI_NEW" "$WIFI_ALIAS" "$WIFI_MARKER"
		fi
	fi
	exit "$rc"
}
trap rollback_on_error EXIT

if [ "$ACTION" = "install" ]; then
	install_entry "$WIFI_FILE" "$WIFI_OLD" "$WIFI_NEW" "$WIFI_ALIAS" "$WIFI_MARKER"
	WIFI_CHANGED="$ENTRY_CHANGED"
	install_entry "$HWSYNC_FILE" "$HWSYNC_OLD" "$HWSYNC_NEW" "$HWSYNC_ALIAS" "$HWSYNC_MARKER"
	HWSYNC_CHANGED="$ENTRY_CHANGED"
else
	uninstall_entry "$WIFI_FILE" "$WIFI_OLD" "$WIFI_NEW" "$WIFI_ALIAS" "$WIFI_MARKER"
	WIFI_CHANGED="$ENTRY_CHANGED"
	uninstall_entry "$HWSYNC_FILE" "$HWSYNC_OLD" "$HWSYNC_NEW" "$HWSYNC_ALIAS" "$HWSYNC_MARKER"
	HWSYNC_CHANGED="$ENTRY_CHANGED"
fi

validate_lua "$WIFI_FILE"
validate_lua "$HWSYNC_FILE"
trap - EXIT
refresh_luci

if [ "$ACTION" = "install" ]; then
	echo "Menu layout installed successfully."
	echo "WIFI: /cgi-bin/luci/admin/network/mtkwifi"
	echo "Authorization Status: /cgi-bin/luci/admin/modem/hwsync"
else
	echo "Original menu layout restored successfully."
	echo "WIFI: /cgi-bin/luci/admin/wifi"
	echo "Authorization Status: /cgi-bin/luci/admin/hwsync"
fi
