#!/usr/bin/env python3
import argparse
from apiclient import maas_client

parser = argparse.ArgumentParser()
parser.add_argument("--api_key")
parser.add_argument("--api_url")
args = parser.parse_args()


auth = maas_client.MAASOAuth(*args.api_key.split(":"))
client = maas_client.MAASClient(auth, maas_client.MAASDispatcher(), args.api_url)
print(client.get(u"version/").read())
