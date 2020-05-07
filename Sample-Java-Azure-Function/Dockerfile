FROM maven:3-jdk-8 AS installer-env

RUN mkdir -p /build/azure

# Copy the parent pom and settings file
COPY ./pom.xml /build
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Copy the project pom and pull artifacts
WORKDIR /build
RUN mvn -B dependency:go-offline dependency:resolve dependency:resolve-plugins

# Copy the project source code and build it
COPY ./host.json /build/host.json
COPY ./src /build/src
RUN mvn clean package

FROM mcr.microsoft.com/azure-functions/java:3.0 as runtime
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
  AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/build/target/azure-functions/Sample-Java-Azure-Function", "/home/site/wwwroot"]
