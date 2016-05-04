#!/usr/bin/env python
import argparse
from maasclient.auth import MaasAuth
from maasclient import MaasClient

parser = argparse.ArgumentParser()
parser.add_argument("--api_key")
parser.add_argument("--api_url")
args = parser.parse_args()

auth = MaasAuth(api_url=args.api_url, api_key=args.api_key)
maas_client = MaasClient(auth)
print(maas_client.server_hostname)
