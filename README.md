# Custom udev input device for accessibility or macros
This covers how to setup a device that doesn't register normal key inputs as a
keyboard for creating custom actions for accessibility or macro users. This is
specifically covering setting up an Infinity IN-USB-1 footpedal. But the general
concepts here should work for any device with an existing linux driver.

I'm writing this document with intention of being understandable by both linux
newcomers and experienced users. So I will try to explain as much about the
steps as I can.

This is written and tested on Ubuntu 17.10 intended for use with Ubuntu or other
`systemd` distributions but not all system files may be in the same place.


## Simple Keyboard Setup

### 0. Open `/lib/udev/hwdb.d/60-keyboard.hwdb`

Run `less /lib/udev/hwdb.d/60-keyboard.hwdb` and check out the top of the file
to view the built-in documentation if you want to get an understanding of how
this process works. I explain most of the steps you will need. But if you get
lost or something isn't working you can refer to this file for more specific
details.


*This file may be in a different location in a different distros*


### 1. Create new udev file: `/etc/udev/hwdb.d/70-keyboard.hwdb`

*You will need higher level permissions to modify files under the `/etc`
directory so we will use `sudo` to elevate the file editing command to run with
`root` user permissions.*

Open a new file in a text editor with
`sudo nano /etc/udev/hwdb.d/70-keyboard.hwdb`. Add the following line that we
will modify in a moment to contain your devices USB information to identify it.


`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*vYYYYpXXXXe*
```


### 2. Use `lsusb` to find your device USB IDs
Run `lsusb` and look for a name that describes the device you are trying to
setup. For example, here is the line for my footpedal:

`Bus 003 Device 011: ID 05f3:00ff PI Engineering, Inc. VEC Footpedal`

If you can't determine what your device is in the list you can unplug it and run
the following commands before and after plugging your device back in.

```
# Unplugged
lsusb > /tmp/lsusb
# Plug the device back in
lsusb > /tmp/lsusb2
diff /tmp/lsusb /tmp/lsusb2
```


3. change the file with usb id
(Must be uppercase)
evdev:input:b*v05F3p00FFe*

4. use `ls -l /dev/input/by-id` to get event # or alternatively `udevadm trigger --verbose --sysname-match="event*"` and look for the USB ID

5. find scan codes for your device sudo evtest /dev/input/event#
push all buttons and note the (probably) type 4 value for each one
Event: time 1534788138.561137, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90001
Event: time 1534788138.561137, type 1 (EV_KEY), code 256 (BTN_0), value 0

6. Go back to the new conf file and add the scan codes
(like python, you must have the space)
evdev:input:b*v05F3p00FFe*
 KEYBOARD_KEY_90001=
 KEYBOARD_KEY_90002=
 KEYBOARD_KEY_90003=

7. From here you can add the names of the keys you want:
(usable keys: https://github.com/xkbcommon/libxkbcommon/blob/master/test/evdev-scancodes.h )
evdev:input:b*v05F3p00FFe*
 KEYBOARD_KEY_90001=a
 KEYBOARD_KEY_90002=w
 KEYBOARD_KEY_90003=d

8. Reload the udev configutations
systemd-hwdb update
udevadm trigger --verbose --sysname-match="event*"

9 Done!


   ---  Complex keyboard setup ---

0. Complete simple setup

1. change keys to unusual keys
(f13 and f15 should probably be avoided due to tab changing)

evdev:input:b*v05F3p00FFe*
  2  KEYBOARD_KEY_90001=f16
  3  KEYBOARD_KEY_90002=f17
  4  KEYBOARD_KEY_90003=f18

2.1 xbind keys / blocking
(init xbindkeys -d > ~/.xbindkeysrc)
"notify-send left"
   c:194

"notify-send middle"
   c:195

"notify-send right"
   c:196

2.2 xinput test / non-blocking
#!/bin/bash
#xinput list for id
xinput test 15 | while read in ; do
  [[ $in = "key press   194" ]] && notify-send left
  [[ $in = "key press   194" ]] && notify-send middle
  [[ $in = "key press   194" ]] && notify-send right
  echo "nothing"
done

3. Create scripts

either make one script per button or a single script with a button parameter.


