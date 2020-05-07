---
page type: sample
languages:
- java
- hcl
products/technologies:
- azure-functions
- azure-pipelines
- docker
---

# Official Microsoft Sample
These samples showcase the following:
- How to use Terraform to provision and deploy Azure Functions based on either docker image or running from a package.
- How to create a docker image to run a Java Azure Function. The assets include: 
  - **DockerFile**: The docker file where the Maven build is done and the artifacts are moved to a final usable Azure Function v3 image.
  - **docker-compose**: a wrapper for the DockerFile to help ease running the docker file.
  - **Azure Pipeline Config**: An Azure DevOps pipeline yaml configuration file that runs the docker file to create the docker image, and then extract the test results from the image and expose them to the pipeline, as well as push the image to a registry.

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `Sample-Java-Azure-Function`             | Sample Java Azure Function, DockerFile, docker-compose, and Azure pipeline files.                        |
| `Terraform`       | Sample Terraform code.
| `.gitignore`      | Define what to ignore at commit time.      |
| `CHANGELOG.md`    | List of changes to the sample.             |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md`       | This README file.                          |
| `LICENSE`         | The license for the sample.                |

## Running The Sample

## Azure Functions Terraform Module

This [Terraform](https://www.terraform.io/intro/index.html) module simplifies provisioning [Azure Functions](https://azure.microsoft.com/en-us/services/functions/) based on either docker image or running from a package.

### Prerequisites

Before using this Terraform model,
- we expect you to have basic knowledge about:
  - [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)
  - [Azure provider in Terraform](https://www.terraform.io/docs/providers/azurerm/index.html)
- [Terraform 0.12+](https://www.terraform.io/downloads.html) installed.
- [Azure subscription](https://portal.azure.com/) for the module to run deployments within.
- [Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) for tracking Terraform remote backend state.
 - This module assumes that the following resources are deployed in your Azure subscription:
    - a [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/manage-resource-groups-portal#create-resource-groups)
   - an [app service plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
   - an [application insights resource](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

### Characteristics

*  Provisions a set of azure function apps.
 * Supports [deployment from a docker image](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=nodejs).
 * Supports [enabling functions to run from package](https://docs.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package#enabling-functions-to-run-from-a-package).
 * Supports azure resource [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags).
 * Supports [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) integration.
 * Supports [Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) integration.
 * Function [App Setting](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) configuration.

### Usage
#### Function-App usage example:

```hcl
module "function_app" {
  source = "<root directory>/function-app"
  fn_name_prefix = var.function_name_prefix
  service_plan_name                 = var.service_plan_name
  resource_group_name  = var.resource_group_name
  storage_account_name              = var.storage_account_name
  docker_registry_server_username   = var.docker_username
  docker_registry_server_password   = var.docker_password
  app_insights_instrumentation_key  = var.app_insights_instrumentation_key
  fn_app_config                     = {
                                        var.first_function_name: {
                                          image : var.function_image,
                                          zip : null,
                                          hash: null
                                        },
                                        var.second_function_name: {
                                            image : null,
                                            zip : var.function_package_location,
                                            hash : var.function_package_sha
                                        }
                                      }
}
```
#### Running the module
#### 1. Clone the repo
Clone the repo to your local machine and navigate to [Terraform directory](./Terraform/function-app).
#### 2. Configuring input variables
Using any of the options in [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables), you can configure the following variables:
- ####  Configuring `fn_app_prefix`
    Each function app created will be in the format `fn_app_prefix-function_app_name`.

- #### Configuring `docker_registry_server_username` and `docker_registry_server_pasword`

    The username and password for the docker registry in order to be able to pull the images to deploy the function apps.

- ####  Configuring `fn_app_config`

    This is a map where the key is the `function_app_name` and the value is an object that contains the definition of what's being deployed. It has one of two possible structures:

    * For Docker based deployment, the object has one field: 
      - `image`: which refers to the docker image name to deploy.
    * For running from a package, it should contains the fields:
      - `zip`: contains an http reference to the package.
        
        This will enable your function app to [run from a package](https://docs.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package) by adding a `WEBSITE_RUN_FROM_PACKAGE` setting to your function app settings.
      - `hash`: contains a hash of the zip file for downloads integrity check.
      
  ####  3.  Apply the module
  In a terminal window, run the following commands:
  
  `cd terraform/function-app`
  
  `terraform init`
  
  `terraform apply`
  

# Dockerizing The Function
### Prerequisites
Before using this DockerFile,
- we expect you to have basic knowledge about:
  - [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)
  - [Building images with DockerFiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
  - Java programming language.
- [Docker](https://docs.docker.com/get-docker/) installed.

Inside the [Sample-Java-Azure-Function directory](./Sample-Java-Azure-Function) you'll find:
* a sample java azure function.
* a DockerFile that builds a Java project inside a docker image and provides a runnable Azure Function image.
* a Docker-Compose file.
* a sample Azure Pipeline yaml file.
### Usage
#### Using DockerFile:
In order to use the sample docker file provided, you will need to:
* In "docker-compose.yml" file, replace `<image-name>` with your docker image name.
* Use the env_sample file to create your own .env with values to REGISTRY and STORAGE_CONNECTION_STRING.
* In "Dockerfile" file, replace `<function-app-name>` with your function app name.
* In a terminal window, run the following commands:

  `cd Sample-Java-Azure-Function`

  `docker-compose up`

* Use Postman, Curl, or any web browser to test the sample function on port 9010.

  ex. `http://localhost:9010/api/HttpExample?name=abc`

# Azure DevOps Pipeline
### Prerequisites
Before using this,
- we expect you to have basic knowledge about:
  - [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)
  - [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)
- [A service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) created in your Azure DevOps.
- [Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) deployed in your Azure subscription for function logs.

### Usage
1.  Create a new repo with the attached pipeline file a long with Docker file and the Azure Function project in [Sample-Java-Azure-Function directory](./Sample-Java-Azure-Function).
2.  In "azure-pipeline.yml" file, replace `<image-name>` with your image name.
3.  In Azure DevOps, create and set the following variables:
    - SERVICE_CONNECTION_NAME
    - STORAGE_CONNECTION_STRING
4.  Use Azure devops to create a new pipeline with the Azure pipeline yaml configuration.
5.  Run the pipeline.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
