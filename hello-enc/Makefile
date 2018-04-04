.PHONY: all pass nosalt keyiv

all: pass nosalt keyiv

IV=a10000
KEY=b20000

pass:
	@echo with password and salt, round 1 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -pass pass:himitsu ;\
	openssl md5  hello.enc
	echo with password and salt, round 2 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -pass pass:himitsu ;


nosalt:
	@echo with password, round 1 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -pass pass:himitsu -nosalt;\
	echo with password round 2 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -pass pass:himitsu -nosalt;

keyiv:
	@echo with key and IV, round 1 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -nosalt -K $(KEY) -iv $(IV);\
	echo with key and IV, round 2 ;\
	openssl aes-256-cbc -in hello.txt -out hello.enc -p -nosalt -K $(KEY) -iv $(IV);

