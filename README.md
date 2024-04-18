
<div align="center">
<a href="/LICENSE">
    <img src="https://img.shields.io/github/license/MilesPoupart/OpenWrt_RockChip?style=flat&a=1" alt="">
  </a>
  </a><a href="https://github.com/MilesPoupart/OpenWrt_RockChip/releases">
    <img src="https://img.shields.io/github/release/MilesPoupart/OpenWrt_RockChip.svg?style=flat">
  </a><a href="hhttps://github.com/MilesPoupart/OpenWrt_RockChip/releases">
    <img src="https://img.shields.io/github/downloads/MilesPoupart/OpenWrt_RockChip/total?style=flat">
  </a>
</div>
<br>

# OpenWrt — RockChip多设备固件云编译 (基于骷髅头源码)<img src="https://img.shields.io/github/downloads/MilesPoupart/OpenWrt_RockChip/total.svg?style=for-the-badge&color=32C955"/>

### 支持设备
```
friendlyarm_nanopi-r2s
friendlyarm_nanopi-r5c
```

### 固件默认配置
- 用户名：`root` 密码：`password` 管理IP：`192.168.2.1`（R2S） `192.168.3.1`（R5C）
- 下载地址：https://github.com/MilesPoupart/OpenWrt_RockChip/releases 对应 Tag 标签内下载固件
- 刷机方法请参考dn2刷机 https://github.com/DHDAXCW/OpenWrt_RockChip/blob/master/data/emmc.md
- 电报交流群：https://t.me/DHDAXCW

### 固件特色
1. 集成 iStore 应用商店，可根据自己需求自由安装所需插件
2. 集成应用过滤插件，支持游戏、视频、聊天、下载等 APP 过滤
3. 集成在线用户插件，可查看所有在线用户 IP 地址与实时速率等
4. 集成部分常用有线、无线、3G / 4G /5G 网卡驱动 可在issues提支持网卡，看本人能力了。。。
5. 支持在线更新，从2024.03.27之后就能通过后台升级
6. 特调优化irq中断分配网卡绑定cpu

### 固件展示
<img width="1304" alt="image" src="https://github.com/DHDAXCW/OpenWrt_RockChip/assets/74764072/acc32c0b-a8aa-4250-88c1-a1d4d3f24ec2">

### 特别提示 [![](https://img.shields.io/badge/-个人免责声明-FFFFFF.svg)](#特别提示-)

- **因精力有限不提供任何技术支持和教程等相关问题解答，不保证完全无 BUG！**

- **本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！**

- **本固件禁止用于任何商业用途，请务必严格遵守国家互联网使用相关法律规定！**

### 有bug请在 https://github.com/DHDAXCW/OpenWrt_RockChip/issues 提问题

### 鸣谢

特别感谢以下项目：

Openwrt 官方项目：

<https://github.com/openwrt/openwrt>

Lean 大的 Openwrt 项目：

<https://github.com/coolsnowwolf/lede>

immortalwrt 的 OpenWrt 项目：

<https://github.com/immortalwrt/immortalwrt>

P3TERX 大佬的 Actions-OpenWrt 项目：

<https://github.com/P3TERX/Actions-OpenWrt>

SuLingGG 大佬的 Actions 编译框架 项目：

https://github.com/SuLingGG/OpenWrt-Rpi
