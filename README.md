# Arcadyan

本仓库集中保存 Arcadyan / OpenWrt 设备使用的 IPK 软件包和维护脚本，并提供可直接复制执行的一键安装命令。

## 仓库内容

### IPK 软件包

- `ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk`：Cloudflare DDNS 脚本。
- `ipk/luci-theme-argon_2.2.4-20200821_all.ipk`：LuCI Argon 主题。

### 脚本

- `scripts/router-bugfixes.sh`：集中应用路由器固件修复。目前用于修复 `fibo_rndis.init` 错误启用 procd、导致 LuCI“启动项”页面永久阻塞的问题。支持 `apply`、`status`、`verify`；不传参数时默认为 `apply`。
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

目前登记的修复会从 `/etc/init.d/fibo_rndis.init` 中删除错误的 `USE_PROCD=1`。该厂商脚本只实现了 `boot()`、没有实现 procd 的 `start_service()`，错误启用 procd 会让相关进程长期持有锁，从而阻塞 LuCI 的“启动项”页面。脚本只在目标内容符合预期时修改文件，修改后会执行 shell 语法验证；在真实设备上还会清理已经阻塞的只读 `enabled` 查询进程。

`router-bugfixes.sh` 是单向修复聚合脚本，不提供 `uninstall` 或恢复故障的操作。

### router-menu-layout.sh

`router-menu-layout.sh` 支持以下操作：

- `install`：将 WIFI 移至 Network 子菜单，将 Authorization Status 移至 Modem 子菜单，并保留兼容入口。
- `uninstall`：恢复原始菜单布局。
- `status`：查看当前菜单布局，不修改系统。

脚本会在修改前后校验相关 Lua 文件。默认会重启 `uhttpd` 以刷新 LuCI；如需禁止重启，可在执行时设置 `RESTART_UHTTPD=0`。
