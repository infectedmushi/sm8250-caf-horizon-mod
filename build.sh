#!/bin/bash
KERNEL_DIR="/mnt/Building/caf_sm8250_horizon"
KBUILD_OUTPUT="/mnt/Building/caf_sm8250_horizon/out"
ZIP_DIR="/mnt/Building/AnyKernel3-omega"
export USE_CCACHE=1
export ARCH=arm64
make clean && make mrproper
rm -rf out
time make O=$KBUILD_OUTPUT CC=clang instantnoodle_defconfig
export VARIANT="OP8-OOS-R"
export HASH=`git rev-parse --short=8 HEAD`
export KERNEL_ZIP="$VARIANT-$(date +%y%m%d)-$HASH"
export LOCALVERSION=~`echo $KERNEL_ZIP`
export KBUILD_BUILD_USER=infected_
export KBUILD_BUILD_HOST=infected-labs
export KBUILD_COMPILER_STRING=$($CLANG_PATH --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export PATH="/mnt/Building/proton-clang/bin:${PATH}"
export LD_LIBRARY_PATH="/mnt/Building/proton-clang/lib:/mnt/Building/proton-clang/lib64:$LD_LIBRARY_PATH"
time make -j$(nproc --all) O=$KBUILD_OUTPUT CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=/mnt/Building/gcc-10.x-aarch64-linux-gnu-master/bin/aarch64-linux-gnu-
find $KBUILD_OUTPUT/arch/arm64/boot/dts/vendor/qcom -name '*.dtb' -exec cat {} + > $ZIP_DIR/dtb
cp -v $KBUILD_OUTPUT/arch/arm64/boot/Image.gz $ZIP_DIR/Image.gz
cd $ZIP_DIR
zip -r9 $VARIANT-$(date +%y%m%d)-$HASH.zip *
mv -v $VARIANT-$(date +%y%m%d)-$HASH.zip /mnt/Building/Out_Zips
echo -e "${green}"
echo "-------------------"
echo "Build Completed"
echo "-------------------"
echo -e "${restore}"
