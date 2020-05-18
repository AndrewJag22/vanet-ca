# Runs key generator
./keycertgenerator.py

# Copies client certificate generator into /etc/certs folder
cp hehe.py /etc/certs/clientcertgenerator.py

# Creates a cron job for the client certificate generator script to run whenever the server is put on
crontab -l > current_cron
cat >> current_cron << EOF
@reboot python3 clientcertgenerator.py
EOF
crontab < current_cron
rm -f current_cron