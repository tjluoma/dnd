#!/bin/zsh
# Purpose: Turn Do Not Disturb OFF
#
# AppleScripting Notification Center > Scheduling Do Not Disturb
# http://www.tuaw.com/2013/02/04/applescripting-notification-center-scheduling-do-not-disturb/
# and
# https://raw.githubusercontent.com/dwsparks/OSXDnDToggle/master/DNDToggle.sh
#
# From:	Tj Luo.ma
# Mail:	luomat at gmail dot com
# Web: 	http://RhymesWithDiploma.com
# Date:	2015-01-22


### 2015-09-28 - this works, but it leaves the icon 'greyed out' so it still _looks_ inactive.

NAME="$0:t:r"

DND_STATUS=`defaults -currentHost read "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null`

if [ "$DND_STATUS" != "1" ]
then
	echo "$NAME: DND is already off"
	exit 0
fi



defaults -currentHost delete com.apple.notificationcenterui dndStart 2>/dev/null
defaults -currentHost delete com.apple.notificationcenterui dndEnd 2>/dev/null
defaults -currentHost delete "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null
defaults -currentHost delete "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturbDate 2>/dev/null
defaults -currentHost read   "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" 2>/dev/null

defaults -currentHost write com.apple.notificationcenterui doNotDisturb -boolean false


launchctl stop com.apple.notificationcenterui.agent && echo "$NAME: stopped agent launchd"

launchctl start com.apple.notificationcenterui.agent  && echo "$NAME: resumed agent launchd"

if (( $+commands[terminal-notifier] ))
then
	terminal-notifier -message "DND is now OFF" -title "$NAME"
fi

exit
#
#EOF
