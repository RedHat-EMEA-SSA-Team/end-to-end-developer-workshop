
.NET Core Gateway Service
===
## Introduction
This microservice has been converted from the original Vert.x implementation and now targets .NET Core 3.1

![](https://raw.githubusercontent.com/alexgroom/cnw3/master/gateway-dotnet/wwwroot/240px-NET_Core_Logo.png)


The component can be built/deployed in many different ways for example:

* Using +Add from the OpenShift web console developer 
    * From Git
    * From Dockerfile
* Via oc new-app
* Via Docker
* Command line locally

## Environment Variables
The Gateway service is dependent on the Catalog and Inventory services, so without links to these it cannot function. The current implmentation will typically fail to start cleanly without these enviroment variables set
* INVENTORY_COOLSTORE_SERVICE_HOST
* INVENTORY_COOLSTORE_SERVICE_PORT
* CATALOG_COOLSTORE_SERVICE_HOST
* CATALOG_COOLSTORE_SERVICE_PORT

## URLs
As before the main entry point to the service API is via ``<hostname>/api/products`` and this returns an amalgamation of the product infortmation collected from the Catalog service with the availability amount coming from the Inventory service.

There is test page displayed on the base URL.


## Build and Deploy from CLI

```
oc new-app dotnet:3.1~https://github.com/alexgroom/cnw3.git \
  --context-dir=gateway-dotnet --name=gateway \
  --as-deployment-config\
  -l app.openshift.io/runtime=dotnet \
  -e CATALOG_COOLSTORE_SERVICE_HOST=catalog -e INVENTORY_COOLSTORE_SERVICE_HOST=inventory -e CATALOG_COOLSTORE_SERVICE_PORT=8080 -e INVENTORY_COOLSTORE_SERVICE_PORT=8080
oc expose svc gateway

```
## Local build
Fetch the source from the sub folder and then use the dotnet tooling to build and run. Note that environment variables must be set up to point to the dependent services that maybe running locally or even exposed via OpenShift.
```
$ dotnet restore
$ dotnet build
$ export CATALOG_COOLSTORE_SERVICE_HOST=catalog
$ export INVENTORY_COOLSTORE_SERVICE_HOST=inventory 
$ export CATALOG_COOLSTORE_SERVICE_PORT=8080 
$ export INVENTORY_COOLSTORE_SERVICE_PORT=8080
$ dotnet run
```
## Docker command line
Fetch the source then build via the supplied Dockerfile. You may need to login in to access the redhat registry to pull the ubi8 as a base.

```
$ docker login registry.redhat.io
$ docker pull registry.redhat.io/ubi8/dotnet-31-runtime


$ docker build -t gateway .
$ docker run --env CATALOG_COOLSTORE_SERVICE_HOST=localhost \
--env INVENTORY_COOLSTORE_SERVICE_HOST=localhost \
--env CATALOG_COOLSTORE_SERVICE_PORT=80 \
--env INVENTORY_COOLSTORE_SERVICE_PORT=80 \
 gateway
```
## +Add from Git or Dockerfile
The OpenShift web console can build this service either directly from Git source using S2I or via the dockerfile and the tools built into the base image.

In both case you need to specify the git library and (in Advanced settings) the context folder. Choose an application name like "gateway"

For a Git build you must select the appropriate builder and version, this will be .NET Core and version 3.1. 

For the Dockerfile based version, an extra label can be addeded to indicate the running service is .NET.

```
oc label dc gateway app.openshift.io/runtime=dotnet
```


