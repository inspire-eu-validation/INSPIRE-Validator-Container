# INSPIRE Validator – Container

## Table of Contents

1. [Repository structure](#repository-structure)  
2. [Getting started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Build the container](#build-the-container)  
   - [Run the container](#run-the-container)  
   - [Proxy support](#proxy-support)  
   - [Binary files](#binary-files)  
3. [Official deployment instructions](#official-deployment-instructions)  
4. [Contributing](#contributing)  
5. [License](#license)  
6. [Maintainers](#maintainers)


This repository provides the necessary resources to **build and run a Docker container** for the [INSPIRE Reference Validator](https://inspire.ec.europa.eu/validator/home/index.html). The validator is used to verify the conformity of spatial data sets and services with the INSPIRE Directive and related Technical Guidelines.

This containerization allows public authorities, data providers and integrators to deploy the INSPIRE Reference Validator in their own environments, either for internal testing or as part of production workflows.

The repository only contains the containerization infrastructure (Dockerfile, configuration files, entrypoint script, etc.). The Validator binaries (`validator.war` and `ui.zip`) must be downloaded manually — see below.

## Repository structure

```text
├── Dockerfile               # Instructions to build the container image
├── VERSION                  # Image tag (e.g. 2025.1) used during build
├── LICENSE                  # EUPL-1.2 licence text
├── README                   # Project documentation
├── ui.zip                   # Placeholder for UI binary – replace with ui.zip
├── validator.war            # Placeholder for core binary – replace with validator.war
└── res/                     # Runtime scripts and configuration files
    ├── docker-entrypoint.sh # Script executed at container start-up
    ├── httpd.conf           # Base Apache HTTPD configuration
    ├── proxy.conf           # Generic proxy settings
    ├── proxy_1.conf         # Apache proxy for INSPIRE Registry
    ├── proxy_2.conf         # Apache proxy for validator UI and captcha
    ├── squid.conf           # Squid proxy configuration
    ├── geant.pem            # GEANT CA certificate
    ├── services.lgrb-bw.de  # Certificate for services.lgrb-bw.de
    ├── opendata.skgeodesy.sk# Certificate for opendata.skgeodesy.sk
    ├── _.fega.gob.es        # Wild-card certificate for *.fega.gob.es
    └── _.hzinfra.hr         # Wild-card certificate for *.hzinfra.hr
```

- `Dockerfile`: Defines the image used to run the validator.
- `VERSION`: Specifies the current release tag to build and label the image.
- `res/`: Contains the entrypoint script and auxiliary configuration files used during runtime.

## Getting started

### Prerequisites

You need to download the following two files from the [latest official release](https://inspire.ec.europa.eu/validator/download) of the INSPIRE Reference Validator:

- `validator.war`
- `ui.zip`

Place both files in the root of the repository (alongside the `Dockerfile`) before building the image.

The files `validator.war.md` and `ui.zip.md` are **not** functional — they exist to keep Git history clean and indicate where the real files must go.

### Build the container

Run the following command in the root directory:

```bash
docker build . -t [IMAGE_NAME]:[VERSION]
```

For example:
```bash
docker build . -t inspire-validator:2025.1
```

This will build a container image using the version tag defined in the VERSION file.

### Run the container

```bash
docker run --name inspire-validator -d -p 8090:8090 -v ~/etf:/etf [IMAGE_NAME]:[VERSION]
```

For example:
```bash
docker run --name inspire-validator -d -p 8090:8090 -v ~/etf:/etf inspire-validator:2025.1
```

This launches a container with the image, exposing the UI in port 8090 through the same port in the host machine, and uses a volume in the local file system, on the directory ~/etf, this will create an ~/etf folder inside the user home folder.

Once the INSPIRE Reference Validator has fully loaded, we can access to it through the URL:
    http://localhost:8090/validator/home/index.html

A volume is mounted to persist user data under ~/etf.

### Proxy support

If your environment requires using a proxy, the container can be run with the following environment variables:

For the run command, you need to add the environment variables to it:

```bash
--env http_proxy=[HTTP_PROXY_URL:PORT] \
--env https_proxy=[HTTPS_PROXY_URL:PORT] \
--env no_proxy=127.0.0.1,localhost,*.<mydomain>
```

During the build process, you may also provide proxy settings as build arguments:

```bash
--build-arg http_proxy=[HTTP_PROXY_URL:PORT] \
--build-arg https_proxy=[HTTPS_PROXY_URL:PORT] \
--build-arg no_proxy=127.0.0.1,localhost,*.<my-domain>
```

These can also be set up in the Dockerfile, using the keyword ENV.

For more information please check out [Docker proxy configuration guide](https://docs.docker.com/network/proxy).

### Binary files

The validator.war and ui.zip files are part of the release packages made available by the INSPIRE Reference Validator. This repository does not store them for maintenance reasons.

You must download them manually from the [official validator releases page](https://github.com/INSPIRE-MIF/helpdesk-validator/releases/) and place them in the root directory of the repository before building the image.

## Official deployment instructions

### Modifying the Docker image

In the inspire-validator ZIP file, you can find all the resources needed to generate the Docker image from this release. If you would like to tweak anything from it, you can modify any of its contents (Dockerfile, entrypoint file, configuration files... ), then execute (inside the ETF docker folder) the command:

```bash
docker build . -t [IMAGE_NAME]:[VERSION]
```

You can run this again using the run command:

```bash
docker run --name inspire-validator -d -p 8090:8090 -v ~/etf:/etf [IMAGE_NAME]:[VERSION]
```

### Deployment on production host

The Docker image is set up to run at localhost to be deployed on any machine. However, users may need to access their validator on a dedicated host, usually with a domain name. For proper functioning of the validator, the UI and correct rendering of Test Reports, the validator needs to be configured to run on a domain.

If you want to run the webapp in another host, you can change the configuration file, inside the .war file inside the inspire-validator zip file accompanying this release, at `WEB-INF/classes/etf-config.properties`, and modify the `etf.webapp.base.url` property.  
It is also necessary to configure the Validator UI properties in order to properly point to the ETF. Thus, it is necessary to modify the configuration values in the /validator/js/config.js file inside the ui.zip (to point to the corresponding host domain).  
Then you can proceed to the build process described in the previous point.

Since 22/12/2022 OGC moved to production version 5.5.2 (2022-08-26) of the TEAM Engine, which introduced credentials for the calls to the services.  
Thus, any deployment which makes use of the OGC TEAM Engine needs to introduce credentials (to be requested here) in order to use them.  
We have incorporated three parameters in the _/WEB-INF/classes/etf-config.properties_ file of _validator.war_ that need to be filled accordingly to authorize the use of the services:

```properties
#TEAM Engine credentials of your organization in order to properly use TEAM Engine remote calls
etf.testdrivers.teamengine.url = http://cite.opengeospatial.org/teamengine
etf.testdrivers.teamengine.username = 
etf.testdrivers.teamengine.password =
```

### Setting up a cache of INSPIRE Registry resources

In your own deployment you may want to increase the performance of fetching the different resources that the INSPIRE Reference Validator requires from the INSPIRE Registry for validations.

The file `inspire-registry-resources.zip` is included in the official release package and contains the resources that the INSPIRE Reference Validator requests to the INSPIRE Registry to execute the validations defined in the Executable Test Suites (ETSs).  
Using this content, you may configure your own deployment to access these resources without the need to make a call to the INSPIRE Registry to obtain them, increasing the performance of your own instance while decreasing the dependency on external resources in your installation.

 **Note**: The `inspire-registry-resources.zip` file is **not included** in this container repository. You must download it separately from the [official release](https://github.com/INSPIRE-MIF/helpdesk-validator/releases/) where it is attached as an asset.

#### Example of setting up INSPIRE Registry resources as cache

In order to show how to use the Registry resources as cache, we have prepared a simple example.  
The purpose of this example is to provide a foundation that can be adapted to an organization's proxy policies.

* Download the Registry resources from the official release assets.
* Unzip the resources.
* Open a terminal and access the resources folder
* Publish the resources as an http server using, for example, Python:  
`python -m http.server 8000`
* Once the resources are published, we can use any proxy reverse (nginx, apache, ...). We show you an example using fiddle:  
`function OnBeforeRequest(oSession: Session) { if (oSession.host == "inspire.ec.europa.eu") { oSession.host = "0.0.0.0"; oSession.port = 8000; oSession.url = oSession.url.replace("https://inspire.ec.europa.eu", "http://0.0.0.0:8000"); } }`

This will ensure that all the Validator's requests to the Registry are redirected to the server, using these local Registry resources instead.

For further configuration, please download the file inspire-validator-2025.1.zip and follow the instructions in the README.md file inside the .zip file.

## Contributing

We welcome contributions from Member States, implementers and the wider community.

To contribute:

1. Fork the repository.
2. Create a new branch from `main`.
3. Make your changes.
4. Submit a pull request with a clear description of the change.


Please follow existing patterns and naming conventions. Squash-merge is used for PRs.

## License

This project is licensed under the European Union Public Licence v1.2 (EUPL-1.2).
See the [LICENSE](https://github.com/inspire-eu-validation/INSPIRE-Validator-Container/blob/main/LICENSE) file for details.

## Maintainers

This repository is maintained by the
[Joint Research Centre (JRC), European Commission](https://joint-research-centre.ec.europa.eu/)