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

> ⚠️ The repository only contains the containerization infrastructure (Dockerfile, configuration files, entrypoint script, etc.). The Validator binaries (`validator.war` and `ui.zip`) must be downloaded manually — see below.

## Repository structure

```text
├── Dockerfile               # Instructions to build the container image
├── VERSION                  # Image tag (e.g. 2025.1) used during build
├── LICENSE                  # EUPL-1.2 licence text
├── README.md                # Project documentation (you’re reading it)
├── ui.zip.md                # Placeholder for UI binary – replace with ui.zip
├── validator.war.md         # Placeholder for core binary – replace with validator.war
└── res/                     # Runtime scripts and configuration files
    ├── docker-entrypoint.sh # Script executed at container start-up
    ├── httpd.conf           # Base Apache HTTPD configuration
    ├── proxy.conf           # Generic proxy settings
    ├── proxy_1.conf         # Additional proxy example (variant 1)
    ├── proxy_2.conf         # Additional proxy example (variant 2)
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

---

## Getting started

### Prerequisites

You need to download the following two files from the [latest official release](https://inspire.ec.europa.eu/validator/download) of the INSPIRE Reference Validator:

- `validator.war`
- `ui.zip`

Place both files in the root of the repository (alongside the `Dockerfile`) before building the image.

> The files `validator.war.md` and `ui.zip.md` are **not** functional — they exist to keep Git history clean and indicate where the real files must go.

---

### Build the container

Run the following command in the root directory:

```bash
docker build -t inspire-validator:2025.1 .
```

This will build a container image using the version tag defined in the VERSION file.


---

### Run the container

```bash
docker run --name inspire-validator \
  -d -p 8090:8090 \
  -v ~/etf:/etf \
  inspire-validator:2025.1
```

The validator UI will be available at:
    http://localhost:8090/validator/home/index.html

A volume is mounted to persist user data under ~/etf.

###Proxy support

If your environment requires using a proxy, the container can be run with the following environment variables:

```bash
--env http_proxy=http://your.proxy:port \
--env https_proxy=https://your.proxy:port \
--env no_proxy=127.0.0.1,localhost
```

During the build process, you may also provide proxy settings as build arguments:

```bash
--build-arg http_proxy=http://your.proxy:port \
--build-arg https_proxy=https://your.proxy:port
```

See the Docker proxy configuration guide for details.

### Binary files

The validator.war and ui.zip files are part of the release packages made available by the INSPIRE Reference Validator. This repository does not store them for maintenance reasons.

You must download them manually from the [official validator release page](https://github.com/jenriquesoriano/helpdesk-validator/releases/) and place them in the root directory of the repository before building the image.

## Official deployment instructions

Comprehensive deployment, configuration and troubleshooting steps are provided in the upstream documentation:

INSPIRE Validator – Docker Deployment Instructions
https://github.com/INSPIRE-MIF/helpdesk-validator/blob/master/training%20material/2020-09-16_Docker_deployment_instructions.md

Topics covered include:

    Building and running the image

    Running behind a proxy

    Custom domain configuration

    Using the INSPIRE Registry cache

    Providing TEAM Engine credentials

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
See the LICENSE file for details.

## Maintainers

This repository is maintained by the
Joint Research Centre (JRC), European Commission
https://joint-research-centre.ec.europa.eu/