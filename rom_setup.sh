#Created by AISHIK999
#For setting up build environment and syncing repo, cloning trees

#update

sudo apt update && sudo apt upgrade

#install git packages

sudo apt-get install git-core

#declare profile

git config --global user.email "aishikm2002@gmail.com" && git config --global user.name "Aishik Mukherjee"

#setup build environment

git clone https://github.com/akhilnarang/scripts && cd scripts
bash setup/android_build_env.sh
mkdir -p ~/bin
PATH=~/bin:$PATH

#create ROM directory

mkdir -p ~/legion
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
cd ~/legion

#initialize repo

repo init --depth=1 -u https://github.com/Project-LegionOS/manifest.git -b 11

#sync repo

repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)

#clone trees

git clone https://github.com/AISHIK999/android_device_xiaomi_santoni.git -b eleven device/xiaomi/santoni
git clone https://github.com/Jabiyeff-Project/kernel-santoni.git -b 11.0 kernel/xiaomi/msm8937
git clone https://github.com/Jabiyeff-Project/vendor-santoni.git -b 11.0 vendor/xiaomi

#nuke telephony

sed -i '/qti-telephony-common.jar/d' vendor/xiaomi/santoni/santoni-vendor.mk