#update

sudo apt update && sudo apt upgrade
sudo apt-get install git-core

#declare profile

git config --global user.email "aishikm2002@gmail.com" && git config --global user.name "Aishik Mukherjee"

#setup build environment

git clone https://github.com/akhilnarang/scripts && cd scripts
bash setup/android_build_env.sh
mkdir -p ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

