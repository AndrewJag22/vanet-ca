#The files are stored in /etc/certs
SUBINFO=/etc/certs/subjectinfo
PASSFILE=/etc/certs/passwordfile
CAKEY=/etc/certs/ca.key
CACERT=/etc/certs/ca.crt

sudo mkdir /etc/certs

#Creates the file containing the password for generating key and certificate
echo "password" | sudo tee -a $PASSFILE > /dev/null

#Creates the file containing the Certification Authority info for generating key and certificate
echo "UK,Manchester,Greater,Manchester,CAserver,server,CA" | sudo tee -a $SUBINFO > /dev/null

#Loops through created subjectinfo file and assigns each value to a variable
while IFS="," read -r f1 f2 f3 f4 f5 f6
do
    CO="$f1"
    ST="$f2"
    LO="$f3"
    OR="$f4"
    OU="$f5"
    CN="$f6"
done < "$SUBINFO"

#Generates Certificate Authority key and certificate
openssl req -new -x509 -days 365 -extensions v3_ca -keyout $CAKEY -passout file:$PASSFILE -subj "/C=$CO/ST=$ST/L=$LO/O=$OR/OU=$OU/CN=$CN" -out $CACERT

#Copies the ca certificate to folder for clients to download
cp /etc/certs/ca.crt /srv/sftp/ca.crt
