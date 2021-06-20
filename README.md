
# OpenWhisk Gleam function templates

This repository contains [OpenWhisk](https://openwhisk.apache.org/) function templates for writing serverless functions in [Gleam](https://github.com/gleam-lang/gleam).

## Usage

1. Make sure OpenWhisk has been deployed to your Kubernetes cluster and the OpenWhisk CLI tool has been installed. See [here](./setup/OpenWhisk.md) for a brief introduction on how to easily do this.

2. Download the Gleam function templates from this repo and enter into the main directory:

```bash
git clone https://github.com/nicklasxyz/gleam_openwhisk#main && \
cd gleam_openwhisk
```

3. Add new functionality to the function that is going to be deployed and managed by OpenWhisk:

``` bash
vim template/function/src/function.gleam
# ... Extend or add whatever you want to the 'run' function.  
```

NOTE: The files and directories in the `template` directory are a part of a usual Gleam project, but structured specifically for use with OpenWhisk. All new functionality should primarily be implemented as a part of the `function` module residing in the `gleam_openwhisk/template/function/` directory.

4. Build, push and deploy the function:

```bash
# Define your docker image name and function name below
export IMAGE_NAME=
export FUNC_NAME=

# Then build and push the docker image to Docker Hub:
docker build template --tag $IMAGE_NAME && docker push $IMAGE_NAME
```

5. Create a package and a serverless funtion:

```bash
wsk -i package create demo && \
wsk -i action create /guest/demo/$FUNC_NAME --docker $IMAGE_NAME --web true
```

6. Trigger the serverless function:

```bash
# A: By invoking the fucntion from the commandline:
wsk -i action invoke /guest/demo/$FUNC_NAME --result --param name YourNameHere
#... This can take a few seconds the first time the function is invoked

# B: By retrieving and sending a request to the URL that triggers the action:
# * Retrieve URL
wsk -i action get /guest/demo/$FUNC_NAME --url

# * Send POST request through curl
curl -k -d '{"value": {"name": "YourNameHere"}}' -H "Content-Type: application/json" -X POST https://localhost:31001/api/v1/web/guest/demo/$FUNC_NAME; echo
#... Use flag '-k to accept self-signed certificates
```

For more information on how GET, POST, PUT and DELETE methods work, see the [OpenWhisk API gateway docs](https://github.com/apache/openwhisk/blob/master/docs/apigateway.md)

## Acknowledgements

The general webserver setup is taken from [this repository](https://github.com/gleam-lang/example-echo-server) by [gleam-lang](https://github.com/gleam-lang).