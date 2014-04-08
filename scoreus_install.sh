#!/bin/bash
# +------------------------------------------------------------+
# | MerMouY mermouy[at]gmail[dot]com
# |
# | This program is free software; you can redistribute it and/or
# | modify it under the terms of the GNU General Public License
# | as published by the Free Software Foundation; either version
# | 3 of the License, or (at your option) any later version.
# |
# | This program is distributed in the hope that it will be useful,
# | but WITHOUT ANY WARRANTY; without even the implied warranty
# | of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# | See the GNU General Public License for more details.
# |
# | You should have received a copy of the GNU General Public
# | License along with this program; if not, write to the
# | Free Software Foundation, Inc., 51 Franklin St,
# | Fifth Floor, Boston, MA  02110-1301  USA
# +------------------------------------------------------------+
# Simple bash/yad script to maintain a Boardgame/other games database & statistics
# Installer part

# Require yad sqlite3
Required="yad sqlite3"

Author="MerMouY"
Licence="GPL 3"
Version="0.1"
AppName="Scoreus"

# Install variables
Install_dir="$HOME/bin"
Db_path="$HOME/.scoreus"
Db="$Db_path/scoreus.db"
GuiName='--name="Scoreus Installer" --class="Scoreus"'
CDATE=`date +"%Y-%m-%d-%H:%M:%S"`
Clone_path=`pwd`
scoreus_icon="$Clone_path/images/scoreus.png"

### Functions
function search_dialog()
{
    for i in `type -p yad kdialog zenity enity Xdialog dialog 2> /dev/null`
    do
        if [ -n $i ]
        then
            DIALOG=$i
            return;
        fi
    done
}

function search_sudo()
{
    for i in `which kdesu gksudo esudo 2> /dev/null`
    do
        if [ -n $i ]
        then
            xsudo=$i
            return;
        else
        	echo -e "Error please install either kdesu, gksudo or esudo manually and restart the installer"
        	exit 1
        fi
    done
}

function message()
{
	if [ -n "$2" ] && [ "$1" = "error" ]
		then
		case $DIALOG in
    	*yad)
    		yad $GuiName --title="YaScore Installer" --text="<span color=\"red\"><b>$2</b></span>" --center --window-icon="yascore_icon" --image="gtk-error" --button=Quit:0
    		;;
        *dialog|*Xdialog|*kdialog)
			# FIXME
            $DIALOG --title "Yascore Installer" --msgbox "$2" 0 0
            ;;
        *zenity)
            # FIXME
            zenity $GuiName --title="YaScore Installer" --window-icon="yascore_icon" --error --text="<span color=\"red\"><b>$2</b></span>" --ok-label=Quit
            ;;
        *)
            echo -e $1
    esac
    elif [ -n "$2" ] && [ "$1" = "warning" ]
    	then
		case $DIALOG in
    	*yad)
    		yad $GuiName --title="YaScore Installer" --text="<span color=\"green\"><b>$2</b></span>" --center --window-icon="yascore_icon" --image="gtk-info" --button=Quit:0
    		;;
        *dialog|*Xdialog|*kdialog)
			# FIXME
            $DIALOG --title "Yascore Installer" --msgbox "$2" 0 0
            ;;
        *zenity)
            # FIXME
            zenity $GuiName --title="YaScore Installer" --window-icon="yascore_icon" --error --text="<span color=\"green\"><b>$2</b></span>" --ok-label=Quit
            ;;
        *)
            echo -e $1
    esac
    elif [ -n "$3" ] && [ "$1" = "more" ]
    	then
    	case $DIALOG in
    		*yad)
    			yad $GuiName --title="YaScore Installer" --text="$2" --center --window-icon="yascore_icon" --image="gtk-help" $3
    			;;
        	*dialog|*Xdialog|*kdialog)
				# FIXME
            	$DIALOG --title "Yascore Installer" --msgbox "$1" 0 0
				;;
			*zenity)
			# FIXME
            	zenity $GuiName --title="YaScore Installer" --window-icon="yascore_icon" --error --text="<span color=\"red\"><b>$2</b></span>"
            	;;
			*)
				echo -e $1
    	esac
    elif [ -z "$2" ] && [ -n "$1" ]
    	then
    	case $DIALOG in
    		*yad)
    			yad $GuiName --title="YaScore Installer" --text="$1" --center --window-icon="yascore_icon" --image="gtk-help"
    			;;
        	*dialog|*Xdialog|*kdialog)
				# FIXME
            	$DIALOG --title "Yascore Installer" --msgbox "$1" 0 0
				;;
			*zenity)
			# FIXME
            	zenity $GuiName --title="YaScore Installer" --window-icon="yascore_icon" --error --text="<span color=\"red\"><b>$1</b></span>"
            	;;
			*)
				echo -e $1
    	esac
	else
		echo "$0 encountered an error"
	fi
}

function install_dep() {
search_sudo
if [ -z "$xsudo" ]
	then
	search_sudo
fi
search_os
case $OS in
        debian|ubuntu)
            $xsudo apt-get install -y --force-yes `cat /tmp/.missing`
            ;;
        *suse*)
            $xsudo zypper in `cat /tmp/.missing`
            ;;
        *arch*|*manjarolinux*)
            $xsudo pacman -S --noconfirm `cat /tmp/.missing`
            ;;
        centos|redhat)
            echo "TODO"
            ;;
        *)
            message error "Unknown OS: $OS, please install python virtualenv manually and restart the installer"
esac
}

function chk_dependances() {
	rm -f /tmp/.missing
	for req in $Required
		do
		if [ "$(type -p $req > /dev/null)" = "0" ]
			then
			echo -e "$req" >> /tmp/.missing
		fi
	done
if [ -f /tmp/.missing ]
	then
	message "<b>Some packages are missing:</b>\n`cat /tmp/.missing`\n<b>Do you want me to install?</b>"
	if [ $? = 0 ]
		then
		detect_os
		install_dep `cat /tmp/.missing`
	fi
fi
}

function search_os()
{
    LSB=`which lsb_release 2> /dev/null`

    if [ -n $LSB ]
    then
        # Getting only the ID
        OS=`$LSB -s -i`
        OS=`echo $OS | tr â€œ[:upper:]â€ â€œ[:lower:]â€œ`
    fi
}

search_dialog
chk_dependances

### Install Scoreus
#Install arch
function install_arch() {
# find directories to create, following archive arch
	Folder_arch=`find . -type d ! -regex ".*/\..*" ! -name ".*" -printf "%p "  | sed -e 's|\./||g'`
	for f in $Folder_arch
	do
		echo $f
		if [ ! -d  $f ]
			then
			mkdir -p $Db_path/$f
		fi
	done
}

function init_db() {
if [ ! -f "$Db" ]
	then
# Create database &
# Defining my databse first table
	p_table="CREATE TABLE players (id integer primary key,p_created date, p_name varchar(30), p_avatar TEXT, p_website TEXT, p_email EMAIL, p_game_admin TEXT REQUIRED, p_players_admin TEXT REQUIRED, p_owned blob);"

	g_table="CREATE TABLE games (id INTEGER PRIMARY KEY,g_created date DEFAULT CURRENT_TIMESTAMP, g_name TEXT REQUIRED, g_cat TEXT, g_website TEXT, g_author TEXT, g_editor TEXT, g_img TEXT, g_synopsis);"
	echo "$p_table" > /tmp/tmpstructure
	echo "$g_table" >>  /tmp/tmpstructure

	sqlite3 "$Db" < /tmp/tmpstructure;
	if [ -f "$Db" ]
		then
		rm -f /tmp/tmpstructure;
		message "Database tables <span color=\"blue\">players</span> and <span color=\"blue\">games</span> created."
	else
		message error "Not able to create $Db"
		exit 1
	fi
elif [ -f "$Db" ] && [ ! -f $Install_dir/scoreus.sh ]
	then
		message more "Database \n<span color=\"blue\">$Db</span>\nexists, not overwriting it...\nBut Scoreus folder and binaries does'nt.\n\nIf you want to re-install Scoreus you should first rename \n<span color=\"blue\">$Db</span> \nto something else, then run this installer again..." \
		"--button=Rename:0  --button=Quit:1"
		if [ $? = 0 ]
			then
			Back_Db="$Db.$CDATE~"
			mv $Db $Back_Db
			message "Database renamed in $Back_Db"
			if [ $? = 0 ]
				then
				init_db
			else exit 1
			fi
		else exit 1
		fi
else
	message warning "Nothing to do.\nDatabase $Db exists and binary $Install_dir/scoreus.sh is executable."
	exit 1
fi
}

function install_files() {
	img_files=`find ./images/ -type f ! -regex ".*/\..*" ! -name ".*" ! -empty -printf "%p "`
	ScorFiles="$img_files LICENSE README.md"
	ScorExe="scoreus.sh"
	for f in "$ScorFiles"
		do
		cp $clone_path/$f $Db_path/$f
	done
	for f in "$ScorExe"
		do
		cp $clone_path/$f $Install_dir/$f
	done
}

function record_options()
{
	echo -e "DIALOG=\"$DIALOG\"\nInstall_dir=\"$Install_dir\"\nDb_path=\"$Db_path\"Db=\"$Db\"\nGuiName='--title=\"Scoreus\" --center --window-icon="$scoreus_icon" --name=\"Scoreus Installer\" --class=\"Scoreus\"\nimg_path=\"$Db_path/images\"'
" > $Db_path/config
}

function install_scoreus() {
install_arch
install_files
init_db
record_options
}

#Verifications
search_dialog
if [ -z $DIALOG ]
then
    message error "No dialog command found.\nPlease install kdialog, zenity, xdialog or dialog for a better interface."
    exit 0
else
	message "Using $DIALOG as dialog interface"
fi

### Installation
install_scoreus
message "Everything looks great\!\n\n\n<span color=\"red\"><b><big>Scoreus</big></b></span> installed\!\n\n"