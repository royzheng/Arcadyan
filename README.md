# Arcadyan

本仓库集中保存 Arcadyan / OpenWrt 设备使用的 IPK 软件包和维护脚本，并提供可直接复制执行的一键安装命令。

## 仓库内容

### IPK 软件包

- `ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk`：Cloudflare DDNS 脚本。
- `ipk/luci-theme-argon_2.2.4-20200821_all.ipk`：LuCI Argon 主题。
- `ipk/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk`：LuCI Material 主题。

### 脚本

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

### 安装 luci-theme-material

```sh
curl -fL "https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk" -o "/tmp/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk" && opkg install "/tmp/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk"
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

### 安装 luci-theme-material

```sh
curl -fL "https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/ipk/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk" -o "/tmp/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk" && opkg install "/tmp/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk"
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

`router-menu-layout.sh` 支持以下操作：

- `install`：将 WIFI 移至 Network 子菜单，将 Authorization Status 移至 Modem 子菜单，并保留兼容入口。
- `uninstall`：恢复原始菜单布局。
- `status`：查看当前菜单布局，不修改系统。

脚本会在修改前后校验相关 Lua 文件。默认会重启 `uhttpd` 以刷新 LuCI；如需禁止重启，可在执行时设置 `RESTART_UHTTPD=0`。
