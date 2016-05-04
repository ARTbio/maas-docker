include env_make
NS = artbio
VERSION ?= latest

REPO = maas
NAME = maas
INSTANCE = default

.PHONY: build push shell run start stop rm release
build:
	docker build -t $(NS)/$(REPO):$(VERSION) .
	docker run -d --name $(NAME)-$(INSTANCE) --privileged $(NS)/$(REPO):$(VERSION)
	docker exec $(NAME)-$(INSTANCE) ansible-playbook -i localhost, -c local /setup/playbook.yml
	docker exec $(NAME)-$(INSTANCE) cp /setup/rsyslog.conf /etc/init/rsyslog.conf
	make commit
	make stop
	make rm
	docker build -t $(NS)/$(REPO):$(VERSION) volumes
push:
	docker push $(NS)/$(REPO):$(VERSION)

commit:
	docker commit $(NAME)-$(INSTANCE) $(NS)/$(REPO):$(VERSION)

shell:
	docker exec -i -t $(NAME)-$(INSTANCE) /bin/bash

run:
	docker run -d --net $(NET) --privileged --name $(NAME)-$(INSTANCE) $(ENV) $(NS)/$(REPO):$(VERSION)

get_api_key:
	docker exec $(NAME)-$(INSTANCE)  maas-region-admin apikey --username maas > api_key.txt

get_ip_address:
	docker inspect --format '{{ .NetworkSettings.Networks.net1.IPAddress }}' maas-default > ip.txt

test_api_access:
	make get_api_key
	make get_ip_address
	python maas_api_test.py --api_key `cat api_key.txt` --api_url http://`cat ip.txt`/MAAS/api/1.0 | grep `cat ip.txt`

persistent_volumes:

	docker create --name maas_persistent_data -v /etc/maas -v /var/lib/maas -v /var/lib/postgresql -v /var/log $(NS)/$(REPO):$(VERSION) /bin/true

delete_persistent_volumes:

	docker rm maas_persitent_data

run_persistent:

	docker run -d --net $(NET) --restart=always --privileged --volumes-from maas_persistent_data --name $(NAME)-$(INSTANCE) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	make stop
	docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
