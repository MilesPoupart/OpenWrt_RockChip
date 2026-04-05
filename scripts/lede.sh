#!/bin/bash
#=================================================
# System Required: Linux
# Version: 1.0
# License: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

now_dir=$(pwd)
clone_dir="${now_dir}/../git_clone_temporary_space"
mkdir -p "$clone_dir"

function github_partial_clone() {
    local author_name="$1"
    local repository_name="$2"
    local branch_name="$3"
    local required_dir="$4"
    local saved_dir="$5"
    local reset_commit="$6"
    local url_prefix="https://github.com/"
    
    local branch_option=""
    if [ "$branch_name" != "use_default_branch" ]; then
        branch_option="-b ${branch_name}"
    fi

    mkdir -p "$saved_dir"

    # Create author-specific directory to avoid conflicts between different authors with same repo names
    local repo_path="${clone_dir}/${author_name}/${repository_name}"
    
    # Determine if we need full history (when reset_commit is specified)
    local depth_option="--depth=1"
    if [ -n "$reset_commit" ]; then
        depth_option=""
    fi
    
    # Only clone if repository doesn't exist
    if [ ! -d "$repo_path" ]; then
        echo "Cloning ${author_name}/${repository_name} for the first time..."
        mkdir -p "${clone_dir}/${author_name}"
        git clone ${depth_option} ${branch_option} "${url_prefix}${author_name}/${repository_name}.git" "$repo_path"
    else
        echo "Reusing existing ${author_name}/${repository_name} repository..."
        # If reset_commit is specified and repo is shallow, unshallow it
        if [ -n "$reset_commit" ]; then
            pushd "$repo_path" > /dev/null
            if git rev-parse --is-shallow-repository | grep -q true; then
                echo "Repository is shallow, fetching full history for reset..."
                git fetch --unshallow
            fi
            popd > /dev/null
        fi
    fi

    # Reset to specific commit if provided
    if [ -n "$reset_commit" ]; then
        echo "Resetting ${author_name}/${repository_name} to commit ${reset_commit}..."
        pushd "$repo_path" > /dev/null
        git reset --hard "$reset_commit"
        popd > /dev/null
    fi

    # Copy (not move) files to preserve the repository for future use
    if [ -d "${repo_path}/${required_dir}" ]; then
        cp -r "${repo_path}/${required_dir}/"* "$saved_dir/"
    else
        echo "Warning: Directory ${required_dir} not found in ${author_name}/${repository_name}"
    fi
}

# Clone community packages to package/community
rm -rf package/base-files/files/lib/preinit/80_mount_root
cp -f "$GITHUB_WORKSPACE/80_mount_root" package/base-files/files/lib/preinit/80_mount_root

# Gloang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Docker ecosystem
rm -rf feeds/packages/utils/docker
rm -rf feeds/packages/utils/dockerd
rm -rf feeds/packages/utils/runc
rm -rf feeds/packages/utils/containerd
rm -rf feeds/luci/applications/luci-app-dockerman
git clone --depth=1 https://github.com/sbwml/packages_utils_docker.git feeds/packages/utils/docker
git clone --depth=1 https://github.com/sbwml/packages_utils_dockerd.git feeds/packages/utils/dockerd
git clone --depth=1 https://github.com/sbwml/packages_utils_runc.git feeds/packages/utils/runc
git clone --depth=1 https://github.com/sbwml/packages_utils_containerd.git feeds/packages/utils/containerd

mkdir -p package/community
pushd package/community

git clone --depth=1 -b openwrt-24.10 https://github.com/sbwml/luci-app-dockerman.git

# Add luci-app-watchcat-plus
rm -rf ../../customfeeds/luci/applications/luci-app-watchcat-plus
git clone https://github.com/0x676e67/luci-app-watchcat-plus.git

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package
rm -rf ../../customfeeds/luci/applications/luci-app-kodexplorer
rm -rf ../../customfeeds/luci/applications/luci-app-ipsec-server
rm -rf ../../customfeeds/luci/applications/luci-app-openvpn-server
rm -rf openwrt-package/verysync
rm -rf openwrt-package/luci-app-verysync
rm -rf openwrt-package/luci-app-softethervpn
rm -rf openwrt-package/luci-app-ramfree
rm -rf openwrt-package/luci-app-nginx-pingos
rm -rf openwrt-package/luci-app-socat
# rm -rf openwrt-package/luci-app-socat/root/etc/config
rm -rf openwrt-package/luci-app-openvpn-server/root/etc/config

# Add luci-app-socat
rm -rf ../../customfeeds/luci/applications/luci-app-socat
github_partial_clone sbwml openwrt_pkgs use_default_branch luci-app-socat luci-app-socat

# Add luci-app-irqbalance by QiuSimons https://github.com/QiuSimons/OpenWrt-Add
github_partial_clone QiuSimons OpenWrt-Add use_default_branch luci-app-irqbalance luci-app-irqbalance

# Add luci-app-passwall
rm -rf ../../customfeeds/luci/applications/luci-app-passwall
rm -rf ../../customfeeds/luci/applications/luci-app-passwall2
rm -rf ../../customfeeds/packages/net/chinadns-ng
rm -rf ../../customfeeds/packages/net/dns2socks
rm -rf ../../customfeeds/packages/net/geoview
rm -rf ../../customfeeds/packages/net/hysteria
rm -rf ../../customfeeds/packages/net/ipt2socks
rm -rf ../../customfeeds/packages/net/microsocks
rm -rf ../../customfeeds/packages/net/naiveproxy
rm -rf ../../customfeeds/packages/net/shadow-tls
rm -rf ../../customfeeds/packages/net/shadowsocks-libev
rm -rf ../../customfeeds/packages/net/shadowsocks-rust
rm -rf ../../customfeeds/packages/net/shadowsocksr-libev
rm -rf ../../customfeeds/packages/net/simple-obfs
rm -rf ../../customfeeds/packages/net/sing-box
rm -rf ../../customfeeds/packages/net/tcping
rm -rf ../../customfeeds/packages/net/trojan-plus
rm -rf ../../customfeeds/packages/net/tuic-client
rm -rf ../../customfeeds/packages/net/v2ray-geodata
rm -rf ../../customfeeds/packages/net/v2ray-plugin
rm -rf ../../customfeeds/packages/net/xray-core
rm -rf ../../customfeeds/packages/net/xray-plugin
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages

# Add luci-app-netspeedtest
rm -rf ../../customfeeds/packages/net/ookla-speedtest
rm -rf ../../customfeeds/packages/net/homebox
rm -rf ../../customfeeds/luci/applications/luci-app-netspeedtest
git clone --depth=1 https://github.com/sirpdboy/netspeedtest

# Add luci-app-taskplan
rm -rf ../../customfeeds/luci/applications/luci-app-taskplan
git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan
# 移除control菜单定义，只保留taskplan项到system菜单下
sed -i '/"admin\/control": {/,/^[[:space:]]*},$/d' luci-app-taskplan/luci-app-taskplan/root/usr/share/luci/menu.d/luci-app-taskplan.json
sed -i 's/"admin\/control\/taskplan"/"admin\/system\/taskplan"/g' luci-app-taskplan/luci-app-taskplan/root/usr/share/luci/menu.d/luci-app-taskplan.json

# Add mosdns
rm -rf ../../customfeeds/packages/net/mosdns
rm -rf ../../customfeeds/packages/utils/v2dat
rm -rf ../../customfeeds/luci/applications/luci-app-mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns

# Add luci-app-ssr-plus
git clone --depth=1 https://github.com/fw876/helloworld

# Add luci-app-unblockneteasemusic
rm -rf ../../customfeeds/luci/applications/luci-app-unblockmusic
git clone --depth=1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git

# Add luci-app-vssr <M>
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/MilesPoupart/luci-app-vssr

# Add luci-proto-minieap
git clone --depth=1 https://github.com/ysc3839/luci-proto-minieap

# Add OpenClash
rm -rf ../../customfeeds/luci/applications/luci-app-openclash
github_partial_clone vernesong OpenClash use_default_branch luci-app-openclash luci-app-openclash 79dee90996b99dbac377c220914b0d73b2941e0d

# Add ddnsto & linkease
rm -rf ../../customfeeds/luci/applications/luci-app-ddnsto
rm -rf ../../customfeeds/luci/applications/luci-app-linkease
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-ddnsto luci-app-ddnsto
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-linkease luci-app-linkease
github_partial_clone linkease nas-packages use_default_branch network/services/ddnsto ddnsto
github_partial_clone linkease nas-packages use_default_branch network/services/linkease linkease
github_partial_clone linkease nas-packages use_default_branch network/services/linkmount linkmount
github_partial_clone linkease nas-packages use_default_branch multimedia/ffmpeg-remux ffmpeg-remux

# Add luci-app-onliner (need luci-app-nlbwmon)
git clone --depth=1 https://github.com/rufengsuixing/luci-app-onliner

# Add luci-app-oled (R2S Only)
git clone --depth=1 https://github.com/NateLol/luci-app-oled

# add wrtbwmon
github_partial_clone brvphoenix luci-app-wrtbwmon use_default_branch luci-app-wrtbwmon luci-app-wrtbwmon
github_partial_clone brvphoenix wrtbwmon use_default_branch wrtbwmon wrtbwmon

# Add ServerChan
rm -rf ../../customfeeds/luci/applications/luci-app-serverchan
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush.git

# Add luci-app-dockerman
# rm -rf ../../customfeeds/luci/collections/luci-lib-docker
# rm -rf ../../customfeeds/luci/applications/luci-app-docker
# rm -rf ../../customfeeds/luci/applications/luci-app-dockerman
# github_partial_clone lisaac luci-app-dockerman use_default_branch applications/luci-app-dockerman luci-app-dockerman
# github_partial_clone lisaac luci-lib-docker use_default_branch collections/luci-lib-docker luci-lib-docker

# Add luci-theme
rm -rf ../../customfeeds/luci/themes/luci-theme-argon
rm -rf ../../customfeeds/luci/themes/luci-theme-argon-mod
rm -rf ../../customfeeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ./luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f "$GITHUB_WORKSPACE/data/bg1.jpg" luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
rm -rf ../../customfeeds/luci/themes/luci-theme-design
rm -rf ../../customfeeds/luci/applications/luci-app-design-config
git clone --depth=1 https://github.com/0x676e67/luci-app-design-config
git clone --depth=1 https://github.com/0x676e67/luci-theme-design

# Add subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter

# Add luci-app-lucky
rm -rf ../../customfeeds/packages/net/lucky
rm -rf ../../customfeeds/luci/applications/luci-app-lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky

# Add openlist2
rm -rf ../../customfeeds/packages/net/openlist
rm -rf ../../customfeeds/luci/applications/luci-app-openlist
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2

# qbittorrent
rm -rf ../../customfeeds/packages/net/qBittorrent
rm -rf ../../customfeeds/packages/libs/rblibtorrent
rm -rf ../../customfeeds/luci/applications/luci-app-qbittorrent
git clone --depth=1 https://github.com/sbwml/luci-app-qbittorrent

# ram free and quickfile
rm -rf ../../customfeeds/luci/applications/luci-app-ramfree
rm -rf ../../customfeeds/luci/applications/luci-app-quickfile
rm -rf ../../customfeeds/packages/utils/quickfile
rm -rf ../../customfeeds/packages/utils/ramfree
git clone --depth=1 https://github.com/sbwml/luci-app-ramfree
git clone --depth=1 https://github.com/sbwml/luci-app-quickfile

# easytier
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git

# Add luci-app-smartdns & smartdns
# rm -rf ../../customfeeds/luci/applications/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/luci-app-smartdns

# Add zerotier
rm -rf ../../customfeeds/packages/net/zerotier
git clone --depth=1 https://github.com/MilesPoupart/feeds_packages_net_zerotier.git ../../customfeeds/packages/net/zerotier
# git clone --depth=1 https://github.com/sbwml/feeds_packages_net_zerotier.git ../../customfeeds/packages/net/zerotier

# Add luci-app-ustreamer
rm -rf ../../customfeeds/luci/applications/luci-app-ustreamer
github_partial_clone immortalwrt luci master applications/luci-app-ustreamer ../../customfeeds/luci/applications/luci-app-ustreamer

# Add luci-app-wolplus
rm -rf ../../customfeeds/luci/applications/luci-app-wolplus
github_partial_clone sundaqiang openwrt-packages use_default_branch luci-app-wolplus luci-app-wolplus

# Add luci-app-poweroffdevice
git clone --depth=1 https://github.com/sirpdboy/luci-app-poweroffdevice

# Add bandix
git clone --depth=1 https://github.com/timsaya/openwrt-bandix
git clone --depth=1 https://github.com/timsaya/luci-app-bandix

# Add OpenAppFilter
rm -rf ../../customfeeds/luci/applications/luci-app-openappfilter
rm -rf ../../customfeeds/packages/net/open-app-filter
git clone --depth=1 https://github.com/destan19/OpenAppFilter

# Add luci-aliyundrive-webdav
rm -rf ../../customfeeds/luci/applications/luci-app-aliyundrive-webdav
rm -rf ../../customfeeds/packages/multimedia/aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/aliyundrive-webdav aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/luci-app-aliyundrive-webdav luci-app-aliyundrive-webdav

BASE_DIR="$(pwd)"

# 使用 find 查找所有以 /po/zh-cn 结尾的目录
find "$BASE_DIR" -type d -path "*/po/zh-cn" | while IFS= read -r zh_cn_dir; do
    # 获取 po 目录的路径
    po_dir=$(dirname "$zh_cn_dir")
    
    # 定义 zh_Hans 目录的路径
    zh_Hans_dir="zh_Hans"

    # 使用 pushd 进入 po 目录
    pushd "$po_dir" > /dev/null
    if [ $? -ne 0 ]; then
        echo "错误: 无法进入目录: $po_dir"
        continue
    fi

    # 检查 zh_Hans 是否已经存在（包括文件、目录或链接）
    if [ ! -e "$zh_Hans_dir" ]; then
        # 创建指向 zh-cn 的软链接 zh_Hans
        ln -s "zh-cn" "$zh_Hans_dir"
        if [ $? -eq 0 ]; then
            echo "✅ 创建软链接: $po_dir/$zh_Hans_dir -> zh-cn"
        else
            echo "❌ 错误: 无法创建软链接: $po_dir/$zh_Hans_dir"
        fi
    fi

    # 使用 popd 返回原工作目录
    popd > /dev/null
    if [ $? -ne 0 ]; then
        echo "❌ 错误: 无法返回到原工作目录"
        exit 1
    fi
done

popd

# Add Pandownload
pushd package/lean
rm -rf ../../customfeeds/packages/net/pandownload-fake-server
github_partial_clone immortalwrt packages use_default_branch net/pandownload-fake-server pandownload-fake-server
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
sed -i '/18.06/d' zzz-default-settings
export orig_version=$(grep DISTRIB_REVISION= zzz-default-settings | awk -F "'" '{print $2}')
export date_version=$(date -d "$(rdate -n -4 -p ntp.aliyun.com)" +'%Y-%m-%d')
sed -i "s/${orig_version}/${orig_version} (${date_version})/g" zzz-default-settings
popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
github_partial_clone openwrt packages use_default_branch libs/libssh libssh
popd

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Cleanup function - uncomment if you want to clean up cloned repositories after build
cleanup_clone_dir() {
    echo "Cleaning up temporary clone directory..."
    rm -rf "$clone_dir"
}

# Uncomment the following line to enable automatic cleanup
cleanup_clone_dir