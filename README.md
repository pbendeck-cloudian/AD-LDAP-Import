# AD-LDAP-Import
1. This script allows a Cloudian administrator to import SSL certificates and to leverage LDAPS via port 636.
2. The script will request the end-user to input the following variables:
```
--> Enter the FQDN of the AD/LDAP server that you want to import the certificate from: WinSrv2016VM01.iphilsanity.com
--> Enter the certificate name for WinSrv2016VM01.iphilsanity.com: WinSrv2016VM01
--> Enter the alias for WinSrv2016VM01 for WinSrv2016VM01.iphilsanity.com: WinSrv2016VM01
```
3. After the FQDN of the AD server has been inputted, the script will import the certificate to the Java keystore on all nodes.
4. It will then restart the following services – HyperStore, S3 and CMC.

Script Example
![AD_LDAP_Script_Demo](https://user-images.githubusercontent.com/102058632/169559838-e5612663-2c5b-48b1-ab7c-865ca706fd7f.gif)

CMC Configuration Example
![CMC_AD_LDAP_Script_Demo](https://user-images.githubusercontent.com/102058632/171273860-99492c13-23c1-45b7-9a86-8dc06524db2c.gif)
