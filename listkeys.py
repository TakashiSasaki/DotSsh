#!/usr/bin/python3
import os,subprocess,re,tempfile,socket,uuid,datetime

def isClearKeyFile(filename: str):
  f = open(filename)
  lines = f.readlines()
  m = re.compile("BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY").search(lines[0])
  if m is None: return False
  m = re.compile("ENCRYPTED").search(lines[1])
  if m is None: return True;
  return False

def isPublicKeyFile(filename: str):
  f = open(filename)
  lines = f.readlines()
  m = re.compile("^(ssh-rsa|ssh-dss|ecdsa-sha2-nistp256|ssh-ed25519) ").search(lines[0])
  if m is not None: return True
  return False

def rsaPrivateKeyFileToRsaPublicKey(rsaPrivateKeyFile:str):
  openssl = subprocess.run(["openssl", "rsa", "-pubout", "-RSAPublicKey_out", "-in", rsaPrivateKeyFile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  rsaPublicKey = openssl.stdout.decode("ascii")
  return rsaPublicKey


def rsaPublicKeyToPublicKey(rsaPublicKey:str):
  temporaryFile = tempfile.NamedTemporaryFile(delete=False)
  temporaryFile.write(rsaPublicKey.encode("ascii"))
  temporaryFile.close()
  sshKeyGenProcess = subprocess.run(["ssh-keygen", "-i", "-m", "PEM", "-f", temporaryFile.name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  openSshPublicKey = sshKeyGenProcess.stdout.decode("ascii")
  return openSshPublicKey

def publicKeyToFingerprint(publicKey:str):
  sshKeygen = subprocess.Popen(["ssh-keygen", "-l", "-E", "md5", "-f", "-"],stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  fingerprintLine = sshKeygen.communicate(publicKey.encode("ascii"))[0].decode("ascii")
  return parseFingerprintLine(fingerprintLine)

def privateKeyFileToPublicKey(privateKeyFile:str):
  sshKeygen = subprocess.Popen(["ssh-keygen", "-y", "-f", privateKeyFile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  publicKey = sshKeygen.communicate()[0].decode("ascii")
  return publicKey

def publicKeyFileToFingerprint(publicKeyFile:str):
  return publicKeyToFingerprint(open(publicKeyFile).read())

def rsaPrivateKeyFileToFingerprint(rsaPrivateKeyFile: str):
  rsaPublicKey = rsaPrivateKeyFileToRsaPublicKey(rsaPrivateKeyFile)
  publicKey = rsaPublicKeyToPublicKey(rsaPublicKey)
  fingerprint = publicKeyToFingerprint(publicKey)
  return fingerprint

def parseFingerprintLine(fingerprintLine:str):
  m = re.compile("^([0-9]+) +MD5:([0-9A-Fa-f:]+) +(.*) +\(([0-9A-Z]+)\)$").match(fingerprintLine)
  bits = m.group(1)
  md5 = m.group(2)
  comment = m.group(3)
  algorithm = m.group(4)
  return [bits, md5, comment, algorithm]

if __name__ == "__main__":
  result = []
  macAddress = hex(uuid.getnode())[2:].zfill(12)
  hostname = socket.gethostname()
  datetime = datetime.datetime.now().isoformat()
  files = os.listdir(".")
  for filename in files:
    d = {}
    if not os.path.isfile(filename): continue
    d["datetime"] = datetime
    d["hostname"] = hostname
    d["macAddress"] = macAddress
    d["absolutePath"] = os.path.abspath(filename)
    try: 
      fingerprint = None
      if isClearKeyFile(filename):
        publicKey = privateKeyFileToPublicKey(filename)
        fingerprint = publicKeyToFingerprint(publicKey)
        d["private"] = True
      elif isPublicKeyFile(filename):
        fingerprint = publicKeyFileToFingerprint(filename)
        d["private"] = False
      else: continue
      d["bits"] = fingerprint[0]
      d["md5"] = fingerprint[1]
      d["comment"] = fingerprint[2]
      d["algorithm"] = fingerprint[3]
      print(d)
    except UnicodeDecodeError as e:
      continue

