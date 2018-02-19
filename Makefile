ifndef HOSTNAME
	export HOSTNAME=$(shell hostname)
endif

ifndef USER
	export USER=$(shell whoami)
endif

.PHONY: all test clean fingerprint

all: decrypt verify hello.decrypted view-id_rsa2.pem view-id_rsa2.req

test:
	echo $(USER); echo $(shell hostname)

clean:
	rm -f hello.p7m hello.p7s hello.encrypted hello.decrypted hello.tsq hello.tsr

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

id_rsa.req: id_rsa
	openssl req -new -key id_rsa -subj "/C=JP/ST=Ehime/O=Takashi SASAKI Things/O=SPHERE/OU=$(shell hostname)/OU=Ubuntu on Windows/CN=$(USER)/emailAddress=takashi316@gmail.com" -out id_rsa.req

view-id_rsa.req: id_rsa.req
	openssl req -in id_rsa.req -text | less

id_rsa.pem: 
	openssl ca -in id_rsa.req -out id_rsa.pem -days 36500

view-id_rsa.pem:
	openssl x509 -in id_rsa.pem -text | less

id_rsa2.req: id_rsa req.cnf Makefile
	openssl req -new -key id_rsa -config req.cnf -out id_rsa2.req

view-id_rsa2.req: id_rsa2.req
	openssl req -in id_rsa2.req -text | less

id_rsa2.pem: id_rsa2.req ca.cnf
	openssl ca -in id_rsa2.req -out id_rsa2.pem -verbose -config ca.cnf ;\
	find -name "id_rsa2.pem" -size 0 -exec rm {} \;

view-id_rsa2.pem: id_rsa2.pem
	openssl x509 -in id_rsa2.pem -text | less

hello.tsq: hello.txt tsq.cnf 
	openssl ts -query -data hello.txt -out hello.tsq -config tsq.cnf

view-hello.tsq: hello.tsq tsq.cnf
	openssl ts -query -in hello.tsq -text

hello.tsr: hello.tsq tsr.cnf
	openssl ts -reply -queryfile hello.tsq -out hello.tsr -config tsr.cnf

view-hello.tsr: hello.tsr
	openssl ts -reply -in hello.tsr -text

view-HOSTNAME:
	echo $(HOSTNAME)

view-USER:
	echo $(USER)
