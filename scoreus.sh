#!/bin/bash
License="
# +------------------------------------------------------------------------------------------------------------+
# |
# |This program is free software: you can redistribute it and/or modify
# |it under the terms of the GNU General Public License as published by
# |the Free Software Foundation, either version 3 of the License, or
# |(at your option) any later version.
# |
# |This program is distributed in the hope that it will be useful,
# |but WITHOUT ANY WARRANTY; without even the implied warranty of
# |MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# |GNU General Public License for more details.
# |
# +----------------------------------------------------------------------------------------------------------------+"
License_link="See <a href=\"http://www.gnu.org/licenses/gpl.html\">Gpl Official page</a>"
git_address="https://github.com/Mermouy/scoreus"
git_link="<a href=\"https://github.com/Mermouy/scoreus\">$git_address</a>"
Summary="<b>Simple bash + yad application to record and stat your boardgames scoring sessions</b>\n\nThe project is on github and should take long to upgrade as I'm not a real developper...\nIf you are developper, I will be happy to learn advices from you but, please do not give all answers without <i>child-level explanations</i>!\nIf you're a beginner as I am feel free to participate to this small project.\nPlease contact me if you need help like \"where to start\"\nGithub repo: $git_link\n"
mini_changelog="Nothing works for now, just playing with yad widgets... slowly working on sqlite integration"
## Variables
Author="MerMouY [mermouy [at] gmail .com]"
Licence="<a href=\"http://www.gnu.org/licenses/gpl.html\">Gpl Official page</a>"
Version="0.0.1"
AppName="Scoreus"
# scoreus_error="$img_path/error.png"
# scoreus_warning="$img_path/warning.png"
g_cat_list="Fast!Bit less than an hour!Between 1 and 2 Hours!Evening!All night long"
g_ub_cat_list="Cartes!Ouvriers!Management"
Db_path="$HOME/.scoreus"
img_path="$Db_path/images"
scoreus_error="gtk-error"
scoreus_warning="gtk-warning"
scoreus_ok="$img_path/valid_16p.png"
scoreus_img="$img_path/scoreus.png"
##test variables
DIALOG=`which yad`
Db="$Db_path/scoreus.sqlite"
Game_default="$Db_path/uploads/games/default"
Player_default="$Db_path/uploads/images/avatars"
GuiName="--title=Scoreus --center --window-icon=$scoreus_img --name=Scoreus --class=Scoreus --selectable-labels --image-path=\"$img_path\""
CDATE=`date +"%Y-%m-%d-%H:%M:%S"`

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

function bug_report()
{
if [ -n "$1" ]
	then
	b_report="$1"
fi
issue=$(echo "$b_report" | $DIALOG $GuiName --text-info \
--text="Here is the error message if any has been generated, you fill/complete informations above to explain circumstances, diagnostic and eventually solution: " \
--button=Cancel:1 --button=Send:0 --editable --width=800 --height=350)
if [ "$?" != "0" ]
	then
	exit 0
else
	if [ -n "$issue" ]
		then git_open "$issue"
	else message error "Issue is empty...\nExiting..."
	exit 0
	fi
fi
}

rawurlencode() {
local string="${1}"
local strlen=${#string}
local encoded=""
for (( pos=0 ; pos<strlen ; pos++ )); do
	c=${string:$pos:1}
	case "$c" in
		[-_.~a-zA-Z0-9] )	o="${c}" ;;
		*)						printf -v o '%%%02x' "'$c" ;;
esac
encoded+="${o}"
done
echo "${encoded}" # You can either set a return variable (FASTER)
#REPLY="${encoded}"#+or echo the result (EASIER)... or both... :p
}

function git_open()
{
issue_text=$(rawurlencode "$1")
git_link_issue=$(echo "$git_address a" | sed "s| a|/issues/new?title=Name_your_issue\&body=$issue_text|")
xdg-open $git_link_issue
exit 0
}

function add_player_ui()
{
player_data=($($DIALOG $GuiName --form --text="<span size=\"x-large\"><b>Add a new player to the database: </b></span>" \
	--always-print-result --separator=" " \
	--field="Player Name: " Name \
	--field="Avatar (preferably square form): ":fl $HOME \
	--field="If your image is not already on this computer\nCheck this to upload it now.":chk FALSE \
	--field="Website: " "http://yourwebsite.com" \
	--field="Email address: " "you@yourmail.com" \
	--field="<b><u>Player should be considered as: </u></b>":lbl \
	--field="Games admin: ":chk false \
	--field="Players admin: ":chk false \
	--field="Games owned: ":txt \
	--quoted-output))
	if [ "$?" = "0" ]
		then
 		p_name=`echo ${player_data[0]} | sed "s/'//g"`
 		p_avatar=`echo ${player_data[1]} | sed "s/'//g"`
 		p_website=`echo ${player_data[3]} | sed "s/'//g"`
		p_http="<a href=${player_data[3]}>Website of $p_name</a>"
 		p_email=`echo ${player_data[4]} | sed "s/'//g"`
		p_mailto="<a href=\"mailto:$p_email\">$p_name</a>"
 		p_game_admin=`echo ${player_data[6]} | sed "s/'//g"`
 		p_players_admin=`echo ${player_data[7]} | sed "s/'//g"`
 		p_owned=`echo ${player_data[8]} | sed "s/'//g"`
 		case $p_game_admin in
 			TRUE)
 				if [ "$p_players_admin" = "TRUE" ]
 					then
 					p_powers="Full admin"
				else
					p_powers="Game admin"
				fi
			;;
			FALSE)
				if [ "$p_players_admin" = "TRUE" ]
					then
					p_powers="Players admin"
				else
					p_powers="Not an admin"
				fi
			;;
		esac
		Dir_name="$(dirname "$p_avatar")/"
		filename=`echo ${p_avatar%%.*} | sed "s|$Dir_name||"`
		convert "$p_avatar" -resize 256x\> "/tmp/$filename.png"
		mogrify -resize x256\> "/tmp/$filename.png"
		p_avatar="$Player_default/$filename.png"
		echo -e "$p_owned" | $DIALOG $GuiName --text-info --text="<b>Verify entered data to avoid any mistake.</b>\n\n \
If you agree with these data, click \"<i>Insert</i>\" button.\n\n\n \
	<i>Player avatar should be displayed on the left.</i>\n\n \
	<small>	Or there was an error with upload/selection.</small>\n\n \
		<b>Player Name: </b><span color=\"blue\">$p_name</span>\n\n  \
		<b>Player Website: </b><span color=\"blue\">$p_http</span>\n\n \
		<b>Player email address: </b><span color=\"blue\">$p_mailto</span>\n\n \
		<b>$p_name will be: </b><span color=\"blue\">$p_powers</span>\n\n \
		<b>And finally some his games: </b>" \
		--button=Insert:0 --button=Cancel:1 --image=/tmp/$filename.png
		if [ "$?" = "0" ]
			then
			cp "/tmp/$filename.png" "$p_avatar"
			player_data_2insert="0001,DATETIME('NOW'),${player_data[0]},$p_avatar,${player_data[3]},${player_data[4]},${player_data[5]},${player_data[6]}"
			sqlite3 $Db "insert into players ( p_created,p_name,p_avatar,p_website,p_email,p_game_admin,p_players_admin ) \
			values ( DATETIME('NOW'),${player_data[0]},'$p_avatar',${player_data[3]},${player_data[4]},${player_data[6]},${player_data[7]} );"  || message error "Unable to record \"$player_data_2insert\" in \"$Db\""
			echo $(sqlite3 $Db "select * from players" ;)
		fi
	else rm -f "/tmp/$filename" 2>/dev/null && exit 1
	fi
}

function squery()
{
sqlite3 $Db "select $p_name from $1 limit 1";
}

function search_ui()
{
p_search=$($DIALOG $GuiName --text="Search by: " --list \
--column="Choose: " --column="Search by: " --print-column=2 \
--limit=20 --listen --separator="" --radiolist \
TRUE Name FALSE Email FALSE 'Games Admin' FALSE 'Players Admin' \
--width=200 --height=250 --title="Scoreus Search" --no-headers --text-align=center)
if [ $? = 1 ]
	then
	exit 1
fi

case $p_search in
	"Name")
		player_name_query(){
			sqlite3 $Db "select $1 from players where p_name=\"$2\"";
		}
		p_name=$($DIALOG $GuiName --text="Enter Player Name to search :" --entry --entry-text=Name)
			if [ $? != 0 ]
				then
				exit 1
			fi
		p_query=$($DIALOG $GuiName --text="Choose what to display: " --list --radiolist \
--width=250 --height=250 --title="Scoreus Search" --no-headers --text-align=center \
TRUE "Email" FALSE "Is A Game Admin" FALSE "Is a Players Admin" FALSE "Show Player Avatar" FALSE "Everything" \
--print-column 2 --column="Choose :" --column="Display :" --separator="")
			case $p_query in
				"Email")
					player_name_query p_email "$p_name" | $DIALOG $GuiName --text="Search results: " --text-info --button=Quit:0 --width=200 && exit 0
					;;
				"Is A Game Admin")
					Ishe=$(player_name_query p_game_admin "$p_name" | sed 's/TRUE/Is/;s/FALSE/is not/')
					$DIALOG $GuiName --text="<big><b>$p_name <span color=\"red\">$Ishe</span> a Game Admin</b></big>" --button=Quit:0 --width=200 && exit 0
					;;
				"Is a Players Admin")
					Ishe=$(player_name_query p_players_admin "$p_name" | sed 's/TRUE/Is/;s/FALSE/is not/')
					$DIALOG $GuiName --text="<b><big>$p_name <span color=\"red\">$Ishe</span> a Player Admin</big></b>" --button=Quit:0 --width=200 && exit 0
					;;
				"Show Player Avatar")
					Avatar=$(player_name_query p_avatar "$p_name")
					$DIALOG $GuiName --title="$p_name\'s Avatar" --image=$Avatar --button=Quit:1 --width=280
					exit 0
					;;
				"Everything")
					EveryThing=( $(player_name_query "*" "$p_name" | sed 's/|/\n/g') )
					echo -e ${EveryThing[*]} | sed 's/ /\n/g' | $DIALOG $GuiName --list --listen --column=id --column="Creation Date" --column="Creation Time" --column="Player Name" --column="Player Avatar" --column="Player Website" --column="Player Email" --column="Is a Game Admin":chk --column="Is a Player Admin":chk --button=Cancel:1 --button=See:0
					if [ $? = 0 ]
						then
						 echo $(sqlite3 $Db 'select p_owned from players where p_name="$p_name";') | $DIALOG $GuiName --text-info --text="<b>Here is ${EveryThing[3]}.</b>\n\n \
<i>Player avatar should be displayed on the left.</i>\n\n \
<small>	Or there was an error with upload/selection.</small>\n\n \
<b>Player Website: </b><span color=\"blue\">${EveryThing[5]}</span>\n\n \
<b>Player email address: </b><span color=\"blue\">${EveryThing[6]}</span>\n\n \
<b>${EveryThing[3]} is Game Admin: </b><span color=\"blue\">${EveryThing[7]}</span>\n\n \
<b>${EveryThing[3]} is Player Admin: </b><span color=\"blue\">${EveryThing[8]}</span>\n\n \
<b>And finally some of his games: </b>" \
--button=Quit:1 --image=${EveryThing[4]}
					else exit 0
					fi
					exit 0
					;;
			esac
		;;
	"Email")
		p_mail=$($DIALOG --text="Enter Player Email" --entry --entry-text=player@mail.com)
		s_query=$(sqlite3 $Db "select p_email from players where p_name=\"$p_name\""; )
		exit 0
		;;
	"Games Admin")
		player_query * TRUE | $DIALOG $GuiName --text-info
		exit 0
		;;
	"Players Admin")
		echo "All Players Admins"
		exit 0
		;;
	"*")
		message error "No search with this argument"
		exit 1
		;;
esac
}

function add_play_ui()
{
echo "$mini_changelog" | $DIALOG $GuiName --title="Scoreus Add Play" --text="<big><b>Coming soon...</b></big>\n\nFor now just the mini changelog: \n" --text-info --button=Quit:1 --width=500
}

function add_game_ui()
{
g_data=($($DIALOG $GuiName --title="Scoreus Add Game" --text="<span size=\"x-large\"><b>Add a new game to the database: </b></span>" \
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
--colums=2 --quoted-output
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
# 	game_data_record=$($DIALOG $GuiName --text="<b>Verify entered data to avoid any mistake.</b>\n\n \
# 	If you agree with these data, click \"<i>Insert</i>\" button.\n\n\n \
# 	<i>Game image should be displayed on the left.</i>\n\n \
# 	<small>	Or there was an error with upload/selection.</small>\n\n \
# 	<b>Game Name: </b> <span color=\"blue\">\"${g_data[0]}\"</span>\n\n \
# 	<b>Game Categorie: </b><span color=\"blue\">${g_data[1]}</span>\n\n \
# 	<b>Game Website: </b><span color=\"blue\">"$g_http"</span>\n\n \
# 	<b>Game Author: </b><span color=\"blue\">\"${g_data[4]}\"</span>\n\n \
# 	<b>Game Editor: </b><span color=\"blue\">\"${g_data[0]}\"</span>\n\n \
# 	<b>Game Owner(s) (separated with colon): </b><span color=\"blue\">\"${g_data[6]}\"</span>\n\n \
# 	<b>And finally a little summary: </b><span color=\"blue\">\"${g_data[10]}\"</span>" \
# 	--button="Insert":0 --button=Cancel:1 --image=${g_data[7]})
# 	if [ "$?" = "0" ]
# 		then
		echo "on y va"
		sqlite3 $Db "insert into games (id,g_created,g_name,g_cat,g_website,g_author,g_editor,g_img,g_synopsis) \
		values ( '001','CDATE',${g_data[0]},${g_data[1]},${g_data[3]},${g_data[4]},${g_data[5]},${g_data[7]},${g_data[8]} );"  || message error "Unable to record \"${g_data[*]}\" in \"$Db\""
# 	else exit 1
# 	fi
else exit 1
fi
}

function config_ui()
{
$DIALOG $GuiName --title="Scoreus Config" --text="<big><b>Choose parameters here:</b></big>\n" \
--form --button=Quit:1 \
--field="Game Categories:"cbe "$g_cat" --field="g_sub_cat_list"
}

function help_ui()
{
$DIALOG $GuiName --title="Scoreus help" --text="What? You really need help for that shit not working?\n\nPlease...\n\n$help" --button=Quit:1
}

function about_ui()
{
echo -e "$License" | $DIALOG $GuiName --title="About Scoreus" --text-info --width=850 --height=600 --image="$scoreus_img" \
--text="<b>$AppName</b>\n\nVersion $Version is slowly and poorly developped by <b>$Author</b>\nThis is a simple bash script with easy widgets via yad or zenity to record your boardgames plays scores\n\n$Summary\n\n<b>Mini changelog:\n\n<span color=\"green\"><tt>$mini_changelog</tt></span>\n\nLicense:</b>" \
--dialog-sep  --button=Quit:1
}

function welcome_ui() {
$DIALOG $GuiName --form --text="<span size=\"xx-large\"><b><u>Welcome in Scoreus</u></b></span>\n\nChoose what you want to do: \n" \
--width=300 --height=200 --always-print-result --image="$scoreus_img" \
--field="Add Play!$scoreus_ok":fbtn  "./$0 --addplay" \
--field="Add Player!$scoreus_ok":fbtn "./$0 --addplayer" \
--field="Add Game!$scoreus_ok":fbtn "./$0 --addgame" \
--field="Config!$scoreus_ok":fbtn "./$0 --config" \
--field="Search Player!$scoreus_ok":fbtn "./$0 --search" \
--field="Statistics!$scoreus_ok":fbtn "./$0 --stats" \
--field="Help!gtk-help":fbtn "./$0 --help" \
--field="About!gtk-help":fbtn "./$0 --about" \
--button=Quit:1 --button="Report bug":0 --buttons-layout=spread --image-on-top
if [ "$?" ! = "0" ]
	then
	exit 1
else bug_report
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
		#stats_ui
		stats_ui
		;;
	"--search")
		search_ui
		;;
	"--about")
		about_ui
		;;
	"--help")
		help_ui
		;;
esac
