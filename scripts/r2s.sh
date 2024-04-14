# remove 1608Mhz for kernel 6.1
rm -rf target/linux/rockchip/patches-6.1/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch
cp -f $GITHUB_WORKSPACE/patches/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch target/linux/rockchip/patches-6.1/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='HarmonyWrt'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/OpenWrt /MilesPoupart @ HarmonyWrt /g" package/lean/default-settings/files/zzz-default-settings

rm package/base-files/files/etc/banner
touch package/base-files/files/etc/banner
echo -e "____________________________________________________________________" >> package/base-files/files/etc/banner
echo -e "    _     _                                      _      _           " >> package/base-files/files/etc/banner
echo -e "    /    /                                       |  |  /            " >> package/base-files/files/etc/banner
echo -e "---/___ /-----__---)__---_--_----__----__--------|-/|-/----)__--_/_-" >> package/base-files/files/etc/banner
echo -e "  /    /    /   ) /   ) / /  ) /   ) /   ) /   / |/ |/    /   ) /   " >> package/base-files/files/etc/banner
echo -e "_/____/____(___(_/_____/_/__/_(___/_/___/_(___/__/__|____/_____(_ __" >> package/base-files/files/etc/banner
echo -e "                                             /                      " >> package/base-files/files/etc/banner
echo -e "                                         (_ /                       " >> package/base-files/files/etc/banner
echo -e "--------------------------------------------------------------------" >> package/base-files/files/etc/banner
echo -e "           MilesPoupart's HarmonyWrt built on "$(date +%Y.%m.%d)"\n____________________________________________________________________" >> package/base-files/files/etc/banner

# 风扇脚本
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
wget -P target/linux/rockchip/armv8/base-files/etc/init.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/init.d/fa-rk3328-pwmfan
wget -P target/linux/rockchip/armv8/base-files/usr/bin/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/usr/bin/start-rk3328-pwm-fan.sh
wget -P target/linux/rockchip/armv8/base-files/etc/rc.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/rc.d/S96fa-rk3328-pwmfan
chmod +x target/linux/rockchip/armv8/base-files/etc/init.d/fa-rk3328-pwmfan
chmod +x target/linux/rockchip/armv8/base-files/usr/bin/start-rk3328-pwm-fan.sh
