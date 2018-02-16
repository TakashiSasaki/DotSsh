.PHONY: all

cacert2.pem:
	openssl req -new -x509 -key private/cakey.pem -out cacert2.pem -config openssl.cnf

cacert2.pem-view: cacert2.pem
	openssl x509 -in cacert2.pem -text
