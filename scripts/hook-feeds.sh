#!/bin/bash

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

    # Clone the repository only if it hasn't been cloned yet
    if [ ! -d "${clone_dir}/${repository_name}" ]; then
        git clone --depth=1 ${branch_option} "${url_prefix}${author_name}/${repository_name}.git" "${clone_dir}/${repository_name}"
    fi

    # Move required files and clean up
    mv "${clone_dir}/${repository_name}/${required_dir}/"* "$saved_dir"
    rm -rf "${clone_dir}/${repository_name}"
}

# Svn checkout packages from immortalwrt's repository
pushd customfeeds

# Function to clone and clean up
function clone_and_cleanup() {
    local dir_path="$1"
    local author="$2"
    local repo="$3"
    local branch="$4"
    local required="$5"
    local saved="$6"

    rm -rf "$dir_path"
    github_partial_clone "$author" "$repo" "$branch" "$required" "$saved"
}

# Add luci-app-eqos
clone_and_cleanup "luci/applications/luci-app-eqos" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-eqos" "luci/applications/luci-app-eqos"

# Add luci-app-softethervpn
clone_and_cleanup "luci/applications/luci-app-softethervpn" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-softethervpn" "luci/applications/luci-app-softethervpn"

# Add luci-proto-modemmanager
clone_and_cleanup "luci/protocols/luci-proto-modemmanager" "immortalwrt" "luci" "use_default_branch" "protocols/luci-proto-modemmanager" "luci/protocols/luci-proto-modemmanager"

# Add dufs
clone_and_cleanup "luci/applications/luci-app-dufs" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-dufs" "luci/applications/luci-app-dufs"
clone_and_cleanup "packages/net/dufs" "immortalwrt" "packages" "use_default_branch" "net/dufs" "packages/net/dufs"

# Add tmate
git clone --depth=1 https://github.com/immortalwrt/openwrt-tmate

# Add gotop
clone_and_cleanup "packages/admin/gotop" "immortalwrt" "packages" "use_default_branch" "admin/gotop" "packages/admin/gotop"

# Add minieap
clone_and_cleanup "packages/net/minieap" "immortalwrt" "packages" "use_default_branch" "net/minieap" "packages/net/minieap"
clone_and_cleanup "luci/applications/luci-app-minieap" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-minieap" "luci/applications/luci-app-minieap"

# Replace watchcat with the official version
clone_and_cleanup "packages/utils/watchcat" "openwrt" "packages" "use_default_branch" "utils/watchcat" "packages/utils/watchcat"

# Replace adguardhome
clone_and_cleanup "packages/net/adguardhome" "immortalwrt" "packages" "use_default_branch" "net/adguardhome" "packages/net/adguardhome"

# add missing packages
clone_and_cleanup "luci/applications/luci-app-wireguard" "MilesPoupart" "master" "applications/luci-app-wireguard" "luci/applications/luci-app-wireguard"
clone_and_cleanup "luci/applications/luci-app-adbyby-plus" "MilesPoupart" "master" "applications/luci-app-adbyby-plus" "luci/applications/luci-app-adbyby-plus"

# replace luci-app-smartdns
rm -rf luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/luci-app-smartdns luci/applications/luci-app-smartdns

popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd

pushd customfeeds/luci
export luci_feed="$(pwd)"

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

sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

# echo >> feeds.conf.default
# echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
# ./scripts/feeds update istore
# ./scripts/feeds install -d y -p istore luci-app-store

# Update feeds
./scripts/feeds update -a
