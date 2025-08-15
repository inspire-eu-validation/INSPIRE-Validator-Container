FROM jetty:10.0.18-jre11-alpine-eclipse-temurin
MAINTAINER Guadaltel <guadaltel.com>
LABEL maintainer="Guadaltel <inspire.jrc@guadaltel.com>"

LABEL Name="etf-webapp" Description="Testing framework for spatial data and services" Vendor="European Union, interactive instruments GmbH" Version=“2025.1”

EXPOSE 8090

USER root
ENV ETF_DIR /etf
ENV ETF_LOG_DIR /etf/logs

ENV ETF_RELATIVE_URL validator
# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> e.g. “2.0.0” or
# <version as MAJOR.MINOR> e.g. “1.0” to get the latest bugfix version
ENV ETF_WEBAPP_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Packed with the Webapp
ENV ETF_TESTDRIVER_BSX_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Will be downloaded
ENV ETF_GMLGEOX_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Packed with the Webapp
ENV ETF_TESTDRIVER_SUI_VERSION latest

# Possible values: “latest”, <version as MAJOR.MINOR.BUGFIX> or
# <version as MAJOR.MINOR>
# Packed with the Webapp
ENV ETF_TESTDRIVER_TE_VERSION latest

# Default repository configuration
ENV REPO_URL https://services.interactive-instruments.de/etfdev-af/etf-public-dev
ENV REPO_USER etf-public-dev
ENV REPO_PWD etf-public-dev

# Possible values: “none” or URL to ZIP file
ENV ETF_DL_TESTPROJECTS_ZIP https://github.com/inspire-eu-validation/ets-repository/archive/v2025.1.zip
# Subfolder in the projects directory
ENV ETF_DL_TESTPROJECTS_DIR_NAME inspire-ets-repository
# Possible values: true for overwriting the directory on every container start,
# false for keeping an existing directory
ENV ETF_DL_TESTPROJECTS_OVERWRITE_EXISTING true

# Maximum JAVA heap size (XmX parameter) in MB or “max” (max available memory-768MB if at least 3GB available)
ENV MAX_MEM max

# Activate HTTP proxy server by setting a host (IP or DNS name).
# Default: "none" for not using a proxy server
ENV HTTP_PROXY_HOST localhost
# HTTP proxy server port. Default 8080. If you are using Squid it is 3128
ENV HTTP_PROXY_PORT 3128
# Optional username for authenticating against HTTP proxy server or "none" to
# deactivate authentication
ENV HTTP_PROXY_USERNAME none
# Optional password for authenticating against HTTP proxy server or "none"
ENV HTTP_PROXY_PASSWORD none

# Activate HTTP Secure proxy server by setting a host (IP or DNS name).
# Default: "none" for not using a proxy server
ENV HTTPS_PROXY_HOST none
# HTTP Secure proxy server port. Default 3129.
ENV HTTPS_PROXY_PORT 3129
# Optional username for authenticating against HTTPS proxy server or "none" to
# deactivate authentication
ENV HTTPS_PROXY_USERNAME none
# Optional password for authenticating against HTTP Secure proxy server or "none"
ENV HTTPS_PROXY_PASSWORD none

# Config domain where the service runs
# - empty string means current domain
# - code defaults to http://localhost:8090
# Affects (sed cmd in res/docker-entrypoint.sh):
#  - /etf/validator/js/config.js
#  - /etf/config/etf-config.properties
ENV SERVICE_DOMAIN_OVERRIDE ""

RUN mv /docker-entrypoint.sh /docker-entrypoint-jetty.sh
COPY res/docker-entrypoint.sh /
# Ensure the sh has permission to execute
# Preventing: Error: crun: open executable: Permission denied: OCI permission denied
RUN chmod +x /docker-entrypoint.sh

# Inject the config properties file so we have a file to modify the domain at container build.
# Otherwise the app will write a default properties file on startup.
COPY res/etf-config.properties $ETF_DIR/config/

RUN apk add openrc --no-cache

RUN apk update; true

RUN apk add squid
RUN apk add --no-cache tini openrc busybox-openrc

COPY res/squid.conf /etc/squid/squid.conf


COPY ui.zip ui.zip

# INSTALL apache
RUN apk add apache2 apache2-ssl apache2-proxy
COPY res/proxy_1.conf /etc/apache2/conf.d/proxy_1.conf
COPY res/proxy_2.conf /etc/apache2/conf.d/proxy_2.conf
COPY res/httpd.conf /etc/apache2/httpd.conf



RUN apk add openssl


#MAPAMA
RUN openssl s_client -servername wms.mapama.gob.es -connect wms.mapama.gob.es:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias wms.mapama.gob.es -storepass changeit || true

#MAPAMA
RUN openssl s_client -servername mapama.gob.es -connect mapama.gob.es:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias mapama.gob.es -storepass changeit || true

#dgterritorio portugal
#RUN openssl s_client -servername cartografia.dgterritorio.gov.pt -connect cartografia.dgterritorio.gov.pt:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
#RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /usr/local/openjdk-8/lib/security/cacerts -alias cartografia.dgterritorio.gov.pt -storepass changeit

#geonet

RUN openssl s_client -servername mapservice.geonet.es -connect mapservice.geonet.es:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias mapservice.geonet.es -storepass changeit 

#calp

RUN openssl s_client -servername geoportal.calp.es -connect geoportal.calp.es:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias geoportal.calp.es -storepass changeit 


#pki bayern
RUN openssl s_client -servername geoservices.bayern.de -connect geoservices.bayern.de:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias geoservices.bayern.de -storepass changeit  

#pki bayern
RUN openssl s_client -servername gdiserv.bayern.de -connect gdiserv.bayern.de:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias gdiserv.bayern.de -storepass changeit 

#pki bayern
RUN openssl s_client -servername www.lfu.bayern.de -connect www.lfu.bayern.de:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias lfu.bayern.de -storepass changeit 

#ogc team engine
RUN openssl s_client -servername cite.opengeospatial.org -connect cite.opengeospatial.org:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias cite.opengeospatial.org -storepass changeit

#CNIG
COPY res/geant.pem /tmp/certificate.pem
RUN keytool -import -alias geantovrsaca4 -keystore /opt/java/openjdk/lib/security/cacerts -file /tmp/certificate.pem -storepass changeit

#lgrb-test
COPY res/services.lgrb-bw.de /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias test-lgrb.bw.de -storepass changeit

# hzinfra
COPY res/_.hzinfra.hr /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias hzinfra -storepass changeit

# fega
RUN openssl s_client -servername www.fega.gob.es -connect www.fega.gob.es:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias fega -storepass changeit || true

# opendata
COPY res/opendata.skgeodesy.sk /tmp/certificate.pem
RUN keytool -importcert -noprompt -trustcacerts -file /tmp/certificate.pem -keystore /opt/java/openjdk/lib/security/cacerts -alias opendata -storepass changeit || true


COPY --chown=jetty:jetty $ETF_RELATIVE_URL.war /var/lib/jetty/webapps

RUN mkdir /run/openrc
RUN mkdir /run/openrc/exclusive
RUN touch /run/openrc/softlevel


#RUN apk del curl libcurl wget y unzip y nano
RUN apk add curl libcurl wget unzip nano


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
