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

    if [ ! -d "${clone_dir}/${repository_name}" ]; then
        git clone --depth=1 ${branch_option} "${url_prefix}${author_name}/${repository_name}.git" "${clone_dir}/${repository_name}"
    fi

    mv "${clone_dir}/${repository_name}/${required_dir}/"* "$saved_dir"
    rm -rf "${clone_dir}/${repository_name}"
}

# Clone community packages to package/community
rm -rf package/base-files/files/lib/preinit/80_mount_root
cp -f "$GITHUB_WORKSPACE/80_mount_root" package/base-files/files/lib/preinit/80_mount_root

# Gloang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

mkdir -p package/community
pushd package/community

# Add luci-app-watchcat-plus
rm -rf ../../customfeeds/luci/applications/luci-app-watchcat-plus
git clone https://github.com/MilesPoupart/luci-app-watchcat-plus.git

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package
rm -rf ../../customfeeds/luci/applications/luci-app-kodexplorer
rm -rf ../../customfeeds/luci/applications/luci-app-socat
rm -rf ../../customfeeds/luci/applications/luci-app-ipsec-server
rm -rf openwrt-package/verysync
rm -rf openwrt-package/luci-app-verysync
rm -rf openwrt-package/luci-app-softethervpn
rm -rf openwrt-package/luci-app-ramfree

# Add luci-app-irqbalance by QiuSimons https://github.com/QiuSimons/OpenWrt-Add
github_partial_clone QiuSimons OpenWrt-Add use_default_branch luci-app-irqbalance luci-app-irqbalance

# Add luci-app-passwall
rm -rf ../../customfeeds/luci/applications/luci-app-passwall
rm -rf ../../customfeeds/luci/applications/luci-app-passwall2
rm -rf ../../customfeeds/packages/net/brook
rm -rf ../../customfeeds/packages/net/chinadns-ng
rm -rf ../../customfeeds/packages/net/dns2socks
rm -rf ../../customfeeds/packages/net/dns2tcp
rm -rf ../../customfeeds/packages/net/gn
rm -rf ../../customfeeds/packages/net/hysteria
rm -rf ../../customfeeds/packages/net/ipt2socks
rm -rf ../../customfeeds/packages/net/microsocks
rm -rf ../../customfeeds/packages/net/naiveproxy
rm -rf ../../customfeeds/packages/net/pdnsd-alt
rm -rf ../../customfeeds/packages/net/shadowsocks-rust
rm -rf ../../customfeeds/packages/net/shadowsocksr-libev
rm -rf ../../customfeeds/packages/net/simple-obfs
rm -rf ../../customfeeds/packages/net/sing-box
rm -rf ../../customfeeds/packages/net/ssocks
rm -rf ../../customfeeds/packages/net/tcping
rm -rf ../../customfeeds/packages/net/trojan-go
rm -rf ../../customfeeds/packages/net/trojan-plus
rm -rf ../../customfeeds/packages/net/trojan
rm -rf ../../customfeeds/packages/net/tuic-client
rm -rf ../../customfeeds/packages/net/v2ray-core
rm -rf ../../customfeeds/packages/net/v2ray-geodata
rm -rf ../../customfeeds/packages/net/v2ray-plugin
rm -rf ../../customfeeds/packages/net/xray-core
rm -rf ../../customfeeds/packages/net/xray-plugin
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages

# Add luci-app-netdata
rm -rf ../../customfeeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata

# Add luci-app-partexp
rm -rf ../../customfeeds/luci/applications/luci-app-partexp
git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp

# Add luci-app-netspeedtest
rm -rf ../../customfeeds/luci/applications/luci-app-netspeedtest
git clone --depth=1 https://github.com/sirpdboy/NetSpeedTest

# Add luci-app-autotimeset
rm -rf ../../customfeeds/luci/applications/luci-app-autotimeset
git clone --depth=1 https://github.com/sirpdboy/luci-app-autotimeset
sed -i "s/\"control\"/\"system\"/g" luci-app-autotimeset/luasrc/controller/autotimeset.lua

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
github_partial_clone vernesong OpenClash use_default_branch luci-app-openclash luci-app-openclash

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
rm -rf ../../customfeeds/luci/collections/luci-lib-docker
rm -rf ../../customfeeds/luci/applications/luci-app-docker
rm -rf ../../customfeeds/luci/applications/luci-app-dockerman
github_partial_clone lisaac luci-app-dockerman use_default_branch applications/luci-app-dockerman luci-app-dockerman
github_partial_clone lisaac luci-lib-docker use_default_branch collections/luci-lib-docker luci-lib-docker
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
git clone --depth=1 https://github.com/MilesPoupart/luci-app-design-config
git clone --depth=1 https://github.com/MilesPoupart/luci-theme-design

# Add subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter

# Add luci-app-lucky
rm -rf ../../customfeeds/packages/net/lucky
rm -rf ../../customfeeds/luci/applications/luci-app-lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky

# Add alist
rm -rf ../../customfeeds/packages/net/alist
rm -rf ../../customfeeds/luci/applications/luci-app-alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist

# qbittorrent
rm -rf ../../customfeeds/packages/net/qBittorrent
rm -rf ../../customfeeds/packages/libs/rblibtorrent
rm -rf ../../customfeeds/luci/applications/luci-app-qbittorrent
git clone --depth=1 https://github.com/sbwml/luci-app-qbittorrent

# ram free
git clone --depth=1 https://github.com/sbwml/luci-app-ramfree

# easytier
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git

# Add luci-app-smartdns & smartdns
# rm -rf ../../customfeeds/luci/applications/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/luci-app-smartdns

# Add luci-app-wolplus
rm -rf ../../customfeeds/luci/applications/luci-app-wolplus
github_partial_clone sundaqiang openwrt-packages use_default_branch luci-app-wolplus luci-app-wolplus

# Add luci-app-poweroff
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff

# Add OpenAppFilter
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
    
    echo "处理目录: $po_dir"

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
            echo "成功创建软链接: $po_dir/$zh_Hans_dir -> zh-cn"
        else
            echo "错误: 无法创建软链接: $po_dir/$zh_Hans_dir"
        fi
    else
        echo "已存在: $po_dir/$zh_Hans_dir，不做任何操作。"
    fi

    # 使用 popd 返回原工作目录
    popd > /dev/null
    if [ $? -ne 0 ]; then
        echo "错误: 无法返回到原工作目录。"
        exit 1
    fi

    echo "完成处理目录: $po_dir"
    echo "----------------------------------------"
done

echo "所有目录处理完毕。"

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
