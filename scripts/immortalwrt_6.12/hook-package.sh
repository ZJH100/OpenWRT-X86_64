#!/bin/bash
# Set to local prepare

# autocore
rm -rf package/emortal/autocore
git clone https://github.com/xuanranran/autocore-arm -b openwrt-24.10 package/emortal/autocore

# default settings
rm -rf package/emortal/default-settings
git clone https://github.com/xuanranran/default-settings -b openwrt-24.10 package/emortal/default-settings

# custom packages
rm -rf customfeeds/luci/applications/{luci-app-filebrowser,luci-app-argon-config}
rm -rf customfeeds/luci/themes/luci-theme-argon
rm -rf customfeeds/packages/net/shadowsocks-libev

rm -rf customfeeds/packages/net/{*alist,chinadns-ng,dns2socks,dns2tcp,lucky,sing-box}
# chmod 755 customfeeds/lovepackages/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

sed -i 's/video,+libmesa +libwayland +libgudev/video,+libgudev/g' customfeeds/packages/multimedia/gst1-plugins-base/Makefile
sed -i 's/controller,,+libgraphene +libjpeg +libpng/controller,,+libjpeg +libpng/g' customfeeds/packages/multimedia/gst1-plugins-base/Makefile

# zerotier
# rm -rf customfeeds/packages/net/zerotier
# git clone https://github.com/sbwml/feeds_packages_net_zerotier customfeeds/packages/net/zerotier

# mt76
mkdir -p package/kernel/mt76/patches
curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch > package/kernel/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch
curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/mt76/patches/101-fix-build-with-linux-6.12rc2.patch > package/kernel/mt76/patches/101-fix-build-with-linux-6.12rc2.patch

# mac80211 - 6.12
rm -rf package/kernel/mac80211
git clone https://github.com/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b openwrt-24.10

# bpf-headers - 6.12
sed -ri "s/(PKG_PATCHVER:=)[^\"]*/\16.12/" package/kernel/bpf-headers/Makefile

sed -i 's/1.14.1/1.14.2/g' customfeeds/packages/net/zerotier/Makefile
sed -i 's/4f9f40b27c5a78389ed3f3216c850921f6298749e5819e9f2edabb2672ce9ca0/c2f64339fccf5148a7af089b896678d655fbfccac52ddce7714314a59d7bddbb/g' customfeeds/packages/net/zerotier/Makefile

# Update golang 1.23.x
rm -rf customfeeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang customfeeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 23.x customfeeds/packages/lang/golang

# lrzsz - 0.12.20
rm -rf customfeeds/packages/utils/lrzsz
git clone https://github.com/sbwml/packages_utils_lrzsz customfeeds/packages/utils/lrzsz

# samba4 - bump version
rm -rf customfeeds/packages/net/samba4
git clone https://github.com/sbwml/feeds_packages_net_samba4 customfeeds/packages/net/samba4
sed -i 's/ftp.gwdg.de/download.samba.org/g' customfeeds/packages/net/samba4/Makefile

# frpc
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' customfeeds/packages/net/frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' customfeeds/packages/net/frp/files/frpc.init
sed -i 's/stdout stderr //g' customfeeds/packages/net/frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' customfeeds/packages/net/frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' customfeeds/packages/net/frp/files/frpc.config
sed -i 's/env conf_inc/env conf_inc enable/g' customfeeds/packages/net/frp/files/frpc.init
sed -i "s/'conf_inc:list(string)'/& \\\\/" customfeeds/packages/net/frp/files/frpc.init
sed -i "/conf_inc:list/a\\\t\t\'enable:bool:0\'" customfeeds/packages/net/frp/files/frpc.init
sed -i '/procd_open_instance/i\\t\[ "$enable" -ne 1 \] \&\& return 1\n' customfeeds/packages/net/frp/files/frpc.init
curl -s https://raw.githubusercontent.com/xuanranran/r4s_build_script/refs/heads/master/openwrt/patch/luci/applications/luci-app-frpc/001-luci-app-frpc-hide-token.patch | patch -p1
curl -s https://raw.githubusercontent.com/xuanranran/r4s_build_script/refs/heads/master/openwrt/patch/luci/applications/luci-app-frpc/002-luci-app-frpc-add-enable-flag.patch | patch -p1

# liburing - 2.7 (samba-4.21.0)
rm -rf customfeeds/packages/libs/liburing
git clone --depth 1 https://github.com/sbwml/feeds_packages_libs_liburing customfeeds/packages/libs/liburing
# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' customfeeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' customfeeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' customfeeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' customfeeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' customfeeds/packages/net/samba4/files/smb.conf.template

# natmap
pushd customfeeds/luci
curl -s https://raw.githubusercontent.com/xuanranran/r4s_build_script/refs/heads/master/openwrt/patch/luci/applications/luci-app-natmap/0001-luci-app-natmap-add-default-STUN-server-lists.patch | patch -p1
popd

# luci-app-openclash: make version alpine compatible
# curl -s https://raw.githubusercontent.com/xuanranran/OpenWRT-X86_64/refs/heads/master/data/openclash_make_version_alpine_compatible.patch | patch -p1

# mihomo_version_reading
# curl -s https://raw.githubusercontent.com/xuanranran/OpenWRT-X86_64/refs/heads/master/data/mihomo-apk/mihomo-call > customfeeds/lovepackages/luci-app-mihomo/root/usr/libexec/mihomo-call

# Realtek driver - R8168 & R8125 & R8126 & R8152 & R8101
# rm -rf package/kernel/r8168 package/kernel/r8152 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
# git clone https://github.com/sbwml/package_kernel_r8168 package/kernel/r8168
# git clone https://github.com/sbwml/package_kernel_r8152 package/kernel/r8152
# git clone https://github.com/sbwml/package_kernel_r8101 package/kernel/r8101
# git clone https://github.com/sbwml/package_kernel_r8125 package/kernel/r8125
# git clone https://github.com/sbwml/package_kernel_r8126 package/kernel/r8126

# procps-ng - top
sed -i 's/enable-skill/enable-skill --disable-modern-top/g' customfeeds/packages/utils/procps-ng/Makefile

# xdp-tools
rm -rf package/network/utils/xdp-tools
git clone --depth 1 https://github.com/sbwml/package_network_utils_xdp-tools package/network/utils/xdp-tools

# perl
# sed -i "/Target perl/i\TARGET_CFLAGS_PERL += -Wno-implicit-function-declaration -Wno-int-conversion\n" customfeeds/packages/lang/perl/Makefile
# sed -i '/HOST_BUILD_PARALLEL/aPKG_BUILD_FLAGS:=no-mold' customfeeds/packages/lang/perl/Makefile

# 替换杂项
rm -rf customfeeds/luci/applications/luci-app-package-manager
pushd customfeeds/luci/applications/
git clone --depth 1 https://github.com/openwrt/luci openwrt_package-manager && mv -n openwrt_package-manager/applications/luci-app-package-manager ./ ; rm -rf openwrt_package-manager
popd


