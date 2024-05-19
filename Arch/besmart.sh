#!/bin/bash

echo "Ensuring all scripts are executable..."
chmod +x ./scripts/*.sh
chmod +x ./configs/config/scripts/*.sh

echo "Setting variables..."
WALLPAPER_PATH="/usr/share/wallpapers"
WALLPAPER_NAME="interstellarArt.jpg"
FONT_PATH="$HOME/.local/share/fonts"

clear
echo ""
echo "  =:| Automated Setup Script |:=    "
echo ""

set_hardlinks () {
    # light dm
    echo "--- LIGHTDM LINKS ---"
    sudo cp -lf configs/conf/lightdm.conf /etc/lightdm/
    sudo cp -lf configs/conf/lightdm-mini-greeter.conf /etc/lightdm

    # dotfiles
    echo "--- DOTFILE LINKS ---"
    cp -lfr ./configs/dotfiles/.* $HOME

    # .config files/folders
    echo "--- .CONFIG LINKS ---"
    cp -lfr ./configs/config/* $HOME/.config/
        
    # fontconfig
    echo "--- FONTCONFIG LINK ---"
    if [ -d $HOME/fontconfig ]; then rm -rf $HOME/fontconfig ; fi
    mkdir $HOME/fontconfig
    ln ./configs/fontconfig/conf.d $HOME/fontconfig

    echo "--- DONE ---"

    main
}

set_fonts () {
    echo "--- SETTING CUSTOM FONT ---"
    if [ ! -d $FONT_PATH ]; then mkdir -p $FONT_PATH; fi
    cp ./fonts/HackNerdFont-Regular.ttf $FONT_PATH
    fc-match "Hack Nerd Font"
    echo "--- DONE ---"
}


base_sys_config () {
    echo "Setting custom fonts..."
    set_fonts
    echo "Fonts set."
    echo "Setting hardlinks..."
    set_hardlinks
    echo "Hardlinks set."
    echo "Sourcing bash..."
    python ./scripts/sourcebash.py $HOME
    echo "Bash sourced."
    echo "Setting wallpaper..."
    set_wallpaper
    echo "Wallpaper set."
    main
}

post_configuration () {
    echo ""
    echo "1. Install Neovim"
    echo "2. Install Dropbox"
    echo "3. Setup Audio"
    echo "4. Setup Bluetooth"
    echo "7. Replace custom wallpapers/ files"
    echo "9. Exit"
    read -p "Please enter your choice: " selection 

    case $selection in
        "1")
            ./scripts/install_neovim.sh
            post_configuration
            ;;
        "2")
            ./scripts/install_dropbox.sh
            post_configuration
            ;;
        "3")
            ./scripts/setup_audio.sh
            post_configuration
            ;;
        "4")
            ./scripts/setup_bluetooth.sh
            post_configuration
            ;;
        "7")
            set_wallpaper
            post_configuration
            ;;
        "9")
            exit
            ;;
          *)
            echo "Invalid input."
            post_configuration
            ;;
    esac 
}

set_wallpaper () { 
    echo "--- DIR CHECK '$WALLPAPER_PATH' ---"
    if [ -d $WALLPAPER_PATH ]; then rm $WALLPAPER_PATH/*; fi
    if ! [ -d $WALLPAPER_PATH ]; then mkdir $WALLPAPER_PATH; fi
    echo "--- MIGRATING IMAGES ---"
    sudo cp -a ../wallpapers/. $WALLPAPER_PATH
    echo "--- DONE ---"
    echo "--- SETTING NEW WALLPAPER VALUE ---"
    python3 ./scripts/confEditer.py ./configs/conf/lightdm-mini-greeter.conf background-image "\"/usr/share/wallpapers/$WALLPAPER_NAME\""
    python3 ./scripts/alwaysExecEditer.py ./configs/config/i3/config "feh --bg-fill" /usr/share/wallpapers/$WALLPAPER_NAME
    echo "--- DONE ---"
}

main () {
    echo ""
    echo "1. Install needed packages & dependancies. ~ FIRST STEP BEFORE DOING ANYTHING BELOW"
    echo "2. Base system config ~ Automated setup (Sets up everything in one go)"
    echo "3. Individual configurations Indiviudal setups (For edits or breakages)"
    echo "4. Set Hardlinks ~ CURRENTLY HERE FOR DEV PURPOSES)"
    echo "9. Exit"
    read -p "Please enter your choice: " selection 

    case $selection in
        "1")
            ./scripts/base.sh
            ;;
        "2")
            base_sys_config
            ;;
        "3")
            post_configuration
            ;;
        "4")
            set_hardlinks
            ;;
        "9")
            exit
            ;;
          *)
            echo "Invalid input."
            main
            ;;
    esac 
}
main

