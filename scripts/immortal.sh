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
    local url_prefix="https://github.com/"
    
    local branch_option=""
    if [ "$branch_name" != "use_default_branch" ]; then
        branch_option="-b ${branch_name}"
    fi

    mkdir -p "$saved_dir"

    # Create author-specific directory to avoid conflicts between different authors with same repo names
    local repo_path="${clone_dir}/${author_name}/${repository_name}"
    
    # Only clone if repository doesn't exist
    if [ ! -d "$repo_path" ]; then
        echo "Cloning ${author_name}/${repository_name} for the first time..."
        mkdir -p "${clone_dir}/${author_name}"
        git clone --depth=1 ${branch_option} "${url_prefix}${author_name}/${repository_name}.git" "$repo_path"
    else
        echo "Reusing existing ${author_name}/${repository_name} repository..."
    fi

    # Copy (not move) files to preserve the repository for future use
    if [ -d "${repo_path}/${required_dir}" ]; then
        cp -r "${repo_path}/${required_dir}/"* "$saved_dir/"
    else
        echo "Warning: Directory ${required_dir} not found in ${author_name}/${repository_name}"
    fi
}

# Gloang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

# Docker ecosystem
rm -rf feeds/packages/utils/docker
rm -rf feeds/packages/utils/dockerd
# rm -rf feeds/packages/utils/docker-compose
rm -rf feeds/packages/utils/runc
rm -rf feeds/packages/utils/containerd
git clone --depth=1 https://github.com/sbwml/packages_utils_docker.git feeds/packages/utils/docker
git clone --depth=1 https://github.com/sbwml/packages_utils_dockerd.git feeds/packages/utils/dockerd
git clone --depth=1 https://github.com/sbwml/packages_utils_runc.git feeds/packages/utils/runc
git clone --depth=1 https://github.com/sbwml/packages_utils_containerd.git feeds/packages/utils/containerd
# github_partial_clone MilesPoupart packages use_default_branch utils/docker feeds/packages/utils/docker
# github_partial_clone MilesPoupart packages use_default_branch utils/dockerd feeds/packages/utils/dockerd
# github_partial_clone MilesPoupart packages use_default_branch utils/docker-compose feeds/packages/utils/docker-compose
# github_partial_clone MilesPoupart packages use_default_branch utils/runc feeds/packages/utils/runc
# github_partial_clone MilesPoupart packages use_default_branch utils/containerd feeds/packages/utils/containerd

mkdir -p package/community
pushd package/community

git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki
git clone --depth=1 https://github.com/linkease/istore

# Add luci-app-watchcat-plus
rm -rf ../../customfeeds/luci/applications/luci-app-watchcat-plus
git clone https://github.com/0x676e67/luci-app-watchcat-plus.git

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package
rm -rf ../../customfeeds/luci/applications/luci-app-kodexplorer
rm -rf ../../customfeeds/luci/applications/luci-app-socat
rm -rf ../../customfeeds/luci/applications/luci-app-ipsec-server
rm -rf openwrt-package/verysync
rm -rf openwrt-package/luci-app-verysync
rm -rf openwrt-package/luci-app-softethervpn
rm -rf openwrt-package/luci-app-ramfree
rm -rf openwrt-package/luci-app-nginx-pingos

# Add luci-app-irqbalance by QiuSimons https://github.com/QiuSimons/OpenWrt-Add
github_partial_clone QiuSimons OpenWrt-Add use_default_branch luci-app-irqbalance luci-app-irqbalance

# Add luci-app-netspeedtest
rm -rf ../../customfeeds/packages/net/speedtest-cli
rm -rf ../../customfeeds/luci/applications/luci-app-netspeedtest
git clone --depth=1 https://github.com/sirpdboy/luci-app-netspeedtest
rm -rf luci-app-netspeedtest/homebox/Makefile
wget -O luci-app-netspeedtest/homebox/Makefile https://raw.githubusercontent.com/MilesPoupart/homebox/master/OpenWrt-Makefile
sed -i.backup 's|/usr/bin/homebox >> |/usr/bin/homebox serve --port 3300 --host 0.0.0.0 >> |' luci-app-netspeedtest/luci-app-netspeedtest/htdocs/luci-static/resources/view/netspeedtest/homebox.js

# Add luci-app-autotimeset
rm -rf ../../customfeeds/luci/applications/luci-app-taskplan
git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan
sed -i "s/\"control\"/\"system\"/g" luci-app-taskplan/luci-app-taskplan/luasrc/controller/taskplan.lua

# Add mosdns
rm -rf ../../customfeeds/packages/net/mosdns
rm -rf ../../customfeeds/packages/utils/v2dat
rm -rf ../../customfeeds/luci/applications/luci-app-mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns

# Add custom smartdns from MilesPoupart/packages
rm -rf ../../customfeeds/packages/net/smartdns
github_partial_clone MilesPoupart packages master net/smartdns ../../customfeeds/packages/net/smartdns

# Add zerotier
rm -rf ../../customfeeds/packages/net/zerotier
github_partial_clone immortalwrt packages master net/zerotier ../../customfeeds/packages/net/zerotier

# Add luci-app-ssr-plus
git clone --depth=1 https://github.com/fw876/helloworld

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
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages

# Add other applications
rm -rf ../../customfeeds/luci/applications/luci-app-onliner
git clone --depth=1 https://github.com/rufengsuixing/luci-app-onliner
rm -rf ../../customfeeds/luci/applications/luci-app-wechatpush
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush.git

# Add ddnsto & linkease
rm -rf ../../customfeeds/luci/applications/luci-app-ddnsto
rm -rf ../../customfeeds/luci/applications/luci-app-linkease
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-ddnsto luci-app-ddnsto
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-linkease luci-app-linkease
github_partial_clone linkease nas-packages use_default_branch network/services/ddnsto ddnsto
github_partial_clone linkease nas-packages use_default_branch network/services/linkease linkease
github_partial_clone linkease nas-packages use_default_branch network/services/linkmount linkmount
github_partial_clone linkease nas-packages use_default_branch multimedia/ffmpeg-remux ffmpeg-remux

# Add OpenClash
rm -rf ../../customfeeds/luci/applications/luci-app-openclash
github_partial_clone vernesong OpenClash use_default_branch luci-app-openclash luci-app-openclash

# add wrtbwmon
github_partial_clone brvphoenix luci-app-wrtbwmon use_default_branch luci-app-wrtbwmon luci-app-wrtbwmon
github_partial_clone brvphoenix wrtbwmon use_default_branch wrtbwmon wrtbwmon

# Add luci-app-poweroffdevice
git clone --depth=1 https://github.com/sirpdboy/luci-app-poweroffdevice

# Add bandix
git clone --depth=1 https://github.com/timsaya/openwrt-bandix
git clone --depth=1 https://github.com/timsaya/luci-app-bandix

# Add luci-theme
rm -rf ../../customfeeds/luci/themes/luci-theme-argon
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
rm -rf ../../customfeeds/packages/net/openlist2
rm -rf ../../customfeeds/luci/applications/luci-app-openlist2
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2

# qbittorrent
rm -rf ../../customfeeds/packages/net/qBittorrent
rm -rf ../../customfeeds/packages/libs/rblibtorrent
rm -rf ../../customfeeds/luci/applications/luci-app-qbittorrent
git clone --depth=1 https://github.com/sbwml/luci-app-qbittorrent

# ram free and quickfile
rm -rf ../../customfeeds/luci/applications/luci-app-ramfree
rm -rf ../../customfeeds/packages/utils/ramfree
rm -rf ../customfeeds/luci/applications/luci-app-quickfile
rm -rf ../customfeeds/packages/utils/quickfile
git clone --depth=1 https://github.com/sbwml/luci-app-ramfree
git clone --depth=1 https://github.com/sbwml/luci-app-quickfile

# replace luci-app-smartdns (using custom smartdns package from above)
rm -rf ../../customfeeds/luci/applications/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns

# easytier
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git

# Add luci-app-wolplus
rm -rf ../../customfeeds/luci/applications/luci-app-wolplus
github_partial_clone sundaqiang openwrt-packages use_default_branch luci-app-wolplus luci-app-wolplus

# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter

# Add luci-aliyundrive-webdav
rm -rf ../../customfeeds/luci/applications/luci-app-aliyundrive-webdav
rm -rf ../../customfeeds/packages/multimedia/aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/aliyundrive-webdav aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/luci-app-aliyundrive-webdav luci-app-aliyundrive-webdav

# Add luci-app-oled (R2S Only)
git clone --depth=1 https://github.com/NateLol/luci-app-oled

# Replace nginx.config file
rm -rf ../../customfeeds/packages/net/nginx-util/files/nginx.config
cp -f "$GITHUB_WORKSPACE/configs/immortal/nginx.config" ../../customfeeds/packages/net/nginx-util/files/

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

# Cleanup function - uncomment if you want to clean up cloned repositories after build
cleanup_clone_dir() {
    echo "Cleaning up temporary clone directory..."
    rm -rf "$clone_dir"
}

# Uncomment the following line to enable automatic cleanup
cleanup_clone_dir

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd
