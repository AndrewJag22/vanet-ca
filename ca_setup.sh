# Installs packages and dependencies for the service to use
sudo apt-get install -y python3-pyinotify openssh-server openssh-sftp-server expect

# Creating sftp user profile and sftp folders
useradd -m vanetclients
usermod -s /usr/bin/nologin vanetclients
chmod +x user_pass.exp
./user_pass.exp
groupadd sftpgroup
usermod -a -G sftpgroup vanetclients
mkdir /srv/sftp/
mkdir /srv/sftp/incoming_requests
mkdir /srv/sftp/outgoing_certificates
chgrp sftpgroup /srv/sftp/
chgrp sftpgroup /srv/sftp/incoming_requests
chgrp sftpgroup /srv/sftp/outgoing_certificates
chmod 750 /srv/sftp/
chmod 770 /srv/sftp/incoming_requests
chmod 770 /srv/sftp/outgoing_certificates

sed -i 's|Subsystem sftp.*|#Subsystem sftp /usr/lib/openssh/sftp-server\nSubsystem sftp internal-sftp|' /etc/ssh/sshd_config
echo -e "\n#sftp server setup and information\nMatch group sftpgroup\n\tForceCommand internal-sftp\n\tX11Forwarding no\n\tAllowTcpForwarding no\n\tChrootDirectory /srv/sftp/" >> /etc/ssh/sshd_config

# Makes the key generator script executable and then runs it
chmod +x keycertgenerator.sh
./keycertgenerator.sh

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