#!/bin/zsh -f
# Purpose: Turn on Do Not Disturb
#
# From:	Tj Luo.ma
# Mail:	luomat at gmail dot com
# Web: 	http://RhymesWithDiploma.com
# Date:	2015-09-28
#
# Adapted from:
# AppleScripting Notification Center > Scheduling Do Not Disturb
# http://www.tuaw.com/2013/02/04/applescripting-notification-center-scheduling-do-not-disturb/

NAME="$0:t:r"

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

############ OS X NOTIFICATIONS ############

DND_STATUS=`defaults -currentHost read "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null`

if [ "$DND_STATUS" = "1" ]
then

	[[ "$SHLVL" = "3" ]] && echo "$NAME: DND is already on"
	exit 0
fi

defaults -currentHost delete com.apple.notificationcenterui dndStart 2>/dev/null
defaults -currentHost delete com.apple.notificationcenterui dndEnd 2>/dev/null
defaults -currentHost delete "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb 2>/dev/null
defaults -currentHost delete "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturbDate 2>/dev/null
defaults -currentHost read "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" 2>/dev/null

[[ "$SHLVL" = "3" ]] &&  echo "$NAME: Deleted old preferences"

defaults -currentHost write "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb -boolean true

TS=`date -u +"%Y-%m-%d %H:%M:%S +0000"`

defaults -currentHost write "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturbDate -date "$TS"

[[ "$SHLVL" = "3" ]] &&  echo "$NAME: dwrite DND yes and time/date"

# Read preferences, mostly to make sure that it has been updated
defaults -currentHost read "$HOME/Library/Preferences/ByHost/com.apple.notificationcenterui" 2>&1 >/dev/null

launchctl stop com.apple.notificationcenterui.agent && [[ "$SHLVL" = "3" ]] && echo "$NAME: stopped agent launchd"

launchctl start com.apple.notificationcenterui.agent && [[ "$SHLVL" = "3" ]] && echo "$NAME: resumed agent launchd"

if (( $+commands[terminal-notifier] ))
then
	terminal-notifier -message "DND was started at $TS" -title "$NAME"
fi

############ OS X NOTIFICATIONS ############


exit 0
#
#EOF
