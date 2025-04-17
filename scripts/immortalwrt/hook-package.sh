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

sed -i 's/1.14.1/1.14.2/g' customfeeds/packages/net/zerotier/Makefile
sed -i 's/4f9f40b27c5a78389ed3f3216c850921f6298749e5819e9f2edabb2672ce9ca0/c2f64339fccf5148a7af089b896678d655fbfccac52ddce7714314a59d7bddbb/g' customfeeds/packages/net/zerotier/Makefile

# Update golang 1.23.x
rm -rf customfeeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang customfeeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 23.x customfeeds/packages/lang/golang

# rm -rf feeds/packages/utils/lrzsz
# git clone https://github.com/sbwml/packages_utils_lrzsz package/new/lrzsz

# samba4 - bump version
rm -rf customfeeds/packages/net/samba4
git clone https://github.com/sbwml/feeds_packages_net_samba4 customfeeds/packages/net/samba4
sed -i 's/ftp.gwdg.de/download.samba.org/g' customfeeds/packages/net/samba4/Makefile

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

# gcc 15
# gcc15 patches
curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/generic-24.10/202-toolchain-gcc-add-support-for-GCC-15.patch | patch -p1
# fix gcc-15
    sed -i '/TARGET_CFLAGS/ s/$/ -Wno-error=unterminated-string-initialization/' package/libs/mbedtls/Makefile
    # elfutils
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/openwrt-6.x/gcc-15/elfutils/901-backends-fix-string-initialization-error-on-gcc15.patch > package/libs/elfutils/patches/901-backends-fix-string-initialization-error-on-gcc15.patch
    # libwebsockets
    mkdir -p customfeeds/packages/libs/libwebsockets/patches
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/openwrt-6.x/gcc-15/libwebsockets/901-fix-string-initialization-error-on-gcc15.patch > customfeeds/packages/libs/libwebsockets/patches/901-fix-string-initialization-error-on-gcc15.patch
    # libxcrypt
    mkdir -p customfeeds/packages/libs/libxcrypt/patches
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/openwrt-6.x/gcc-15/libxcrypt/901-fix-string-initialization-error-on-gcc15.patch > customfeeds/packages/libs/libxcrypt/patches/901-fix-string-initialization-error-on-gcc15.patch

# fix gcc-15.0.1 C23
    # gmp
    mkdir -p package/libs/gmp/patches
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/openwrt-6.x/gcc-15-c23/gmp/001-fix-build-with-gcc-15.patch > package/libs/gmp/patches/001-fix-build-with-gcc-15.patch
    # htop
    mkdir -p customfeeds/packages/admin/htop/patches
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/refs/heads/master/openwrt/patch/openwrt-6.x/gcc-15-c23/htop/001-Avoid-compilation-issues-with-ncurses-on-GCC-15.patch > customfeeds/packages/admin/htop/patches/001-Avoid-compilation-issues-with-ncurses-on-GCC-15.patch
    # libtirpc
    sed -i '/TARGET_CFLAGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/libs/libtirpc/Makefile
    # libsepol
    sed -i '/HOST_MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libsepol/Makefile
    # tree
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/tree/Makefile
    # gdbm
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/libs/gdbm/Makefile
    # libical
    sed -i '/CMAKE_OPTIONS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/libs/libical/Makefile
    # libconfig
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/customfeeds/packages/libconfig/Makefile
    # lsof
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/lsof/Makefile
    # screen
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/screen/Makefile
    # ppp
    sed -i '/CONFIGURE_VARS/i \\nTARGET_CFLAGS += -std=gnu17\n' package/network/services/ppp/Makefile
    # vim
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/vim/Makefile
    # mtd
    sed -i '/target=/i TARGET_CFLAGS += -std=gnu17\n' package/system/mtd/Makefile
    # libselinux
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libselinux/Makefile
    # avahi
    sed -i '/TARGET_CFLAGS +=/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/libs/avahi/Makefile
    # bash
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/bash/Makefile
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/net/xl2tpd/Makefile
    # dnsmasq
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/network/services/dnsmasq/Makefile
    # bluez
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/bluez/Makefile
    # e2fsprogs
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/e2fsprogs/Makefile
    # f2fs-tools
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/f2fs-tools/Makefile
    # krb5
    sed -i '/CONFIGURE_VARS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/net/krb5/Makefile
    # parted
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/parted/Makefile
    # iperf3
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/net/iperf3/Makefile
    # db
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/libs/db/Makefile
    # python3
    sed -i '/TARGET_CONFIGURE_OPTS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/lang/python/python3/Makefile
    # uwsgi
    sed -i '/MAKE_VARS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/net/uwsgi/Makefile
    # perl
    sed -i '/Target perl/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/lang/perl/Makefile
    # rsync
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/net/rsync/Makefile
    # shine
    sed -i '/Build\/InstallDev/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/sound/shine/Makefile
    # jq
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' customfeeds/packages/utils/jq/Makefile
    # coova-chilli
    sed -i '/TARGET_CFLAGS/s/$/ -std=gnu17/' customfeeds/packages/net/coova-chilli/Makefile


