.PHONY: all

tsakey.pem:
	openssl genrsa -out tsakey.pem 2048

view-tsakey.pem:
	openssl rsa -in tsakey.pem -text | less

view-cakey.pem:
	openssl rsa -in cakey.pem -text | less

