#!/bin/bash

#
#  Build Script for Adin's Kernel for the OnePlus 5!
#  Based off RenderBroken's build script which is...
#  ...based off AK's build script ~~ Thanks!
#

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="oneplus5_defconfig"

# Kernel Details
VER=Adin-Kernel-R4
VARIANT="OP5-OOS-N"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm64
export SUBARCH=arm64

# Paths
KERNEL_DIR="${HOME}/android/kernel/op5"
REPACK_DIR="${HOME}/android/kernel/anykernel2"
ZIP_MOVE="${HOME}/android/kernel/out/op5"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

function clean_all {
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf zImage
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 "$VER"-"$VARIANT".zip *
		mv "$VER"-"$VARIANT".zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo "Adin's Kernel Creation Script:"
export CROSS_COMPILE=${HOME}/android/toolchains/google/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo "-------------------"
echo "Build Completed in:"
echo "-------------------"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
