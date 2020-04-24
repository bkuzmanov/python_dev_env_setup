#!/bin/bash

# Clone and Install vim
function build_vim {
	echo "[+] Cloning vim repository"
	git clone "https://github.com/vim/vim.git" /tmp/vim
	if [ ! $? -eq 0 ]; then
		echo "[-] GIT clone failed" >2&
		exit 1
	fi

	cd /tmp/vim
	echo "[+] Configuring vim setup"
	if [ -f /tmp/vim/configure ]; then
		./configure --enable-python3interp
	else
		echo "[-] Vim changed location or removed 'configure' file" >&2
		exit 1
	fi
	
	if [ ! $? -eq 0 ]; then
		echo "[-] Vim setup configuration failed" >&2
		exit 1
	fi

	echo "[+] Installing vim to /usr/local"
	make install
	if [ ! $? -eq 0 ]; then
		cd -
		echo "[-] Vim Build failed" >&2
		exit 1
	fi

	cd - > /dev/null

	# Clear vim
	rm -r /tmp/vim	
}


function configure_vim {
	mkdir -p ~/.vim/bundle

	# Install vundle
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	if [ ! $? -eq 0 ]; then
		echo "[-] Cloning vundle failed" >2&
		exit 1
	fi
	
	cp $WORK_DIR"/config/vim/python_vimrc" ~/.vimrc
	vim -c ":PluginInstall" -c ":q" -c ":q"
	
	~/.vim/bundle/YouCompleteMe/install.py --clang-completer
}


function install_debian_dep {
	apt-get update
	apt-get install --assume-yes git gcc ncurses-dev build-essential python3 python3-dev cmake
	if [ ! $? -eq 0 ]; then
		echo "[-] Dependencies install failed"
		exit 1
	fi
}

function setup_env {
	python3 -m pip install virtualenv

	cp $WORK_DIR"/config/bash/bashrc" ~/.bashrc
	cp $WORK_DIR"/config/bash/bash_aliases" ~/.bash_aliases
}

WORK_DIR="$( dirname "${BASH_SOURCE[0]}" )"

# Intall dependencies
echo "[*] Installing dependencies"
install_debian_dep

echo "[*] Setting up env"
setup_env

echo "[*] Build VIM:"
build_vim

echo "[*] Configure VIM:"
configure_vim


echo "Successs"
