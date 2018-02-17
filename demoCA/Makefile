.PHONY: all clean view-cacert2.pem

clean:
	rm -f cacert2.pem

cacert2.pem:
	openssl req -new -x509 -key private/cakey.pem -out cacert2.pem -config self.cnf ;\
		find . -name "cacert2.pem" -size 0 -exec rm -f {} \;

view-cacert2.pem: cacert2.pem
	openssl x509 -in cacert2.pem -text | less
