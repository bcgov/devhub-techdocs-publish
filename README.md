# License
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE)

# DevHub TechDocs Publish
This repository contains the code and related artifacts for a [Docker container GitHub action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) that can be used in a GitHub Action workflow to build and publish TechDocs-compatible documentation to DevHub. In addition, the Docker image can be used by developers in their own environments to build and preview content. 

## Technical Details
The action defined in this repository is a [Docker container action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) that bundles up the [Backstage techdocs-cli](https://backstage.io/docs/features/techdocs/cli/) tool along with its `npm` and `python` dependencies, some plugins/extensions used by the [DevHub](https://github.com/bcgov/developer-portal/)  and some custom logic implemented in `bash`. 

Please take a look at the [documentation](docs/index.md) for instructions on how to make use of the Action or the Docker image.

## Project Status
- [x] Stable Beta

## Development

This section provides notes for developers working on maintaining or improving `devhub-techdocs-publish`.

### Using branches

Users of `devhub-techdocs-publish` are directed to use the `stable` version of the Action, which resolves to the contents of the `stable` branch of this repo. Given this, we want to keep `stable`, uh, stable, so will not want to use `stable` as our working branch. Instead, we will normally work in `main` and use a PR workflow to incorporate changes into `stable` when we want to make changes available to our users.

### Building

#### With GitHub Actions

The logic of `devhub-techdocs-publish` Action is implemented as a Docker image. The Docker image is automatically built on every push to `main` using the [docker_build.yml](./github/workflows) workflow file. Once a build succeeds, the resulting image will be available in the [repo's packages list](https://github.com/bcgov/devhub-techdocs-publish/pkgs/container/devhub-techdocs-publish).

#### Locally

The image can also be built locally using the following command, or equivalent if you are not using `docker`. (In this case, we are tagging the image with `devhub-publisher` to make it easier to identify. 

```shell
podman build --tag=devhub-publisher .
```

### Testing

To test that the image is working as expected, you can run the locally-built image (see [local build](#locally)) using the instructions below.

> Note: these instructions only user the build and preview functionality of the image. The publishing functions require additional credentials. Contact the developers on the Developer Experience team for guidance on testing publishing locally.

```shell
podman run -it -p 3000:3000 -v $(pwd):/github/workspace devhub-publisher preview
```

If successful, you will be able to open a browser to [http://localhost:3000](http://localhost:3000) to see the TechDocs for this repository rendered in a DevHub-like format.

### Tagging and publishing

Once you have changes that you're happy with in `main` and would like to make them available in the `stable` version, you'll need to take the following steps:

- test your changes locally
- push your changes to the `main` branch of the repo in GitHub and 
- check that an image was built successfully with the GitHub Action that has your changes
- find the current highest version tag using `git tag`.
- run `./tag.sh <new tag>`, where `<new tag>` is the current highest tag incremented by 1. For example, if the current version is `v0.0.20`, `<new tag>` would be `v0.0.21`. 

Running the `tag.sh` command will:

- update the `action.yml` file to point to a Docker image in GitHub packages tagged with  `<new tag>` 
- commit the updated `action.yml` file locally 
- create a new `git` tag with the value of `<new tag>`
- push the local commit and the new tag to GitHub 

Once this completes, a new image will be built by the GitHub Action, tagged with the value of `<new tag>`.

So, the last part of the publishing a new version of the Action is to make a pull request from the `main` branch into the `stable` so users of the `stable` version will be using the new image you just created. This feels kind of "backwards" to be merging *from* `main` but that's what you want to in this situation.  Once the PR is merged, users making use of the `stable` version of the Action from their workflow files will get the latest changes you've just made.

### Rolling back `stable`

If for some reason, you need to revert `stable` to a prior version of an image, this can be done by editing the image tag referenced in `action.yml` in the `stable` branch to point to a prior version. (this can be done directly vs. a PR). Keep in mind, that if the `action.yml` or other files in the repo aren't compatible with the image version you're now pointing to (e.g. Action input parameters or mkdocs plugins have changed), this may not work on its own and other edits may be needed. In this case, it may be best to have `git` help with the rollback. (`git revert`, for e.g.)  

## License
    Copyright 2024 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
