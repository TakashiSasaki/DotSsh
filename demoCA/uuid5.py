#!/usr/bin/python3
import uuid
if __name__ == "__main__":
    print("UUID5 is a SHA160-based unique ID and it requires namespace and name.")
    name = "https://twitter.com/TakashiSasaki";
    #name = input("URL (ex. https://example.com/who_am_i/ ) : ")
    newUuid = uuid.uuid5(uuid.NAMESPACE_URL, name)
    print("UUID5 for " + name + " is")
    print("UUID5 hex : ", newUuid.hex)
    print("UUID5 int : ", newUuid.int)
    print("UUID5 urn : ", newUuid.urn)
    print("UUID5 oid : ", "2.25.%s" % newUuid.int)


