
# Gleam OpenWhisk function templates

<p align="center">
  <img src="preview/logo.png" />
</p>

This repository contains [OpenWhisk](https://openwhisk.apache.org/) function templates for writing serverless functions in the [Gleam](https://github.com/gleam-lang/gleam) programming language.

## Usage

1. Make sure OpenWhisk has been deployed to your Kubernetes cluster and the OpenWhisk CLI tool has been installed. See [here](https://github.com/NicklasXYZ/selfhosted-serverless) and [here](https://github.com/NicklasXYZ/selfhosted-serverless/blob/main/OpenWhisk.md) for a brief introduction on how to do this.

2. Download the Gleam function templates from this repo and enter into the main directory:

```bash
git clone https://github.com/nicklasxyz/gleam_openwhisk && \
cd gleam_openwhisk
```

3. Add new functionality to the function that is going to be deployed and managed by OpenWhisk:

``` bash
vim template/function/src/function.gleam
# ... Extend or add whatever you want to the 'run' function  
```

Note: The files and directories in the `template` directory are a part of a usual Gleam project, but structured specifically for use with OpenWhisk. All new functionality should primarily be implemented as a part of the `function` module residing in the `gleam_openwhisk/template/function/` directory. Extra dependencies should be added to the `rebar.config` file in the root of the `template` directory. The project can be compiled and tested locally as usual.

4. Build and push the function:

```bash
# Define your docker image name and function name below
export FUNC_NAME=  # For example: test-function
export IMAGE_NAME= # For example: username/test-function:latest

# Then build and push the docker image to Docker Hub:
docker build template --tag $IMAGE_NAME && docker push $IMAGE_NAME
```

5. Create a package and deploy the serverless function:

```bash
wsk -i package create demo && \
wsk -i action create /guest/demo/$FUNC_NAME --docker $IMAGE_NAME --web true

# To remove function deployments run:
wsk -i action delete /guest/demo/$FUNC_NAME
```

6. Wait a few seconds, then we can invoke the function by sending a request through curl:

```bash
### Retrieve function invocation URL
export FUNC_URL=$(wsk -i action get /guest/demo/$FUNC_NAME --url | tail -1)

### Example POST request:
curl -k \
    -d "{\"name\": \"YourNameHere\"}" \
    -H "Content-Type: application/json" \
    -X POST $FUNC_URL; \
    echo

# If nothing was changed in the 'gleam_openwhisk/template/function/src/function.gleam'
# file before deployment then we should just see the default response:
>> {"int_field":42,"string_field":"Hello YourNameHere, from Gleam & OpenWhisk!"}

# The function can also be invoked from the commandline via the OpenWhisk CLI:
wsk -i action invoke /guest/demo/$FUNC_NAME --result --param name YourNameHere
```

For more information on how GET, POST, PUT and DELETE methods work see the [OpenWhisk API gateway docs](https://github.com/apache/openwhisk/blob/master/docs/apigateway.md)

## Acknowledgements

The general webserver setup is taken from [this repository](https://github.com/gleam-lang/example-echo-server) by [gleam-lang](https://github.com/gleam-lang).
