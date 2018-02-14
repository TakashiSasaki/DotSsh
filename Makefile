.PHONY: all test clean

all: decrypt verify

test:
	echo $(USER); echo $(shell hostname)

clean:
	rm -f hello.p7m hello.p7s

id_rsa.req:
	openssl req -new -key id_rsa -subj "/C=JP/ST=Ehime/O=Takashi SASAKI Things/O=SSH keys/OU=$(shell hostname)/OU=Ubuntu on Windows/CN=$(USER)/emailAddress=takashi316@gmail.com" -out id_rsa.req

id_rsa.pem:
	openssl ca -in id_rsa.req -out id_rsa.pem -days 36500

hello.p7m: hello.txt id_rsa.pem
	openssl cms -encrypt -in hello.txt -out hello.p7m id_rsa.pem 

cmsout: hello.p7m
	openssl cms -cmsout -print -in hello.p7m -certsout hello.certs

decrypt: hello.p7m
	openssl cms -decrypt -in hello.p7m -inkey id_rsa

hello.p7s: hello.txt id_rsa.pem  id_rsa
	openssl smime -sign -in hello.txt -inkey id_rsa -signer id_rsa.pem -out hello.p7s

verify: id_rsa.pem hello.p7s
	openssl smime -verify -in hello.p7s -CAfile demoCA/cacert.pem  

