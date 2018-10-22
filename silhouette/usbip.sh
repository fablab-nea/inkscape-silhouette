#!/bin/sh

USBIP_REMOTE="$2"
USBIP_DEVICE="$3"

timeout=10

case $1 in
	attach)
		modprobe vhci-hcd
		usbip attach -r "$USBIP_REMOTE" -b "$(usbip list -r "$USBIP_REMOTE" | grep "$USBIP_DEVICE" | sed -n -r 's/^\s*([0-9]+-[0-9]+\.[0-9]+):.*$/\1/p')"
		retries=0
		while [ -z "$(lsusb -d "$USBIP_DEVICE")" ]; do
			sleep 1
			retries=$((retries+1))
			if [ $retries -gt $timeout ]; then
				echo "timeout waiting for usb device attachment" >&2
				exit 1
			fi

		done
	;;

	detach)
		usbip detach -p "$(usbip port | grep -B 1 "$USBIP_DEVICE" | sed -n 's/^Port \([0-9]*\):.*$/\1/p')"
	;;
esac

