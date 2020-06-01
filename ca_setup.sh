# Creating sftp user profile and sftp folders
useradd -m vanetclients -p vanetclients
usermod -s /usr/bin/nologin vanetclients
groupadd sftpgroup
usermod -a -G sftpgroup vanetclients
mkdir /srv/sftp/
mkdir /srv/sftp/incoming_requests
mkdir /srv/sftp/outgoing_certificates
chgrp sftpgroup /srv/sftp/
chgrp sftpgroup /srv/sftp/incoming_requests
chgrp sftpgroup /srv/sftp/outgoing_certificates
chmod 750 /srv/sftp/
chgrp 770 /srv/sftp/incoming_requests
chgrp 770 /srv/sftp/outgoing_certificates

sed -i 's|Subsystem sftp.*|#Subsystem sftp /usr/lib/openssh/sftp-server\nSubsystem sftp internal-sftp|' /etc/ssh/sshd_config
echo -e "\n#sftp server setup and information\nMatch group sftpgroup\n    ForceCommand internal-sftp\n    X11Forwarding no\n    AllowTcpForwarding no\n    ChrootDirectory /srv/sftp/" >> /etc/ssh/sshd_config

# Makes the key generator script executable and then runs it
chmod +x keycertgenerator.sh
./keycertgenerator.sh

# Installs pyinotify for the service to use
sudo apt-get install -y python3-pyinotify openssh-server openssh-sftp-server

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