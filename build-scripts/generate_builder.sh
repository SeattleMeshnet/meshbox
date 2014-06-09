#!/usr/bin/env bash
# set -x
#
declare -a builderArray

# Purpose: make buildbot.master config based on hardware
#          and multiple choices of firmware/packages
#
#      8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8<-
#       cut cut cut cut cut cut cut cut cut cut cut cut
#      8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8<-
#      # -----------------------------------------------
#      # Building #1 for x86factory
#      # -----------------------------------------------
#      86factory= BuildFactory()
#      86factory.addStep(Git(repourl="git://git.openwrt.org/openwrt.git"))
#       x86factory.addStep(ShellCommand(command=["rm", "-fr", "staging_dir", "build_dir", "bin"]))
#       x86factory.addStep(Configure(command=["make", "distclean"])) # use when modifying staging/building (toolchain)
#      86factory.addStep(ShellCommand(
#       command=["rm", "-rf", "bin"]))
#      86factory.addStep(FileDownload(
#       mastersrc="~/openwrtbuildbot/target-package.sh",
#       slavedest="target-package.sh"))
#      86factory.addStep(ShellCommand(
#       command=["bash","./target-package.sh", "x86", "alix2", "meshbox"]))
#      x86factory.addStep(ShellCommand(command=["rsync","-rv", "bin/x86","sonic@igel.meshwith.me:/etc../"], warnOnFailure=True))
#
# STOP: Script development comes at a stop:
# 	[INCOMPLETE #1] - bash script needs function return_target_builder_package_feeds
# 	[INCOMPLETE #2] - use python or C to get json
# 	[BUG/TYPO] - Naming convention bcm and brcm


# INCOMPLETE #1
ar7xxx[1]="ar71xx"
ar7xxx[2]="whr_hp_gn"
ar7xxx[3]="meshbox"

ar7xxxfresh[1]="ar71xx"
ar7xxxfresh[2]="whr_hp_gn"
ar7xxxfresh[3]="cjdns_libssp"

bcm47xx[1]="brcm47xx"
bcm47xx[2]="b47cutter43"
bcm47xx[3]="meshbox"

bcm47xxfresh[1]="brcm47xx"
bcm47xxfresh[2]="b47cutter43"
bcm47xxfresh[3]="cjdns_libssp"

bcm63xx[1]="brcm"
bcm63xx[2]="b63generic"
bcm63xx[3]="meshbox"

bcm63xxfresh[1]="brcm63xx"
bcm63xxfresh[2]="b63generic"
bcm63xxfresh[3]="cjdns_libssp"

bcm953xx[1]="CONFIG_TARGET_brcm47xx=y"
bcm953xx[2]="CONFIG_TARGET_brcm47xx_Broadcom-b43=y"
bcm953xx[3]="meshbox"

bcm953xxfresh[1]="CONFIG_TARGET_brcm47xx=y"
bcm953xxfresh[2]="CONFIG_TARGET_brcm47xx_Broadcom-b43=y"
bcm953xxfresh[3]="meshbox"

x86[1]="x86"
x86[2]="alix2"
x86[3]="meshbox"

x86fresh[1]="x86"
x86fresh[2]="alix2"
x86fresh[3]="cjdns_libssp"

x86enigmabox[1]="CONFIG_TARGET_x86_64=y"
x86enigmabox[2]="CONFIG_TARGET_x86_64_Default=y"
x86enigmabox[3]="enigmabox"

meshbox_alix2[1]="x86"
meshbox_alix2[2]="alix2"
meshbox_alix2[3]="meshbox"

meshbox_whr_hp_gn[1]="ar71xx"
meshbox_whr_hp_gn[2]="whr_hp_gn"
meshbox_whr_hp_gn[3]="meshbox"

meshbox_whr_hp_gn_s4[1]="ar71xx"
meshbox_whr_hp_gn_s4[2]="whr_hp_gn"
meshbox_whr_hp_gn_s4[3]="meshbox"

meshbox_wnr2000v3_s4[1]="ar71xx"
meshbox_wnr2000v3_s4[2]="wnr2000v3"
meshbox_wnr2000v3_s4[3]="meshbox"

# INCOMPLETE #2

x86factory="x86"
x86factoryfresh="x86fresh"
x86factory="meshbox_alix2"
x86factoryEnigmabox="x86enigmabox"
ar7xxxfactory="ar7xxx"
ar7xxxfactoryfresh="ar7xxxfresh"
ar7xxx_meshbox_whr_hp_gn="meshbox_whr_hp_gn"
ar7xxx_meshbox_whr_hp_gn="meshbox_whr_hp_gn_s4"
ar7xxx_meshbox_wnr2000v3="meshbox_wnr2000v3_s4"
bcm47xxfactory="bcm47xx"
bcm47xxfactoryfresh="bcm47xxfresh"
bcm47xxfactory="bcm63xx"
bcm63xxfactoryfresh="bcm63xxfresh"
bcm47xxfactory="bcm953xx"
bcm63xxfactoryfresh="bcm953xxfresh"


builders="\
x86factory \
x86factoryfresh \
x86factory \
x86factoryEnigmabox \
ar7xxxfactory \
ar7xxxfactoryfresh \
ar7xxx_meshbox_whr_hp_gn \
ar7xxx_meshbox_whr_hp_gn \
ar7xxx_meshbox_wnr2000v3 \
ar7xxx_meshbox_wnr2000v3 \
ar7xxx_meshbox_wnr2000v3 \
bcm47xxfactory \
bcm47xxfactoryfresh \
bcm47xxfactory \
bcm63xxfactoryfresh \
bcm47xxfactory \
bcm63xxfactoryfresh"
# same above example --^
builders=$( grep factory= master.cfg | grep "\#" -v | cut -d\) -f1 | cut -d\= -f2 | grep \( -v)

say(){ echo "# [$(basename $0 | sed s/\.sh//1 )] - $@" ; }


nbuilders=$( echo $builders | wc -w )
cuthere(){
	echo "# 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< "
	echo "#  cut cut cut cut cut cut cut cut cut cut cut cut"
	echo "# 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< 8< "
}

cuthere
for (( key = 1; key < $nbuilders; key++ )); do

	value=$( for bldr in $(echo $builders); do echo $bldr; done | sed s/\ /\n/g | sed -n ${key}p )
	builderArray[${key}]=${value}
	# functions in forloops :D
	function bldrPrefix() { echo "${builderArray[$key]}$@"; }
	function bldrNoGo() { echo "# ${builderArray[$key]}$@"; }
	function bldrPrint() { echo "$@"; }

	say "-----------------------------------------------"
	say "# Building #${key} for ${builderArray[$key]}"
	say "-----------------------------------------------"

	bldrPrefix 	'=BuildFactory()'
	bldrPrefix 	'.addStep(Git(repourl="git://git.openwrt.org/openwrt.git"))'
	# /Rebuilds/
	bldrPrefix 	'.addStep(ShellCommand(command=["rm", "-fr", "staging_dir", "build_dir", "bin"]))'
	bldrPrefix 	'.addStep(Configure(command=["make", "distclean"])) # use when modifying staging/building (toolchain)'
	# /Rebuilds/

	# /Nuke old build images/
	bldrPrefix 	'.addStep(ShellCommand('
	bldrPrint 	'	command=["rm", "-rf", "bin"]))'
	# /Nuke old build images/


	# /cjdns-openwrt scripts/
	bldrPrefix 	'.addStep(FileDownload('
	bldrPrint 	'	mastersrc="~/openwrtbuildbot/target-package.sh",'
	bldrPrint 	'	slavedest="target-package.sh"))'

	bldrPrefix 	'.addStep(ShellCommand('
	# bldrPrint 	'	command=["bash","./target-package.sh", "ar71xx", "whr_hp_gn", "meshbox"]))'

	# bldrPrint "--=-=-=--"
	# echo TARGET ===== ${builderArray[$key]}
	TARGET="$( eval echo \${${builderArray[$key]}[0]} )"
	# echo "TARGET=$TARGET"
	eval PROFILE="\${$TARGET[2]}"
	eval FEED="\${$TARGET[3]}"
	eval TARGET="\${$TARGET[1]}"
	# echo "TARGET=$TARGET"
	# echo "PROFILE=$PROFILE"
	# echo "FEED=$FEED"

	# INCOMPLETE #3
	# optWarez[${key}]="$( ./rTargetPackage ${builderArray[$key]} )"
	# echo "* " ${optWarez[$key]} # command=["bash","./target-package.sh",
	bldrPrint 	'	command=["bash","./target-package.sh", "'${TARGET}'", "'${PROFILE}'", "'${FEED}'"]))'
	# echo "-> ${builderArray[$key]} "
	# bldrPrint "--=-=-=--"
	# /cjdns-openwrt scripts/
	bldrPrint 	''
	bldrPrefix 	'.addStep(Configure(command=["make", "defconfig"]))'
	bldrPrefix 	'.addStep(Compile(command=["make", "IGNORE_ERRORS=m", "V=s"]))'
	bldrNoGo 	'.addStep(ShellCommand(command=["rsync","-rv", "bin/x86","buildbot@igel.meshwith.me:/snapshots/"], warnOnFailure=True))'
	:	#more statements
	echo ""
	echo ""
done
cuthere
