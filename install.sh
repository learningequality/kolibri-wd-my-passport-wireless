# copy to the device, and unpack
ssh root@192.168.60.1 "mkdir -p /DataVolume/python/"
scp python.zip root@192.168.60.1:/DataVolume/python/
ssh root@192.168.60.1 "cd /DataVolume/python/ && unzip python.zip"
ssh root@192.168.60.1 "curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py --insecure && PYTHONHOME=/DataVolume/python/ /DataVolume/python/bin/python get-pip.py"
ssh root@192.168.60.1 "mkdir -p /DataVolume/tmp && umount /tmp && ln -s /DataVolume/tmp /tmp"
ssh root@192.168.60.1 "PYTHONHOME=/DataVolume/python/ /DataVolume/python/bin/pip install kolibri"
scp kolibri.service root@192.168.60.1:/etc/systemd/system/
ssh root@192.168.60.1 "systemctl enable kolibri.service"

echo "Please turn off the WD My Passport Wireless Pro and then turn it back on again..."