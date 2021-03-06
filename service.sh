#!/sbin/.magisk/busybox/ash
# shellcheck shell=dash
SH=$(readlink -f "$0")
MODDIR=$(dirname "$SH")
exxit() {
	  set +euxo pipefail
	    [ "$1" -ne 0 ] && abort "$2"
	      exit "$1"
      }
exec 3>&2 2>"$MODDIR"/logs/service-verbose.log
set -x 2
set -euo pipefail
trap 'exxit $?' EXIT
FINDLOG=$MODDIR/logs/find.log
VERBOSELOG=$MODDIR/logs/service-verbose.log
touch "$VERBOSELOG"
echo "Started at $(date)"
if test -d "$MODDIR"/apk/ ;
then
	sleep 30
	pm install -r -g "$MODDIR"/apk/webview.apk 2>&3
	pm install -r -g "$MODDIR"/apk/browser.apk 2>&3
	echo "Installed bromite webview as user app.."
	if pm list packages -a|grep -q com.android.chrome 2>&3;
	then
		pm disable com.android.chrome 2>&3;
	fi
	echo "Disabled chrome and google webview. You may re-enable but please be aware that may cause issues";
	rm -rf "$MODDIR"/apk/
else
	echo "Skipping install, as the needed files are not present. This is most likely because they've already been installed"
fi
while test "$(getprop sys.boot_completed)" != "1"  && test ! -d /storage/emulated/0/Android ;
do sleep 30;
done
{ echo "SDCARD DIR contains:\n"; find /storage/emulated/0/WebviewSwitcher; echo "\nModule DIR contains:\n"; find "$MODDIR"; } > "$FINDLOG"
tail -n +1 "$MODDIR"/logs/install.log "$MODDIR"/logs/aapt.log "$MODDIR"/logs/find.log "$MODDIR"/logs/props.log "$MODDIR"/logs/postfsdata-verbose.log "$MODDIR"/logs/service-verbose.log > "$MODDIR"/logs/complete.log 
cp -rf "$MODDIR"/logs /storage/emulated/0/WebviewSwitcher/