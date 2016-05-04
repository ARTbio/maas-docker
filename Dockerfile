FROM ubuntu:14.04

# Based on https://github.com/tianon/dockerfiles/blob/4d24a12b54b75b3e0904d8a285900d88d3326361/sbin-init/ubuntu/upstart/14.04/Dockerfile

ADD init-fake.conf /etc/init/fake-container-events.conf

ADD . /setup

# remove pointless stuff and run maas playbook
RUN rm /usr/sbin/policy-rc.d; \
	rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl && \
    locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 && \
    /usr/sbin/update-rc.d -f ondemand remove; \
	for f in \
		/etc/init/u*.conf \
		/etc/init/mounted-dev.conf \
		/etc/init/mounted-proc.conf \
		/etc/init/mounted-run.conf \
		/etc/init/mounted-tmp.conf \
		/etc/init/mounted-var.conf \
		/etc/init/tty*.conf \
		/etc/init/hwclock*.conf \
	; do \
		dpkg-divert --local --rename --add "$f"; \
	done; \
	echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab && \
    apt-get update -qq && \
    apt-get install -y apt-transport-https software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update -qq && apt-get install -y --no-install-recommends ansible && \
    ansible-playbook -i /setup/hosts.ini -c local --tags install_packages /setup/playbook.yml

# let Upstart know it's in a container
ENV container docker

# pepare for takeoff
CMD ["/sbin/init"]
