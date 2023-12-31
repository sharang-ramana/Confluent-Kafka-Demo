#!/bin/sh

mkdir /var/lib/secret

echo "==================================================================================="
echo "==== Kerberos KDC and Kadmin ======================================================"
KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM

echo "REALM: $REALM"
echo "KADMIN_PRINCIPAL_FULL: $KADMIN_PRINCIPAL_FULL"
echo "KADMIN_PASSWORD: $KADMIN_PASSWORD"

echo "==================================================================================="
echo "==== /etc/krb5.conf ==============================================================="
KDC_KADMIN_SERVER=$(hostname -f)
tee /etc/krb5.conf <<EOF
[libdefaults]
	default_realm = $REALM

[realms]
	$REALM = {
		kdc_ports = 88,750
		kadmind_port = 749
		kdc = $KDC_KADMIN_SERVER
		admin_server = $KDC_KADMIN_SERVER
	}
EOF

echo "==================================================================================="
echo "==== /etc/krb5kdc/kdc.conf ========================================================"
tee /etc/krb5kdc/kdc.conf <<EOF
[realms]
	$REALM = {
		acl_file = /etc/krb5kdc/kadm5.acl
		max_renewable_life = 7d 0h 0m 0s
		supported_enctypes = $SUPPORTED_ENCRYPTION_TYPES
		default_principal_flags = +preauth
	}
[logging]
	kdc = FILE:/var/log/krb5kdc.log
	admin_server = FILE:/var/log/kadmin.log
  default = FILE:/var/log/krb5lib.log
EOF

echo "==================================================================================="
echo "==== /etc/krb5kdc/kadm5.acl ======================================================="
tee /etc/krb5kdc/kadm5.acl <<EOF
$KADMIN_PRINCIPAL_FULL *
noPermissions@$REALM X
EOF

echo "==================================================================================="
echo "==== Creating realm ==============================================================="
MASTER_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
# This command also starts the krb5-kdc and krb5-admin-server services
krb5_newrealm <<EOF
$MASTER_PASSWORD
$MASTER_PASSWORD
EOF

echo "==================================================================================="
echo "==== Creating default principals in the acl ======================================="
echo "Adding $KADMIN_PRINCIPAL principal"
kadmin.local -q "delete_principal -force $KADMIN_PRINCIPAL_FULL"
kadmin.local -q "addprinc -pw $KADMIN_PASSWORD $KADMIN_PRINCIPAL_FULL"

echo "Adding noPermissions principal"
kadmin.local -q "delete_principal -force noPermissions@$REALM"
kadmin.local -q "addprinc -pw $KADMIN_PASSWORD noPermissions@$REALM"

echo "Starting krb5kdc"
krb5kdc

echo "Starting kadmind"
kadmind -nofork

echo "Initialization complete"