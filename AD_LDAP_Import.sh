#!/bin/bash

INSTALL_SCRIPT=$(grep installscript /opt/cloudian/conf/cloudianservicemap.json | awk '{print $8}' | cut -d'"' -f2)
STAGING_DIR=$(dirname ${INSTALL_SCRIPT})
SSH_KEY=${STAGING_DIR}/cloudian-installation-key
HOSTS=$(cat $STAGING_DIR/hosts.cloudian | awk {'print $2'})
JDK=$(grep cloudian_java_home $STAGING_DIR/CloudianInstallConfiguration.txt | cut -d '=' -f2)
CMC=$(grep cmc_domain $STAGING_DIR/CloudianInstallConfiguration.txt | cut -d'=' -f2)

echo "######################################################################################"
echo "# This is a script to input all the required variables to import an SSL certificate  #"
echo "#                                                                                    #"
echo "# Phil Bendeck | Cloudian Solutions Architect, Strategic Alliances ©                 #"
echo "#                                                                                    #"
echo "######################################################################################"
echo

echo "--> Welcome to this simple script to import a self-signed certificate into the Cloudian HyperStore Cluster."
echo "--> This script is automated to examine hosts.cloudian and import the SSL certificate to all Cloudian HyperStore Nodes"
echo "--> It will automatically use the keystore password [changeit] with no prompt for the user."
echo "--> After the certificate has been imported, it will restart the Hyperstore and S3 service on all nodes."

while true
do
read -r -p "--> Would you like to import an AD/LDAP SSL certificate [Yes or No]: " input

case $input in
     [yY][eE][sS]|[yY])
# Input Variables [fqdn, certname, alias]
echo "--> The option Yes has been selected by $USER"
read -p "--> Enter the FQDN of the AD/LDAP server that you want to import the certificate from: " fqdn
echo "--> FQDN Entered = [$fqdn]"
read -p "--> Enter the certificate name for $fqdn: " certname
echo "--> Certificate Name Entered = [$certname.crt]"
read -p "--> Enter the alias for $certname for $fqdn: " alias
echo "--> Alias Name Entered = [$alias]"

break
;;
     [nN][oO]|[nN])
echo "--> No has been selected; exiting script."
exit
        ;;
     *)
echo "Invalid input..."
 ;;
esac
done

for i in $HOSTS;do echo "--> $i";
    ssh -i $SSH_KEY $i "cd $HOME/CloudianPackages && openssl s_client -connect $fqdn:636 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $certname.crt";
    ssh -i $SSH_KEY $i "cd $HOME/CloudianPackages && $JDK/bin/keytool -import -alias $alias -keystore $JDK/lib/security/cacerts -file $certname.crt -storepass changeit -noprompt";
done

echo "--> Removing Certfile $certname.crt"
rm -fv $HOME/CloudianPackages/$certname.crt

echo 
printf "The SSL AD/LDAP certificate installed on:\n$HOSTS"
echo
printf "Restarting Hyperstore, S3, CMC services on:\n$HOSTS"
cd $STAGING_DIR && ./cloudianService.sh -s hyperstore,s3,cmc restart

echo
echo "--> Please login to https://$CMC:8443 and continue the configuration for ldaps://$fqdn:636"
