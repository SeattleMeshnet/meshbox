#!/usr/bin/env bash
set -x

# Purpose: Deployed by buildbot 
#  		and executed in in ./openwrt/ by buildbots
# Notes: key & legend to builder master.cfg is server side.
# 		see: generate_builder.sh 
# 		(returns values for this script (see below))
# 	
# Syntax below:
# 	------------------- 	------ 	--------- 	---------
# 	$(basename $0) 		target 	profile 	feed
# 	------------------- 	------ 	--------- 	---------
# 	./target-package.sh 	ar71xx 	whr_hp_gn 	cjdns
# 	./target-package.sh 	x86 	alix2 		enigmabox
# 	./target-package.sh 	ar71xx 	whr_hp_gn 	meshbox
# 	------------------- 	------ 	--------- 	---------
function exit_noBuild ()
{
	rm -rf Makefile
	touch .nobuild_TargetPackages
	echo "exit_noBuild(! \$$1)" \
		| tee .nobuild_TargetPackages
	exit 1
}

################################################################## 
# Sanity Sanity Sanity Sanity Sanity Sanity Sanity Sanity Sanity #
##################################################################
[ $1 ] &&  TARGET=$1 || exit_noBuild "TARGET"
[ $2 ] && PROFILE=$2 || exit_noBuild "PROFILE"
[ $3 ] &&    FEED=$3 || exit_noBuild "FEED"
##################################################################


[ $TARGET == "ar71xx" ] 	&& T="CONFIG_TARGET_ar71xx=y"
[ $TARGET == "x86" ] 		&& T="CONFIG_TARGET_x86=y"
[ $TARGET == "brcm47xx" ] 	&& T="CONFIG_TARGET_brcm47xx=y"
[ $TARGET == "brcm63xx" ] 	&& T="CONFIG_TARGET_brcm63xx=y"
#
[ $PROFILE == "b63generic" ] 	&& P="CONFIG_TARGET_brcm63xx_generic_Broadcom=y"
[ $PROFILE == "b63atheros" ] 	&& P="CONFIG_TARGET_brcm63xx_generic_Atheros=y"
[ $PROFILE == "b47cutter43" ]  	&& P="CONFIG_TARGET_brcm47xx_Broadcom-b43=y"
[ $PROFILE == "b47wl" ]  	&& P="CONFIG_TARGET_brcm47xx_Broadcom-wl=y"
[ $PROFILE == "b47ath5k" ]  	&& P="CONFIG_TARGET_brcm47xx_Broadcom-ath5k=y"
[ $PROFILE == "whr_hp_gn" ] 	&& P="CONFIG_TARGET_ar71xx_generic_WHRHPGN=y"
[ $PROFILE == "wnr2000v3" ] 	&& P="CONFIG_TARGET_ar71xx_generic_WNR2000V3=y"
[ $PROFILE == "alix2" ] 	&& P="CONFIG_TARGET_x86_alix2=y"

[ $FEED == "meshbox" ] 		&& F="luci_cjdns"
[ $FEED == "enigmabox" ] 	&& F="enigmabox"
[ $FEED == "cjdns" ] 		&& F="cjdns_nossp"
[ $FEED == "cjdns_libssp" ] 	&& F="cjdns_libssp"

if [[ -z $T && -n $TARGET ]] 	\
&& [[ -z $P && -n $PROFILE ]] 	\
&& [[ -n $F && -n $FEED ]] 	  # feed required
then
	T=$TARGET
	P=$PROFILE
	F=$FEED
	# echo "**********"
	# echo "* \$TARGET = $TARGET"
	# echo "* \$PROFILE = $PROFILE"
	# echo "* \$FEED = $FEED"
	# echo "**********"

fi
################################################################## 
# Sanity Sanity Sanity Sanity Sanity Sanity Sanity Sanity Sanity #
##################################################################
[ $T ] || exit_noBuild "T"
[ $P ] || exit_noBuild "P"
[ $F ] || exit_noBuild "F"
##################################################################
# Functions Functions Functions Functions Functions Function Fun #
##################################################################

##################################################################
# Profile/Board Dotconfig Profile/Board Dotconfig Profile/Board  #
##################################################################
function ssp_support ()
{
	echo "CONFIG_DEVEL=y" 			>> .config
	echo "CONFIG_TOOLCHAINOPTS=y" 		>> .config
	echo "CONFIG_SSP_SUPPORT=y" 		>> .config
	echo "CONFIG_PACKAGE_libssp=y" 		>> .config
}

function config_all_yes ()
{
	echo "CONFIG_ALL=y" 			>> .config
}

function luci_cjdns ()
{
	ssp_support
	echo "CONFIG_DEFAULT_ppp-mod-pppoe=n" 	>> .config
	echo "CONFIG_DEFAULT_ppp=n" 		>> .config
	echo "CONFIG_PACKAGE_kmod-ppp=n" 	>> .config
	echo "CONFIG_PACKAGE_kmod-pppoe=n" 	>> .config
	echo "CONFIG_PACKAGE_kmod-pppox=n" 	>> .config
	echo "CONFIG_PACKAGE_luci-cjdns=y" 	>> .config
	echo "CONFIG_PACKAGE_luci-proto-ppp=n" 	>> .config
	echo "CONFIG_PACKAGE_ppp-mod-pppoe=n" 	>> .config
	echo "CONFIG_PACKAGE_ppp=n" 		>> .config

}

function enigmabox ()
{
	ssp_support
	echo "CONFIG_GRUB_BAUDRATE=115200" 		>> .config
	echo "CONFIG_PACKAGE_enigmasuite=y" 		>> .config
	echo "CONFIG_PACKAGE_beanstalkd=y" 		>> .config
	echo "CONFIG_PACKAGE_cfengine=y" 		>> .config
	echo "CONFIG_PACKAGE_cfengine-policies=y" 	>> .config
	echo "CONFIG_PACKAGE_cjdns-dumbclient=y" 	>> .config
	echo "CONFIG_PACKAGE_cjdns-master=y" 		>> .config
	echo "CONFIG_PACKAGE_django-south=y" 		>> .config
	echo "CONFIG_PACKAGE_exim4=y" 			>> .config
	echo "CONFIG_PACKAGE_python-beanstalkc=y" 	>> .config
	echo "CONFIG_PACKAGE_python-cython=y" 		>> .config
	echo "CONFIG_PACKAGE_python-django-1.4=y" 	>> .config
	echo "CONFIG_PACKAGE_python-gevent=y" 		>> .config
	echo "CONFIG_PACKAGE_python-greenlet=y" 	>> .config
	echo "CONFIG_PACKAGE_python-gunicorn=y" 	>> .config
	echo "CONFIG_PACKAGE_python-requests=y" 	>> .config
	echo "CONFIG_PACKAGE_python-setuptools=y" 	>> .config
	echo "CONFIG_PACKAGE_python-six=y" 		>> .config
	echo "CONFIG_PACKAGE_python-unidecode=y" 	>> .config
	echo "CONFIG_PACKAGE_roundcube=y" 		>> .config
	echo "CONFIG_PACKAGE_teletext=y" 		>> .config
	echo "CONFIG_PACKAGE_webinterface=y" 		>> .config
}

function cjdns ()
{
	echo "CONFIG_PACKAGE_cjdns=y" 			>> .config
}
#/dotconfig
##################################################################

##################################################################
# Feeds Feeds Feeds Feeds Feeds Feeds Feeds Feeds Feeds Feeeeds  #
##################################################################
function update_feeds ()
{
	./scripts/feeds update -a
}

function feeds ()
{

    # OpenWrt feeds
    local luci="git://nbd.name/luci.git"
    local packages="git://git.openwrt.org/packages.git"
    local routing="git://github.com/openwrt-routing/packages.git"
    local telephony="http://feeds.openwrt.nanl.de/openwrt/telephony.git"
    local xwrt="http://x-wrt.googlecode.com/svn/trunk/package"

    # Meshbox feeds

    local meshbox="git://github.com/seattlemeshnet/meshbox.git"
    local enigmabox="https://github.com/enigmagroup/enigmabox-openwrt.git"
    local cjdns="git://github.com/wfleurant/cjdns-openwrt.git"

    # Default Feeds
    echo "src-git luci          $luci"      >   feeds.conf
    echo "src-git packages      $packages"  >>  feeds.conf
    echo "src-git routing       $routing"   >>  feeds.conf
    echo "src-git telephony     $telephony" >>  feeds.conf
    echo "src-svn xwrt          $xwrt"      >>  feeds.conf

    # Custom Feeds
    case $1 in
        luci_cjdns | meshbox )
		echo "src-git meshbox $meshbox" >> feeds.conf
    		local i="\
    			cjdns \
    			dkjson \
    			lua-bencode \
    			lua-sha2 \
    			luci-cjdns"

    		update_feeds
    		for opkg in $i
    		do
    			./scripts/feeds install $opkg
    		done
    		;;	
    	enigmabox )
		echo "src-git enigmabox $enigmabox" >> feeds.conf
		local i="\
			beanstalkd \
			cfengine \
			cfengine-policies \
			cjdns-dumbclient \
			cjdns-master \
			django-south \
			exim4 \
			python-beanstalkc \
			python-cython \
			python-django-1.4 \
			python-gevent \
			python-greenlet \
			python-gunicorn \
			python-requests \
			python-setuptools \
			python-six \
			python-unidecode \
			roundcube \
			teletext \
			webinterface"

    		update_feeds
		for opkg in $i
    		do
    			./scripts/feeds install $opkg
    		done
    		;;	
    	cjdns )
		echo "src-git cjdns $cjdns" >> feeds.conf
    		local i="cjdns"

    		update_feeds
		for opkg in $i
    		do
    			./scripts/feeds install $opkg
    		done
    		;;	# above is aligned correctly in feeds.conf
    	* )
    		;;
    esac
	
}
#/feeds
##################################################################



##################################################################
# Main Main Main Main Main Main Main Main Maine Main Gucci Mane! #
##################################################################
# T == Target, P == Profile, F == Feeds

rm -rf .config feeds.conf

# Set Target to Dot-Config
echo $T > .config

# Set Profile to Dot-Config
echo $P >> .config

# Select Packages in .config
# Add upstream to feeds.conf
case $F in
	luci_cjdns | meshbox )
		luci_cjdns
		feeds meshbox

		;;
	enigmabox )
		enigmabox
		feeds enigmabox
		;;
	cjdns_nossp )
		cjdns
		feeds cjdns
		;;
	cjdns_libssp )
		ssp_support
		cjdns
		feeds cjdns
		;;
	* )
		exit 1
esac
