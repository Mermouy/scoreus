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
mini_changelog="Nothing works for now, just playing with yad widgets...
then will have a look at sqlite integration"
## Variables
Author="MerMouY"
Licence="<a href=\"http://gpl3.org\">GPL 3</a>"
Version="0.0.1"
AppName="Scoreus"
# scoreus_error="$img_path/error.png"
# scoreus_warning="$img_path/warning.png"
Cat_list="Fast!Bit less than an hour!Between 1 and 2 Hours!Evening!All night long"
Sub_cat_list="Cartes!Ouvriers!Management"
scoreus_error="gtk-error"
scoreus_warning="gtk-warning"
scoreus_ok="/home/mermouy/Images/scoreus/scoreus_logo.png"
Db_path="$HOME/.scoreus"
img_path="$Db_path/images"
##test variables
DIALOG=`which yad`

GuiName="--title=Scoreus --center --window-icon=$scoreus_error --name=Scoreus --class=Scoreus --selectable-labels --image-path=\"$img_path\""


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

function add_player_ui()
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
		player_data_record=$($DIALOG $GuiName --text="<b>Verify entered data to avoid any mistake.</b>\n\nIf you agree with these data, click \"<i>Insert</i>\" button.\n\n\n<i>Player avatar should be displayed on the left.</i>\n\n<small>	Or there was an error with upload/selection.</small>\n\n<b>Player Name:</b> <span color=\"blue\">$p_name</span>\n\n<b>Player Website: </b><span color=\"blue\">$p_http</span>\n\n<b>Player email address: </b><span color=\"blue\">$p_email</span>\n\n<b>$p_name will have $p_powers</b>\n\n<b>And finally some part of his life: </b><span color=\"blue\">\"$p_bio\"</span>" --button="Insert":0 --button=Cancel:1 --image="$p_avatar")
		if [ "$?" = "0" ]
			then
			echo "on y va"
		else exit 1
		fi
	else exit 1
	fi
}

function add_play_ui()
{
echo "$mini_changelog" | $DIALOG $GuiName --title="Scoreus Add Play" --text="<big><b>Coming soon...</b></big>\n\nFor now just the mini changelog: \n" --text-info --button=Quit:1 --width=500
}

function add_game_ui()
{
g_data=($($DIALOG $GuiName --title="Scoreus Add Game" --text="<span size=\"x-large\"><b>Add a new gmae to the database: </b></span>" \
--form --always-print-result --separator=" " \
--field="Game Name: " "Game Name" \
--field="Game category: ":cb "$Cat_list" \
--field="Game subcategory: ":cb "$Sub_cat_list" \
--field="Website: " http://gamesite.com \
--field="Author(s): " "A famous one?" \
--field="Editor: " "Ravensburger?" \
--field="Owner(s): " "mermouy" \
--field="Game Image: ":sfl "$HOME" \
--field="If your image is not already on this computer\nCheck this to upload it now.":chk FALSE \
--field="Score Board: ":chk "true" \
--field="Game Synopsis: ":txt \
--colums=2
))

if [ "$?" = "0" ]
	then
	g_name=${g_data[0]}
	g_cat=${g_data[1]}
	g_website=${g_data[3]}
	g_http="<a href=\"$g_website\">Website of \"$g_name\"</a>"
	g_author=${g_data[4]}
	g_editor=${g_data[5]}
	g_owner=${g_data[6]}
	g_img=${g_data[7]}
	g_synopsis=${g_data[10]}
	if [ "${g_data[9]}" = "true" ]
		then
		add_score_board
	fi
	if [ "${g_data[8]}" = "true" ]
		then
		echo "upload file"
	fi
	game_data_record=$($DIALOG $GuiName --text="<b>Verify entered data to avoid any mistake.</b>\n\n \
	If you agree with these data, click \"<i>Insert</i>\" button.\n\n\n \
	<i>Game image should be displayed on the left.</i>\n\n \
	<small>	Or there was an error with upload/selection.</small>\n\n \
	<b>Game Name: </b> <span color=\"blue\">\"${g_data[0]}\"</span>\n\n \
	<b>Game Categorie: </b><span color=\"blue\">${g_data[1]}</span>\n\n \
	<b>Game Website: </b><span color=\"blue\">"$g_http"</span>\n\n \
	<b>Game Author: </b><span color=\"blue\">\"${g_data[4]}\"</span>\n\n \
	<b>Game Editor: </b><span color=\"blue\">\"${g_data[0]}\"</span>\n\n \
	<b>Game Owner(s) (separated with colon): </b><span color=\"blue\">\"${g_data[6]}\"</span>\n\n \
	<b>And finally a little summary: </b><span color=\"blue\">\"${g_data[10]}\"</span>" \
	--button="Insert":0 --button=Cancel:1 --image=${g_data[7]})
	if [ "$?" = "0" ]
		then
		echo "on y va"
	else exit 1
	fi
else exit 1
fi
}

function config_ui()
{
$DIALOG $GuiName --title="Scoreus Config" --text="<big><b>Coming soon...</b></big>\n" --button=Quit:1
}

function help_ui()
{
$DIALOG $GuiName --title="Scoreus help" --text="What? You really need help for that shit not working?\n\nPlease...\n\n$help" --button=Quit:1
}

function about_ui()
{
$DIALOG $GuiName --title="About Scoreus" --text="$AppName Version $Version is slowly and poorly developped by $Author\n \
This is a simple bash script with easy widgets via yad or zenity to record your boardgames plays scores\n\n \
<span color=\"green\">$mini_changelog</span>\n\n \
The project is on github and should take long to upgrade as I'm not a real developper...\n \
If you are developper, I will be happy to learn advices from you but,\n \
Please do not give all answers without child-level explanations!\n \
If you're a beginner as I am feel free to participate to this small project.\n \
Please contact me if you need help like \"where to start\"\n \
Github repo: <a href=\"https://github.com/Mermouy/scoreus\">https://github.com/Mermouy/scoreus</a>\n" \
--button=Quit:1 --width=400 --height=280 --image="$scoreus_ok" --image-on-top
}

function welcome_ui() {
$DIALOG $GuiName --form --text="<span size=\"xx-large\"><b><u>Welcome in Scoreus</u></b></span>\n\nChoose what you want to do: \n" \
--width=300 --height=200 --always-print-result --image="$scoreus_ok" \
--field="Add Play!gtk-ok":fbtn  "./$0 --addplay" \
--field="Add Player!gtk-ok":fbtn "./$0 --addplayer" \
--field="Add Game!gtk-ok":fbtn "./$0 --addgame" \
--field="Config!gtk-ok":fbtn "./$0 --config" \
--field="Statistics!gtk-ok":fbtn "./$0 --stats" \
--field="Help!gtk-help":fbtn "./$0 --help" \
--field="About!gtk-help":fbtn "./$0 --about" \
--button=Quit:1 --buttons-layout=spread --image-on-top
if [ "$?" = "1" ]
	then
	exit 1
fi
}

function stats_ui()
{
$DIALOG $GuiName --title="Scoreus help" --text="What? You really think stats are available?\n\nPlease...\n\nSeriously...\n\n$help" --button=Quit:1
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
#add_player
#welcome_form
case $1 in
	"")
		welcome_ui
		;;
	"--config")
		config_ui
		;;
	"--addplayer")
		add_player_ui
		;;
	"--addgame")
		add_game_ui
		;;
	"--addplay")
		add_play_ui
		;;
	"--stats")
		stats_ui
		;;
	"--about")
		about_ui
		;;
	"--help")
		help_ui
		;;
esac
