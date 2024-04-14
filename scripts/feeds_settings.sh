#!/bin/bash

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd
pushd customfeeds/luci
export luci_feed="$(pwd)"
popd
sed -i '/src-git packages/d' feeds.conf.default
sed -i '/src-link packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
sed -i '/src-link luci/d' feeds.conf.default 
echo "src-link luci $luci_feed" >> feeds.conf.default

cat feeds.conf.default

./scripts/feeds update -a && ./scripts/feeds install -a
