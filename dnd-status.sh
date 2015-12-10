#!/bin/zsh -f
# Check the Status of DND mode
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2015-09-29

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi


OSX_DND_RAW=`defaults -currentHost read "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null`

if [[ "$OSX_DND_RAW" = "1" ]]
then
	IS_OSX_DND='yes'
else
	IS_OSX_DND='no'
fi


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Get Mute/Unmute Status
#

MUTE_STATUS=`/usr/bin/osascript <<EOT
if output muted of (get volume settings) is true then
	return yes
else
	return no
end if
EOT`

case "$MUTE_STATUS" in
	yes)
		MUTE_STATUS_READABLE="Sound IS Muted"

	;;

	no)
		MUTE_STATUS_READABLE="Sound IS NOT Muted"

	;;

	*)
		MUTE_STATUS_READABLE="Mute Status UNKNOWN"
	;;

esac

pgrep -xq Growl

GROWL_EXIT="$?"

if [[ "$GROWL_EXIT" == "0" ]]
then

# Don't Indent - BEGIN
IS_GROWL_PAUSED=`/usr/bin/osascript <<EOT

tell application "System Events"
	set isRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
end tell

if isRunning then
	tell application id "com.Growl.GrowlHelperApp"
		set paused to is paused
		if (paused) then
			return yes
		else
			return no
		end if
	end tell
end if

EOT`
# Don't Indent - END

else
	## If we get here, Growl isn't running, which just as good

	IS_GROWL_PAUSED='yes'

fi


if [ "$IS_OSX_DND" = 'yes' -a "$IS_GROWL_PAUSED" = 'yes' ]
then
		echo "Both Growl and OS X Notifications are paused."
elif [ "$IS_OSX_DND" = 'no' -a "$IS_GROWL_PAUSED" = 'no' ]
then
		echo "Neither Growl nor OS X Notifications are paused."
elif [ "$IS_OSX_DND" = 'yes' -a "$IS_GROWL_PAUSED" = 'no' ]
then
		echo "OS X Notifications are paused but Growl is not"
elif [ "$IS_OSX_DND" = 'no' -a "$IS_GROWL_PAUSED" = 'yes' ]
then
		echo "Growl is paused but OS X Notifications are not"
fi

echo "$MUTE_STATUS_READABLE"

# EXIT = 1 means that something is NOT paused
# EXIT = 0 means that both ARE paused
exit 1


#
#EOF
