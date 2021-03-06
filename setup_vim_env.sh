dir=$(dirname `realpath $0`)

# backup vimrc
if [ -e ~/.vimrc ]; then
  echo backup the original .vimrc to .vimrc.bk
  cp ~/.vimrc ~/.vimrc.bk
fi

# awesome vimrc
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# vimplug and youcompleteme
echo cp $dir/vimrc.template ~/.vimrc
cp $dir/vimrc.template ~/.vimrc

echo please open vim and wait for plug to install
