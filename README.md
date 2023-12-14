# License
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE)

# DevHub TechDocs Publish
This repository contains the code and related artifacts for a [Docker container GitHub action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) that can be used in a GitHub Action workflow to build and publish TechDocs-compatible documentation to DevHub. In addition, the Docker image can be used by developers in their own environments to build and preview content. 

## Technical Details
The action defined in this repository is a [Docker container action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) that bundles up the [Backstage techdocs-cli](https://backstage.io/docs/features/techdocs/cli/) tool along with its `npm` and `python` dependencies, some plugins/extensions used by the [DevHub](https://github.com/bcgov/developer-portal/)  and some custom logic implemented in `bash`. 

Please take a look at the [documentation](docs/index.md) for instructions on how to make use of the Action or the Docker image.

## Project Status
- [x] Stable Beta

## License
    Copyright 2023 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
