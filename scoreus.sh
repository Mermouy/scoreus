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
# Simple bash + yad application to record and stat your boardgames scoring sessions

## Variables
Author="MerMouY"
Licence="GPL 3"
Version="0.1"
AppName="Scoreus"
Install_dir=""
# scoreus_error="$img_path/error.png"
# scoreus_warning="$img_path/warning.png"
scoreus_error="gtk-error"
scoreus_warning="gtk-warning"
scoreus_ok="gtk-ok"
Db_path="$HOME/.scoreus"
img_path="$Db_path/images"
##test variables
DIALOG=`which yad`
GuiName="--title=Scoreus --center --window-icon=$scoreus_ok --name=Scoreus --class=Scoreus --selectable-labels --image-path=\"$img_path\""


### Functions

function message()
{
if [ $# -gt 1 ]
	then
	case "$1" in
		"error")
			$DIALOG $GuiName --text="<span color=\"red\"><b>$2</b></span>"  --image="$scoreus_error" --button=Quit $3
		;;
		"warning")
			$DIALOG $GuiName --text="<b>$2</b>"  --image="$scoreus_warning" --button=Ok $3
		;;
		"*")
		$DIALOG $GuiName --text="<span color=\"red\"><b>$1</b></span>" --image="$scoreus_ok" --button=Ok $3
		;;
	esac
else
	$DIALOG --text="<span color=\"red\"><b>$1</b></span>" --image="$scoreus_error" --button=Quit $2
fi
}

function add_player()
{
player_data=($($DIALOG $GuiName --form --text="<span size=\"x-large\"><b>Add a new player to the database: </b></span>" \
	--always-print-result --separator=" " \
	--field="Player Name: " Name \
	--field="Avatar (local file): ":fl $HOME \
	--field="If your image is not already on this computer\nCheck this to upload it now.":chk FALSE \
	--field="Website: " "http://yourwebsite.com" \
	--field="Email address: " "you@yourmail.com" \
	--field="<b><u>Player should be considered as: </u></b>":lbl \
	--field="Games admin: ":chk false \
	--field="Players admin: ":chk false \
	--field="Games owned: ":txt))
	if [ "$?" = "0" ]
		then
		p_name=${player_data[0]}
		p_avatar=${player_data[1]}
		p_website=${player_data[3]}
		p_http="<a href=\"$p_website\">Website of \"$p_name\"</a>"
		p_email=${player_data[4]}
		p_mailto="<a href=\"mailto:$p_email\">\"$p_name\"</a>"
		p_game_admin=${player_data[5]}
		p_players_admin=${player_data[6]}
		p_owned=${player_data[7]}
		if [ "$player_data[5]" = "true" ] && [ "$player_data[6]" = "true" ]
			then p_powers="Super admin powers\!"
		elif [ "$player_data[5]" = "true" ] && [ "$player_data[6]" = "false" ]
			then p_powers="Games admin status"
		elif [ "$player_data[5]" = "false" ] && [ "$player_data[6]" = "true" ]
			then p_powers="Players admin status"
		fi
		player_data_record=$($DIALOG $GuiName --text="<b>Verify entered data to avoid any mistake.</b>\n\nIf you agree with these data, click <i>Inser</i>' button.\n\n\n<i>Player avatar should be displayed on the left.</i>\n\n<b>Player Name:</b> <span color=\"blue\">$p_name</span>\n\n<b>Player Website: </b><span color=\"blue\">$p_http</span>\n\n<b>Player email address: </b><span color=\"blue\">$p_email</span>\n\n<b>$p_name will have $p_powers</b>\n\n<b>And finally some part of his life: </b><span color=\"blue\">\"$p_bio\"</span>" --button="Insert":0 --button=Cancel:1 --image="$p_avatar")
		if [ "$?" = "0" ]
			then
			echo "on y va\!"
		else exit 1
		fi
	else exit 1
	fi
}

# Look for recorded options while installed
# case $Install_dir in
# 	"")
# 	if [ -f "$HOME/.scoreus/config" ]
# 		then
# 		source "$HOME/.scoreus/config"
# 	else
# 		message error "Not able to find config file\nAre you sure it is installed?"
# 		exit 1
# 	fi
# 	;;
# 	"*")
# 	if  [ -f "$Install_dir/config" ]
# 		then
# 		source "$Install_dir/config"
# 	else
# 		message error "Not able to find config file\nAre you sure it is installed?"
# 		exit 1
# 	fi
# 	;;
# esac
add_player
echo $player_data | sed -e 's/|//g'
#welcome_form