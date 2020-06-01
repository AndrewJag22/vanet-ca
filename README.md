# VANET-CA

This repository is for the Certification Authority that would be used in the VANET.

Two files are created using the code here which should be changed accordingly: The password file and the subjectinfo file

The password file contains the password to be used for generating certification authority key and certificate which should be changed.

The subjectinfo file contains the information that would normally be inputted using the openssl command. The parameters are separated using commas.
The format is as follows: Country,State,Locality,OrganizationName,OrganizationalUnitName,CommonName

An example is given in the created subjectinfo file.

On downloading, the ca_setup.sh file should be run as root using command:

    sudo bash ./ca_setup.sh