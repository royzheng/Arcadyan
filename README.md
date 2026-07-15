# Arcadyan

本仓库集中保存 Arcadyan / OpenWrt 设备使用的 IPK 软件包和维护脚本，并提供可直接复制执行的一键安装命令。

## 仓库内容

### IPK 软件包

- `ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk`：Cloudflare DDNS 脚本。
- `ipk/luci-theme-argon_2.2.4-20200821_all.ipk`：LuCI Argon 主题。

### 脚本

- `scripts/router-bugfixes.sh`：集中应用路由器固件修复。目前包括 LuCI“启动项”页面阻塞修复、移除冲突的旧 `ntpclient` 栈，以及配置标准 `sysntpd`。支持 `apply`、`status`、`verify`；不传参数时默认为 `apply`。
- `scripts/router-menu-layout.sh`：调整或恢复路由器 LuCI 菜单布局，并可查看当前状态。参数必须是 `install`、`uninstall`、`status` 其中之一；不传参数时默认为 `status`。

> 以下命令应在 Arcadyan / OpenWrt 设备的 root shell 中执行。IPK 安装所需的依赖仍由设备上的 `opkg` 负责解析。

## GitHub 直连命令

下面先统一列出所有直接从 GitHub 下载的命令。

### 安装 ddns-scripts-cloudflare

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk" -o "/tmp/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk" && opkg install "/tmp/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk"
```

### 安装 luci-theme-argon

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/luci-theme-argon_2.2.4-20200821_all.ipk" -o "/tmp/luci-theme-argon_2.2.4-20200821_all.ipk" && opkg install "/tmp/luci-theme-argon_2.2.4-20200821_all.ipk"
```

### 应用全部路由器问题修复

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" apply
```

### 查看路由器问题修复状态

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" status
```

### 验证全部路由器问题修复

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" verify
```

### 安装菜单布局

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" install
```

### 卸载菜单布局

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" uninstall
```

### 查看菜单布局状态

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" status
```

## gh-proxy 代理命令

无法直接访问 GitHub 时，可使用代理前缀 `https://gh-proxy.org/`。下面统一列出所有代理下载命令。

### 安装 ddns-scripts-cloudflare

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk" -o "/tmp/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk" && opkg install "/tmp/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk"
```

### 安装 luci-theme-argon

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/luci-theme-argon_2.2.4-20200821_all.ipk" -o "/tmp/luci-theme-argon_2.2.4-20200821_all.ipk" && opkg install "/tmp/luci-theme-argon_2.2.4-20200821_all.ipk"
```

### 应用全部路由器问题修复

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" apply
```

### 查看路由器问题修复状态

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" status
```

### 验证全部路由器问题修复

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-bugfixes.sh" -o "/tmp/router-bugfixes.sh" && sh "/tmp/router-bugfixes.sh" verify
```

### 安装菜单布局

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" install
```

### 卸载菜单布局

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" uninstall
```

### 查看菜单布局状态

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/scripts/router-menu-layout.sh" -o "/tmp/router-menu-layout.sh" && sh "/tmp/router-menu-layout.sh" status
```

## 脚本参数说明

### router-bugfixes.sh

- `apply`：应用全部已登记修复，并在完成后自动验证；不传参数时默认执行此操作。可重复执行，已修复的项目会被跳过。
- `status`：只显示每项修复是 `[pending]` 还是 `[fixed]`，不修改系统。
- `verify`：检查全部修复是否已应用，并验证相关文件语法；任一检查失败时返回非零状态。
- `help`、`-h`、`--help`：显示用法。

目前登记了以下修复：

1. **fibo_rndis procd 锁**：从 `/etc/init.d/fibo_rndis.init` 中删除错误的 `USE_PROCD=1`。该厂商脚本只实现了 `boot()`、没有实现 procd 的 `start_service()`，错误启用 procd 会让相关进程长期持有锁，从而阻塞 LuCI 的“启动项”页面。脚本只在目标内容符合预期时修改文件，修改后会执行 shell 语法验证；在真实设备上还会清理已经阻塞的只读 `enabled` 查询进程。
2. **移除旧 ntpclient**：卸载 `ntpclient`、`luci-app-ntpc` 及所有已安装的 `luci-i18n-ntpc-*` 语言包，并清理旧配置和 LuCI 缓存。旧页面 `/cgi-bin/luci/admin/system/ntpc` 使用独立的 `/etc/config/ntpclient`，其客户端会占用 UDP 123，导致标准 `sysntpd` 在启用服务端模式后启动失败。移除页面后，脚本会停止并重新启动 `uhttpd`，确保 LuCI 菜单缓存立即刷新。
3. **标准 sysntpd 配置**：将下面四个服务器按顺序写入 `/etc/config/system` 的 `system.ntp.server`：

   - `ntp1.aliyun.com`
   - `ntp.tencent.com`
   - `ntp.ntsc.ac.cn`
   - `time.apple.com`

脚本会设置 `system.ntp.use_dhcp=0`，防止 DHCP 追加其他上游；删除可能禁用客户端的 `system.ntp.enabled`，并设置 `system.ntp.enable_server=1`，让路由器同时向上游校时并为局域网提供 NTP 服务。应用后会重启 `sysntpd`，并确认运行命令包含服务端参数 `-l` 和全部四个上游。

NTP 配置会先在临时副本中生成并校验，再替换正式配置；不会提交 LuCI 或其他 UCI 客户端留下的未保存改动。`verify` 会检查 `sysntpd` 进程和启动参数，但不代表对每个公网 NTP 服务器进行实时可达性测试。

`router-bugfixes.sh` 是单向修复聚合脚本，不提供 `uninstall` 或恢复故障的操作。

### router-menu-layout.sh

`router-menu-layout.sh` 支持以下操作：

- `install`：将 WIFI 移至 Network 子菜单，将 Authorization Status 移至 Modem 子菜单，并保留兼容入口。
- `uninstall`：恢复原始菜单布局。
- `status`：查看当前菜单布局，不修改系统。

脚本会在修改前后校验相关 Lua 文件。默认会重启 `uhttpd` 以刷新 LuCI；如需禁止重启，可在执行时设置 `RESTART_UHTTPD=0`。
