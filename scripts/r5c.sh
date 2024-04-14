# Modify default IP
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='MagicWrt'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/OpenWrt /MilesPoupart @ MagicWrt /g" package/lean/default-settings/files/zzz-default-settings

rm package/base-files/files/etc/banner
touch package/base-files/files/etc/banner
echo -e "------------------------------------------------------------" >> package/base-files/files/etc/banner
echo -e "______  ___              _____      ___       __      _____ " >> package/base-files/files/etc/banner
echo -e "___   |/  /_____ _______ ___(_)_______ |     / /________  /_" >> package/base-files/files/etc/banner
echo -e "__  /|_/ /_  __ \`/_  __ \`/_  /_  ___/_ | /| / /__  ___/  __/" >> package/base-files/files/etc/banner
echo -e "_  /  / / / /_/ /_  /_/ /_  / / /__ __ |/ |/ / _  /   / /_  " >> package/base-files/files/etc/banner
echo -e "/_/  /_/  \__,_/ _\__, / /_/  \___/ ____/|__/  /_/    \__/  " >> package/base-files/files/etc/banner
echo -e "                 /____/                                     " >> package/base-files/files/etc/banner
echo -e "------------------------------------------------------------" >> package/base-files/files/etc/banner
echo -e "        MilesPoupart's MagicWrt built on "$(date +%Y.%m.%d)"\n------------------------------------------------------------" >> package/base-files/files/etc/banner

cp -f $GITHUB_WORKSPACE/999-fuck-rockchip-pcie.patch target/linux/rockchip/patches-6.1/999-fuck-rockchip-pcie.patch
