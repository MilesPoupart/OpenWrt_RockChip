#!/bin/bash
now_dir=$(pwd)
clone_dir=${now_dir}"/../git_clone_temporary_space"
if [ ! -d "$clone_dir" ]; then
  mkdir "$clone_dir"
fi
function github_partial_clone(){
    url_prefix="https://github.com/" author_name="$1" repository_name="$2" branch_name="$3" required_dir="$4" saved_dir="$5"
    if [ "$branch_name" == "use_default_branch" ]; then
        branch_option=""
    else        
        branch_option="-b "${branch_name}
    fi
    if [ ! -d ${saved_dir} ]; then
        mkdir -vp ${saved_dir}
    fi
    if [ ! -d ${clone_dir}"/"${repository_name} ]; then
        git clone --depth=1 ${branch_option} ${url_prefix}${author_name}"/"${repository_name}".git" ${clone_dir}"/"${repository_name}
    fi
    mv ${clone_dir}"/"${repository_name}"/"${required_dir}/* ${saved_dir}
    rm -rf ${clone_dir}"/"${repository_name}
}

# Svn checkout packages from immortalwrt's repository
pushd customfeeds

# Add luci-app-eqos
rm -rf luci/applications/luci-app-eqos
github_partial_clone immortalwrt luci use_default_branch applications/luci-app-eqos luci/applications/luci-app-eqos

# Add luci-proto-modemmanager
rm -rf luci/protocols/luci-proto-modemmanager
github_partial_clone immortalwrt luci use_default_branch protocols/luci-proto-modemmanager luci/protocols/luci-proto-modemmanager

# Add luci-app-gowebdav
# github_partial_clone immortalwrt luci use_default_branch applications/luci-app-gowebdav luci/applications/luci-app-gowebdav
# rm -rf packages/net/gowebdav
# github_partial_clone immortalwrt packages use_default_branch net/gowebdav packages/net/gowebdav

# Add dufs
github_partial_clone immortalwrt luci use_default_branch applications/luci-app-dufs luci/applications/luci-app-dufs
github_partial_clone immortalwrt packages use_default_branch net/dufs packages/net/dufs

# Add tmate
git clone --depth=1 https://github.com/immortalwrt/openwrt-tmate

# Add gotop
rm -rf packages/admin/gotop
github_partial_clone immortalwrt packages openwrt-18.06 admin/gotop packages/admin/gotop

# Add minieap
rm -rf packages/net/minieap
github_partial_clone immortalwrt packages use_default_branch net/minieap packages/net/minieap

# Replace smartdns
# rm -rf packages/net/smartdns
# github_partial_clone immortalwrt packages use_default_branch net/smartdns packages/net/smartdns

# Replace watchcat with the official version
rm -rf packages/utils/watchcat
github_partial_clone openwrt packages use_default_branch utils/watchcat packages/utils/watchcat

# Replace adguardhome
rm -rf packages/net/adguardhome
github_partial_clone immortalwrt packages use_default_branch net/adguardhome packages/net/adguardhome

popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd
pushd customfeeds/luci
export luci_feed="$(pwd)"
popd
sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

echo >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
./scripts/feeds update istore
./scripts/feeds install -d y -p istore luci-app-store

# Update feeds
./scripts/feeds update -a
