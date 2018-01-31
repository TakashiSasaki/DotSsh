.PHONY: req test

req:
	openssl req -new -key id_rsa -subj "/C=JP/ST=Ehime/O=Takashi SASAKI Things/O=SSH keys/OU=$(shell hostname)/OU=Ubuntu on Windows/CN=$(USER)/emailAddress=takashi316@gmail.com" -out id_rsa.req

pem:
	openssl ca -in id_rsa.req -out id_rsa.pem -days 36500

test:
	echo $(USER); echo $(shell hostname)
