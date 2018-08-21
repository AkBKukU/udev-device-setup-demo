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
`ls -l /dev/input`.

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

 - Option **A** is `xinput test` which will require you to have a script to
 handle reading all the button presses. This could be used for creating unique
 commands for multiple devices using the same keys.
 - Option **B** is `xbindkeys` that will need to be installed and running. The
 setup is easier, but the key presses are read from all devices.

There could technically be an option **C** that uses `evtest` in nearly the
same way as option **A** uses `xinput test`. That wouldn't require a GUI/X
Server to be loaded. It would also bypass the need for the udev files. But the
setup for that would require a bit more string manipulation than I want to get
into explaining here.

#### A. `xinput test` / non-blocking

We can directly read changes in the key state using `xinput`. With that we can
watch for the key presses and respond to them in a `bash` script. This may be a
bit more confusing than option B but will allow you more control. First you will
need to know the X input ID for your device (no relation to Microsoft's XInput
for game controllers). You can find that with `xinput list`. Here is how my
pedals show up in the full output:
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

There is a lot going here so let's break it down:

 - First `|` is used to take the output from the left command and use it as the input
 for the right command.
 - `grep` is a command for filtering  data. We're just looking for any rows that
 would match our device. So I'm searching for "VEC". You will need something
 unique to search for your device.
 - `awk` is really complex and does a lot. It's basically it's own scripting
 language. We're just using it to print data from the 6th column.
 - `sed` is a command most used for running regular expressions. In this case we
 are using a **s**ubstitute to replace "id=" with nothing. At the end there is a
 `g` which is the global option. It's not needed in this case. The "/"
 characters are use to seperate or more acurately deliniate the command, serach
 string, replace string, and options.

With the ID we can read the key presses now. The command `xinput test #` will
tell you when each key scancode is pressed and released. Here is what the output
from the command looks like for pushing all the buttons on my pedals:

```
key press   194
key release 194
key press   195
key release 195
key press   196
key release 196
```

Now we need to read those lines and respond when a new line matches one of the
buttons being pressed. It will be better to just show the complete script from
here. So this is how my pedals will be read:

`keyListen.sh`
```bash
#!/bin/bash
id="$(xinput list | grep VEC | awk '{print $6}' | sed 's/id=//g')"
xinput test $id | while read in ; do
  [[ $in = "key press   194" ]] && notify-send left
  [[ $in = "key press   195" ]] && notify-send middle
  [[ $in = "key press   196" ]] && notify-send right
  echo "nothing"
done
```

Let's go over the new stuff in this one:

 - `#!/bin/bash` This is a line that tells `bash` to run this script through
 `bash`
 - `id="$(stuff)"` we're wrapping this around the part that gets the X input id
 to save it as the variable id.
 - `xinput test $id | while read in ; do` First this just the key press output
 command from before using the id variable. `while read` takes the lines from
 the output and puts them in the variable `in`. `;` marks the end of a command.
 `do` means that all command after this only run when the `in` variable has
 data.
 -  `[[ $in = "key press   ###" ]] &&` inside the `[[` `]]` is a an expression
 checking if the `$in` variable matches the output of the `xinput test` for a
 key scancode we want to perform an action for. The `&&` means that if the
 expression evaluates to 0 it runs the next command.
 - `notify-send` is a command to let you send a message as a notification in your
Desktop Envoirnment. This would be replaced with the command you want to run
after the button is pressed.
 - `done` marks the end of the `while` loop. In this script, nothing after
 `done` will be run.


#### B. `xbindkeys` / blocking

Using `xbindkeys` with a configuration file will block configured key presses
from getting through(in theory). You will need a configuration file in your
home directory. After you have installed `xbindkeys`(`sudo apt install
xbindkeys`) you can run `xbindkeys -d > ~/.xbindkeysrc` to have it create a
template file that details how to use it. Simply put, you need a line with the
command you want to run followed by a line with the key press that runs it.
`xbindkeys` is more geared towards complex shortcuts that use key modifiers and
can be confusing. It can be easiest to just use the scancode for your key.
(Which you can get from `xinput test #` like in the A option above). Then you
can just use "c:###" as your key `xbindkeys` will respond to.

Here is an example setup for my pedals that lets us check it's working.

`~/.xbindkeysrc`
```
"notify-send left"
   c:194

"notify-send middle"
   c:195

"notify-send right"
   c:196
```

#### Both

In order for your script or `xbindkeys` to read key presses it needs to be running. You can launch them manually if you want to, but if you want to automate it [here](https://www.cyberciti.biz/tips/linux-desktop-auto-start-or-launch-programs.html) is a guide that covers Gnome and KDE.

### 3. Create scripts

Now that you have some way to run a command from a button press you can either
make one bash script per button or a single script that has a button parameter. If you know how to make one script that reads all the button you could know how to make multiple scripts for one button. So I will cover the parameter method. I'm going to start off by making a script called `inputAction.sh` that will accept the button presses. You can create the file anywhere you want, but when you run it you will need to specific where the file is with the complete path. So if you just have it in the root of your users folder it would be `/home/$USE/home/$USER/inputAction.sh`. I will use that as an example location for this tutorial. Let's start writing the file by first adding the bash script line:

`inputAction.sh`
```bash
#!/bin/bash
```

Just to get you more familiar with scripting let's a add a line to print something to the terminal with `echo`:

`inputAction.sh`
```bash
#!/bin/bash

echo "test"
```

Now if the script is run it will print "test". But first to make it allowed to be run you need to mark it as executable. The command `chmod +x inputAction.sh` run in the same directory as the script will mark it as executable. There is more to linux permissions like that, but it is beyond the scope of this document. Next you can run the command, let's do it with the full path to make sure it works. All you need to do it type the location of the file as a command and it will run `/home/$USE/home/$USER/inputAction.sh`. That should have output "test" after it was run.

Now let's remove the test command and add the ability to do different things based on a parameter:

`inputAction.sh`
```bash
#!/bin/bash

BUTTON=$1

if [[ $BUTTON = "left" ]] ; then
	echo "left pressed"
fi

if [[ $BUTTON = "middle" ]] ; then
	echo "middle pressed"
fi

if [[ $BUTTON = "right" ]] ; then
	echo "right pressed"
fi

```
Ok, let's look at the new stuff again:

 - `BUTTON=$1` is setting the variable BUTTON to be the value of the first
 parameter which is read with `$1`
 - `if [[ $BUTTON = "something" ]] ; then` This says `if` the expression returns
 0 `then` run the next lines. `if` and `then` are separate commands that are just
 being put on the same line with `;`. `"something"` is the name of the button
 you want to run the command(s) on the next line(s). You can set this to any
 name you want, but I would avoid spaces or special characters.
 - `fi` marks the end of the commands to be run after `then`.

*Unlike most programming lanuages, in bash a "successful" or "true" statement
is `0` instead of `1` or any other number. This is becase bash is meant
primarily as a system shell for running commands. When a command is run
successfully it returns a `0` to show there were no errors. If any other number
is returned it means the command did not run properly and the number relates to
the type of error it had.*

To use your new script you will run it with the name of the button you want the
action for after the location of the script. For my script I used the button
names `left`, `middle`, and `right` So if I run the command with any of those
after the script location it will run one of the `echo` commands.

```
$ /home/$USER/inputAction.sh left
left pressed
```

```
$ /home/$USER/inputAction.sh middle
middle pressed
```

```
$ /home/$USER/inputAction.sh right
right pressed
```

Now you can use your script as a command in the method for reading the button
presses. So for me the `left` button in those would look like this:

Option **A**
```bash
  [[ $in = "key press   194" ]] && /home/$USER/inputAction.sh left
```

Option **B**
```
"/home/$USER/inputAction.sh left"
   c:194
```

If all you need to do is run commands from button presses you should have
everything you need now.

### 4. Simulate complex key presses

If you need have your buttons press a key combination such as `ctrl + c` then
you will want to use another program called `xdotool`. You will need to install
it (`sudo apt install xdotool`) before you can try it out. Once it's installed
you can get a list of all the keys you can use with the command `xmodmap -pke`.

To use `xdotool` to press a specific key combination you run the command like
this: `xdotool key ctrl+c`(no spaces around key names). If you need to hold a key you can use `keydown`
and `keyup` instead of `key`. You can also have `xdotool` type out a phrase:
`xdotool type "this is some text"`.

Here is an example configuration of Option **A** key reading with shortcuts for
Blender:

`inputAction.sh`
```bash
#!/bin/bash
# Blender control example
BUTTON=$1

if [[ $BUTTON = "left" ]] ; then
	xdotool key Next
fi

if [[ $BUTTON = "middle" ]] ; then
	xdotool key alt+a
fi

if [[ $BUTTON = "right" ]] ; then
	xdotool key Prior
fi
```

## Wrap up

That's pretty much it! There are a few honorable mention features I want to add:

 - `xdotool getwindowfocus getwindowname` Will return the name of the current
 window. You can use this to change which keys to press for a specific program.
 - You can create a [systemd](https://www.devdungeon.com/content/creating-systemd-service-files)
 service file to have your `keyListen.sh` file be loaded at startup. You'll want
 to make sure it starts [after](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Automatic%20Dependencies)
 the X Server loads though.
 - `xdotool` can also control the cursor.
 - Game controllers and joysticks can be used as well, but not in the same way.
 `jstest` is what you want for that.


