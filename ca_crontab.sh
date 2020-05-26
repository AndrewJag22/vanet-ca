# Runs key generator
./keycertgenerator.sh

# Copies client certificate generator into /etc/certs folder
cp clientcertgenerator.py /etc/certs/clientcertgenerator.py
cp keycertgenerator.sh /etc/certs/keycertgenerator.sh

# Creates a cron job for the client certificate generator script to run whenever the server is put on
crontab -l > current_cron
cat >> current_cron << EOF
@reboot python3 /etc/certs/clientcertgenerator.py
EOF
crontab < current_cron
rm -f current_cron

python3 /etc/certs/clientcertgenerator.py