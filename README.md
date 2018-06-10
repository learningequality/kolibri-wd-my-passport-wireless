# kolibri-wd-my-passport-wireless

Scripts and resources for running Kolibri on WD My Passport Wireless devices

## Building Python

On Ubuntu (tested on 16.04) you can run `./buildpython.sh` to cross-compile and package up Python with the necessary dependencies (SQLite, OpenSSL, and ZLib). Or, you can just use the pre-built copy of python.zip checked into this repository.

## Installing onto the WD My Passport Wireless Pro

- Connect to the wifi hotspot for your drive (and stay connected to it for the duration of the following steps).

- Load the device's admin interface at http://192.168.60.1, and go to Wi-Fi, selecting and connecting to a wireless network with Internet in the righthand box (the drive will need to be connected to the Internet in order to download Kolibri).

- Now, in the same interface, go to Admin -> Access -> SSH, and turn the switch from Off to On, and then confirm the prompts (choosing a password).

- It'll make things easier if you use [`ssh-copy-id`](https://www.ssh.com/ssh/copy-id) to add your SSH key to the device, so you won't need to repeatedly enter your password (i.e. run something like `ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.60.1`).

- Run `./install.sh` to install Python and Kolibri onto the drive. This will take some time. After, turn off the device (may hang, so you may need to force-reboot it), and turn it on again. If both LEDs blink repeatedly, you may need to do a soft reset (hold down both buttons) and then do the device setup again (but not install.sh).

## Accessing Kolibri

- A little while after booting up, Kolibri should be running and available at http://192.168.60.1:8080 for any device connected to the drive's wifi hotspot. The drive will need to be connected to the Internet via the Wi-Fi settings in the admin page, in order to download content.