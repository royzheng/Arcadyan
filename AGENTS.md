# AGENTS.md

## 项目用途

本仓库用于分发 Arcadyan / OpenWrt 设备所需的 IPK 软件包与设备维护脚本。仓库内容应保持简单、可审计，并让用户能够从 README 直接复制一条命令完成安装或执行操作。

## 目录约定

- `ipk/`：存放可直接由 `opkg install` 安装的 `.ipk` 文件。
- `scripts/`：存放可在设备 root shell 中执行的维护脚本。
- `README.md`：列出仓库中的全部 IPK、脚本、参数以及一键命令。

当前文件：

- `ipk/ddns-scripts-cloudflare_2.8.2-r64.1_all.ipk`
- `ipk/luci-theme-argon_2.2.4-20200821_all.ipk`
- `ipk/luci-theme-material_git-22.115.68448-712bc8e-1_all.ipk`
- `scripts/router-menu-layout.sh`

## 下载地址规则

GitHub 直连地址统一使用：

```text
https://github.com/royzheng/Arcadyan/raw/refs/heads/main/<仓库内路径>
```

代理地址只在完整 GitHub 地址前增加 `https://gh-proxy.org/`：

```text
https://gh-proxy.org/https://github.com/royzheng/Arcadyan/raw/refs/heads/main/<仓库内路径>
```

README 的命令顺序必须保持为：先集中列出全部 GitHub 直连 `curl` 命令，再集中列出全部 gh-proxy `curl` 命令，不要将两类命令交叉排列。每个 IPK 和每项脚本操作都要分别列出一键命令。

## 脚本约定

`scripts/router-menu-layout.sh` 仅接受以下参数之一：

- `install`：安装菜单布局调整。
- `uninstall`：撤销菜单布局调整。
- `status`：显示当前布局状态；无参数时也执行此操作。

脚本应继续兼容 OpenWrt 的 `/bin/sh`（BusyBox `ash`）。更新脚本时保留可执行权限，不要引入仅 Bash 支持的语法。脚本会修改 LuCI controller 文件，因此必须保持重复执行安全、修改前后校验以及失败回滚逻辑。

## 更新要求

新增、删除或重命名 IPK/脚本时，同时更新 README 和本文件中的清单。README 中每个文件都必须同时有 GitHub 直连与 gh-proxy 代理命令，并确保文件名、分支名和大小写与仓库完全一致。

提交前至少执行：

```sh
sh -n scripts/*.sh
git diff --check
```

不要提交设备密码、令牌、私钥、配置备份或其他敏感信息。
