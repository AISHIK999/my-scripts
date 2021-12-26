#!/usr/bin/env bash

# Script to compile kernel

export KERNELDIR="$PWD" #Set kernel directory
export USE_CCACHE=1 # CCACHE for faster compilation
export CCACHE_DIR="$HOME/.ccache"   # Set CCACHE directory
# Set user configurations
git config --global user.email "aishikm2002@gmail.com"
git config --global user.name "AISHIK999"
 
export TZ="Asia/Kolkata";   #Set timezone
 
# Clone dependencies
git clone https://github.com/AISHIK999/AnyKernel3.git   #AnyKernel3 makes zip from kernel image
git clone https://github.com/kdrag0n/proton-clang.git prebuilts/proton-clang --depth=1  #Proton clang for compiler
 
# Function to transfer builds to transfer.sh and post on telegram
# Un-comment the lines after <--, to before -->
# Input the necessary details such as the bot API key in the function, and call the function at the end of this script if needed

# <-- 
# function transfer() {
#     zipname="$(echo $1 | awk -F '/' '{print $NF}')";
#     url="$(curl -# -T $1 https://transfer.sh)";
#     printf '\n';
#     echo -e "Download ${zipname} at ${url}";
#     curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="$url" -d chat_id=$CHAT_ID
#     curl -F chat_id="$CHAT_ID" -F document=@"${ZIP_DIR}/$ZIPNAME" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
# }
# -->


if [[ -z ${KERNELDIR} ]]; then
    echo -e "Please set KERNELDIR";
    exit 1;
fi
 
 
mkdir -p ${KERNELDIR}/aroma
mkdir -p ${KERNELDIR}/files

# Export configurations
export KERNELNAME="Rockstar-UNOFFICIAL" # Kernel name to be picked up by ANyKernel3 to name the zip
export SRCDIR="${KERNELDIR}";   # Export source directory
export OUTDIR="${KERNELDIR}/out";   # Export out directory
export ANYKERNEL="${KERNELDIR}/AnyKernel3"; # Export AnyKernel3 directory
export AROMA="${KERNELDIR}/aroma/";
export ARCH="arm64";
export SUBARCH="arm64";
export KBUILD_COMPILER_STRING="$($KERNELDIR/prebuilts/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
export KBUILD_BUILD_USER="AISHIK999"
export KBUILD_BUILD_HOST="AISHIK999"
export PATH="$KERNELDIR/prebuilts/proton-clang/bin:${PATH}" # Export clang compiler path
export DEFCONFIG="mi8937_defconfig";    # Set the required defconfig
export ZIP_DIR="${KERNELDIR}/files";    # Export the directory where the kernel ZIPs are stored
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";    #Export the kernel image directory
export COMMITMSG=$(git log --oneline -1)
export MAKE_TYPE="Treble"   #Export kernel make type
 
if [[ -z "${JOBS}" ]]; then
    export JOBS="$(nproc --all)";
fi
 
export MAKE="make O=${OUTDIR}";
export ZIPNAME="${KERNELNAME}-santoni-${MAKE_TYPE}$(date +%m%d-%H).zip" #Set the kernel ZIP name
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"
 
[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}
 
cd "${SRCDIR}";
rm -fv ${IMAGE};
 
MAKE_STATEMENT=make
 
# Menuconfig configuration
# If -no-menuconfig flag is present we will skip the kernel configuration step.

if [[ "$*" == *"-no-menuconfig"* ]]
then
  NO_MENUCONFIG=1
  MAKE_STATEMENT="$MAKE_STATEMENT KCONFIG_CONFIG=./arch/arm64/configs/beryllium_defconfig"
fi
 
if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi
 
if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi
 
cd $KERNELDIR
${MAKE} $DEFCONFIG;
START=$(date +"%s");
echo -e "Using ${JOBS} threads to compile"
 
# Start the compilation >///<

${MAKE} -j${JOBS} \ ARCH=arm64 \ CC=clang \ LINKER="lld" \ CROSS_COMPILE=aarch64-linux-gnu- \ CROSS_COMPILE_ARM32=arm-linux-gnueabi- \ NM=llvm-nm \ OBJCOPY=llvm-objcopy \ OBJDUMP=llvm-objdump \ STRIP=llvm-strip  | tee build-log.txt ;
 
exitCode="$?";
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";
 
# Send log and trimmed log if build failed
if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed!";
    echo -e "Resolve errors and try again ≧◠‿◠≦"
    trimlog build-log.txt
    success=false;
    exit 1;
else
    echo -e "Build Succesful! >///<";
    success=true;
fi
 
# Make ZIP using AnyKernel
echo -e "Creating kernel ZIP using AnyKernel3";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;
echo -e "Congratulations! Your kernel is ready to flash! <(^,^)>";
echo -e "Kernel zip is stored in /files directory";
 