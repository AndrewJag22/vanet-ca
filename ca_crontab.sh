# Makes the key generator script executable and then runs it
chmod +x keycertgenerator.sh
./keycertgenerator.sh

# Installs pyinotify for the service to use
sudo apt-get install python3-pyinotify

# Copies client certificate generator into /etc/certs folder
cp clientcertgenerator.py /etc/certs/clientcertgenerator.py
cp keycertgenerator.sh /etc/certs/keycertgenerator.sh

# Copies client certificate generator service to /lib/systemd/system folder
cp clientcertgenerator.service /lib/systemd/system/clientcertgenerator.service

# Creates a cron job for the client certificate generator service to run whenever the server is put on
crontab -l > current_cron
cat >> current_cron << EOF
@reboot systemctl start clientcertgenerator.service
EOF
crontab < current_cron
rm -f current_cron

systemctl daemon-reload
systemctl enable clientcertgenerator.service
systemctl start clientcertgenerator.service