
COLTE_LIGHT_VERSION=0.10.0
COLTE_FULL_VERSION=0.10.0
COLTE_VERSION=0.9.11
CONF_VERSION=0.9.13
WEBSERVICES_VERSION=0.9.11

TARGET_DIR=./BUILD/

.PHONY: webadmin webgui all

all: light full colte conf webservices

build_deps:
	sudo apt-get install ruby ruby-dev rubygems build-essential
	sudo gem install --no-ri --no-rdoc fpm

web_deps_ubuntu:
	sudo apt-get install npm nodejs

web_deps_debian:
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
	sudo apt-get install nodejs

target:
	mkdir -p $(TARGET_DIR)

light: target
	fpm --input-type empty \
		--output-type deb \
		--force \
		--vendor uw-ictd \
		--maintainer sevilla@cs.washington.edu \
		--description "The Community LTE Project - Light Version (EPC and Conf-tools Only)" \
		--url "https://github.com/uw-ictd/colte" \
		--name colte-light \
		--version $(COLTE_LIGHT_VERSION) \
		--package $(TARGET_DIR) \
		--depends 'colte-epc (>= 0.9.3), colte-conf'

colte: target
	fpm --input-type dir \
		--output-type deb \
		--force \
		--vendor uw-ictd \
		--maintainer sevilla@cs.washington.edu \
		--description "The Community LTE Project" \
		--url "https://github.com/uw-ictd/colte" \
		--name colte \
		--version $(COLTE_VERSION) \
		--package $(TARGET_DIR) \
		--depends 'colte-epc (>= 0.9.3), colte-webservices, haulage, colte-conf' \
		./package/colte/haulage.yml=/usr/local/etc/colte/haulage.yml

conf: target
	fpm --input-type dir \
		--output-type deb \
		--force \
		--vendor uw-ictd \
		--config-files /usr/bin/colte/roles/configure/vars/main.yml \
		--maintainer sevilla@cs.washington.edu \
		--description "Configuration Tools for CoLTE" \
		--url "https://github.com/uw-ictd/colte" \
		--name colte-conf \
		--version $(CONF_VERSION) \
		--package $(TARGET_DIR) \
		--depends 'ansible, python-mysqldb, colte-db' \
		--after-install ./conf/postinst \
		--after-remove ./conf/postrm \
		./conf/colteconf=/usr/bin/ \
		./conf/coltedb=/usr/bin/ \
		./conf/colte=/usr/bin/ \
		./conf/colte-tcpdump.service=/etc/systemd/system/colte-tcpdump.service \
		./conf/config.yml=/usr/local/etc/colte/config.yml

webservices: target
	cd webgui; npm install
	cd webgui; cp production.env .env
	cd webadmin; npm install
	cd webadmin; cp production.env .env
	fpm --input-type dir \
		--output-type deb \
		--force \
		--vendor uw-ictd \
		--config-files /usr/bin/colte-webgui/.env \
		--config-files /usr/bin/colte-webadmin/.env \
		--maintainer sevilla@cs.washington.edu \
		--description "CoLTE WebServices: WebAdmin tool for CoLTE network administrators and WebGUI for users to check balance and buy/sell data." \
		--url "https://github.com/uw-ictd/colte" \
		--name colte-websevices \
		--version $(WEBSERVICES_VERSION) \
		--package $(TARGET_DIR) \
		--depends 'nodejs (>= 8.0.0), colte-db (>= 0.9.11), colte-conf' \
		--after-install ./package/webservices/postinst \
		--after-remove ./package/webservices/postrm \
		./webgui/=/usr/bin/colte-webgui \
		./package/webservices/colte-webgui.service=/etc/systemd/system/colte-webgui.service \
		./package/webservices/webgui.env=/usr/local/etc/colte/webgui.env \
		./package/webservices/pricing.json=/usr/local/etc/colte/pricing.json \
		./webadmin/=/usr/bin/colte-webadmin \
		./package/webservices/colte-webadmin.service=/etc/systemd/system/colte-webadmin.service \
		./package/webservices/webadmin.env=/usr/local/etc/colte/webadmin.env 

