#!/bin/bash
  
DOMAIN=$1
FILENM=star.${DOMAIN}

cat <<- EOF > ${FILENM}.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
countryName             = KR
stateOrProvinceName     = Seoul
localityName            = Seonyudo
organizationName        = MK
organizationalUnitName  = Dev.Team
CN                      = ${DOMAIN}
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.${DOMAIN}
EOF

# crt 생성
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ${FILENM}.key -out ${FILENM}.crt -sha256 -config ${FILENM}.cnf
