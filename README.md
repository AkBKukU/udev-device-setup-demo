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

This process is showing how it is done with a nonstandard input device. This
could also be done with an additional keyboard (with a uniqe USB
Vendor:Product ID) to have a separate keyboard dedicated to macros.

## Simple Keyboard Setup

Remap buttons to normal keyboard keys.

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
will modify in a moment to contain your device's USB information to identify it.


`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*vYYYYpXXXXe*
```


### 2. Use `lsusb` to find your device USB device IDs

Run the command `lsusb` and look for a name that describes the device you are
trying to setup. For example, here is the line from the output that is for my
footpedal:

`Bus 003 Device 011: ID 05f3:00ff PI Engineering, Inc. VEC Footpedal`

You need the hexadecimal numbers that are in the position of the  "05f3:00ff"
from the example.

If you can't determine which device is yours in the list you can find it by
looking for the difference of the output before and after plugging your device
in. Here are the commands you would run to do this:

```
# Have device unplugged
lsusb > /tmp/lsusb
# Plug the device in
lsusb > /tmp/lsusb2
diff /tmp/lsusb /tmp/lsusb2
```
*The `#` character means "The text after this is a comment". You don't need to type
these line in.*

*The `>` character means "Send the output from the left to the right instead of
printing it". On the right we are saving the output to a file in the `/tmp`
folder. These will be lost after restarting.*


### 3. Update udev file with USB IDs

The two hexidecimal numbers we got with `lsusb` "05f3:00ff" itentify a specific
product by a specific manufacturer. In this case the manufacturer or "Vendor" ID
is `05f3` and the "Product" ID is `00ff`.

You will add these numbers to the `/etc/udev/hwdb.d/70-keyboard.hwdb` file you
created earlier. Remember you can edit it with
`sudo nano /etc/udev/hwdb.d/70-keyboard.hwdb`In the file you will replace the
"YYYY" after the "*v*" with your "*Vendor*" ID and the "XXXX" after the "*p*"
with your "*Product*" ID. There are other options that can be changed in this
line that we don't need right now. These are already set to match everything
with the "\*" wildcard character.

*udev requires that your vendor and product IDs be uppercase in this file*

`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*v05F3p00FFe*
```


### 4. Find input event for device
To read the data from the input device we need to know what the virtual
interface is. Linux assigns input devices an "event" file access point in `/dev/input`.
To determine which input event is your device easily, you can see if your device
has a more friendly named access point by running this command
`ls -l /dev/input/by-id`.

Example output for my footpedal:
`lrwxrwxrwx 1 root root 9 Aug 20 15:46 usb-VEC_VEC_USB_Footpedal-event-if00 -> ../event5`

In this case my device is `/dev/input/event5`.

*If you wanted to you could also just use the event file in the `by-id` folder.*

If your device isn't listed in the `by-id` folder then you can try to find the
USB IDs in the output of this more complicated command to match to your even
file: `udevadm trigger --verbose --sysname-match="event*"`


### 5. Get the button codes for your device
We need to find the scan codes for your device. These are the values that
indicate which button was pressed. Now that you have your device's event
interface you can run the follwing command to see an output of any button
presses: `sudo evtest /dev/input/event#`

*Replace the "#" character with your event number*

While that command is running you need to press every button you want to map
once to print the scan codes. Here is what the output of my footpedal looks
like:

```
Event: time 1534811478.747420, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90001
Event: time 1534811478.747420, type 1 (EV_KEY), code 256 (BTN_0), value 1
Event: time 1534811478.747420, -------------- SYN_REPORT ------------
Event: time 1534811478.755413, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90001
Event: time 1534811478.755413, type 1 (EV_KEY), code 256 (BTN_0), value 0
Event: time 1534811478.755413, -------------- SYN_REPORT ------------
Event: time 1534811485.083432, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90002
Event: time 1534811485.083432, type 1 (EV_KEY), code 256 (BTN_0), value 1
Event: time 1534811485.083432, -------------- SYN_REPORT ------------
Event: time 1534811485.403417, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90002
Event: time 1534811485.403417, type 1 (EV_KEY), code 256 (BTN_0), value 0
Event: time 1534811485.403417, -------------- SYN_REPORT ------------
Event: time 1534811492.659436, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90003
Event: time 1534811492.659436, type 1 (EV_KEY), code 256 (BTN_0), value 1
Event: time 1534811492.659436, -------------- SYN_REPORT ------------
Event: time 1534811492.787439, type 4 (EV_MSC), code 4 (MSC_SCAN), value 90003
Event: time 1534811492.787439, type 1 (EV_KEY), code 256 (BTN_0), value 0
Event: time 1534811492.787439, -------------- SYN_REPORT ------------
```

It prints once when you depress the button and again when you release the
button. The scancodes you need are at the end of the line with "type 4" after
the time. In this case my scan codes are "90001" , "90002" , and "90003".


### 6. Add the scan codes to udev file

You will now add your device's scancodes to the udev file. Open it back up with
`sudo nano /etc/udev/hwdb.d/70-keyboard.hwdb` and add more lines to the bottom
of the file that start with " KEYBOARD\_KEY\_" and end with your scancodes.

*You can also use `#` for comments in the udev file if you want to leave a note
to explain which scancode is for each button*

`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*v05F3p00FFe*
# left
 KEYBOARD_KEY_90001
# middle
 KEYBOARD_KEY_90002
# right
 KEYBOARD_KEY_90003
```

*Note: You must have the space in front of the lines with the scancodes*


### 7. Add keys to output to udev file
From here you can add the names of the keys you want your device to press
instead. You can go [here](https://github.com/xkbcommon/libxkbcommon/blob/master/test/evdev-scancodes.h)
for a full list of all keys and buttons you can map your device to use.

For keys you can omit the "KEY\_" from the name of value when you use it in the
udev file. If you use any "BTN\_" values you need the first part. The names of
the keys or btns you add also need to be lowercase. For the keys you want to set
add "=" followed by the key to the end of each scancode line to set it to be
equal to that key.

Here is how my file looks like when setup to use the pedals for movement in a
game:

`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*v05F3p00FFe*
# left
 KEYBOARD_KEY_90001=a
# middle
 KEYBOARD_KEY_90002=w
# right
 KEYBOARD_KEY_90003=d
 ```


### 8. Reload the udev configurations

That's everything you need to do to make the device output normal key presses.
To update the loaded configurations without restarting you can run the following
two commands:

```
sudo systemd-hwdb update
sudo udevadm trigger --verbose --sysname-match="event*"
```



## Complex keyboard setup

This is how you can rebind the buttons to key combinations or to run
commands/scripts. This can also be done with a standard keyboard.


### 0. Complete simple setup

If you want to do this with a custom device then you will need it to be able to
register normal key presses.

### 1. Change keys to unusual keys

We're going to bind keys to trigger commands. This is not specific to one device
like the key rebinding you did with udev. So you don't really want to use keys
you're likely going to need to press. For your custom device you can take a
shortcut and use keys that don't exist on most keyboards now. There are F-keys
that go beyond 1-12, all the way up to f-24 in fact. You can use those as
virtual keys for our shortcuts to eliminate the possibility of overriding a key
you may need later.

*f13 and f15 should probably be avoided due to tab changing shortcuts in
some browsers*

I'm going to use F16-18 for my footpedal.

`/etc/udev/hwdb.d/70-keyboard.hwdb`
```
evdev:input:b*v05F3p00FFe*
# left
 KEYBOARD_KEY_90001=f16
# middle
 KEYBOARD_KEY_90002=f17
# right
 KEYBOARD_KEY_90003=f18
 ```

### 2. Make key press run commands

I'm going to cover two different ways of doing this that each have pros and
cons. They will both run commands after reading a key press, but how they do it
is different.

#### A. `xinput test` / non-blocking

We can directly read changes in the key state using `xinput`. With that we can
watch for the key presses and respond to them in a `bash` script. This may be a
bit more confusing than option B but will allow you more control. First you will
need to X input ID for your device (no relation to Microsoft's XInput for game
controllers). You can find that with `xinput list`. Here is how my pedals show
up in the full output:
```
$ xinput list
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ Wacom Intuos4 4x6 Pad pad                 id=9    [slave  pointer  (2)]
⎜   ↳ Wacom Intuos4 4x6 Pen stylus              id=8    [slave  pointer  (2)]
⎜   ↳ Wacom Intuos4 4x6 Pen eraser              id=11   [slave  pointer  (2)]
⎜   ↳ Wacom Intuos4 4x6 Pen cursor              id=12   [slave  pointer  (2)]
⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
    ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    ↳ Power Button                              id=6    [slave  keyboard (3)]
    ↳ Power Button                              id=7    [slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard              id=10   [slave  keyboard (3)]
    ↳ VEC VEC USB Footpedal                     id=13   [slave  keyboard (3)]
```

So my pedals are `13`.

This device ID may change though. So really we need to find this number
automatically. So we going to get a bit more complicated here. This is a single
line of bash that will get the id for my pedals:

`xinput list | grep VEC | awk '{print $6}' | sed 's/id=//g'`



```bash
#!/bin/bash
#xinput list for id
xinput test 15 | while read in ; do
  [[ $in = "key press   194" ]] && notify-send left
  [[ $in = "key press   194" ]] && notify-send middle
  [[ $in = "key press   194" ]] && notify-send right
  echo "nothing"
done
```

#### B. `xbindkeys` / blocking

Using `xbindkeys` with a configuration file will block key presses from getting
through(in theory). You will need a configuration file in your home directory.
After you have installed `xbindkeys`(`sudo apt install xbindkeys`) you can run
`xbindkeys -d > ~/.xbindkeysrc` to have it create a template file that details
how to use it. Simply put, you need a line with the command you want to run
followed by a line with the key press that runs it. `xbindkeys` is more geared
towards complex shortcuts that use key modifiers and can be confusing. It can be
easiest to just use the scancode for your key. (Which you can get from `xinput
test #` like in the A option above). Then you can just use "c:###" as your key
`xbindkeys` will respond to.

Here is an example setup for my pedals that lets check it's working.

`~/.xbindkeysrc`
```
"notify-send left"
   c:194

"notify-send middle"
   c:195

"notify-send right"
   c:196
```

*`notify-send` is a command to let you send a message as a notification in your
Desktop Envoirnment*


3. Create scripts

either make one script per button or a single script with a button parameter.


