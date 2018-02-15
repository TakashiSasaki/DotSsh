.PHONY: all test clean fingerprint

all: decrypt verify hello.decrypted

test:
	echo $(USER); echo $(shell hostname)

clean:
	rm -f hello.p7m hello.p7s hello.encrypted hello.decrypted id_rsa.req 

id_rsa.req: id_rsa
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

hello.encrypted: id_rsa.pub hello.txt
	openssl rsautl -encrypt -certin -inkey id_rsa.pem -in hello.txt -out hello.encrypted

hello.decrypted: id_rsa hello.encrypted
	openssl rsautl -decrypt -inkey id_rsa -in hello.encrypted -out hello.decrypted

fingerprint: id_rsa
	ssh-keygen -l -E MD5 -f id_rsa ;\
	ssh-keygen -l -E SHA1 -f id_rsa ;\
	ssh-keygen -l -E SHA256 -f id_rsa ;\
	ssh-keygen -l -E SHA384 -f id_rsa ;\
	ssh-keygen -l -E SHA512 -f id_rsa 

