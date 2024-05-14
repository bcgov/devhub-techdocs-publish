# DevHub TechDocs Publish GitHub Action

This is the documentation for the DevHub TechDocs Publisher GitHub Action. The DevHub TechDocs Publisher GitHub Action makes is easy for DevHub Content Partners to implement a CI job that will publish their content to [DevHub](https://developer.gov.bc.ca).

> Note: The instructions below presume you are part of a B.C. government development team and have been in touch with the B.C. government [Developer Experience Team](mailto:developer.experience@gov.bc.ca) for orientation to DevHub. The workflow below will not work until the Developer Experience has given you access to certain protected values that it uses (those in `${{ secrets... }` below). You *may* be able to make use of the action to publish to other Backstage environments, but these instructions won't cover that scenario.

## How to use the GitHub Action

If you wish to make use of the Action to publish documentation to DevHub, you should define a GitHub Action workflow file in the `..github/workkflows` directory within the repository containing the markdown-based documentation you wish to publish. Ideally, source markdown files are in the a `docs` folder in the root of the repo. The example workflow file below should be usable as-is in many cases. Refer to the inline comments for guidance on making changes to suit your team's needs.  

```yaml
name: Build TechDocs with DevHub TechDocs Publish Action


# You are free to alter the trigger rules within the `on:` section based on your team's workflow. As-is, the workflow will run on changes to files matching the  indicated patterns in `path`  contained in any push to the `main` branch or any pull request targeted at the `main` branch. 
on:
    workflow_dispatch:
    push:
        branches: [ main ]
        paths:
            - "mkdocs.yml"
            - "catalog-info.yml"
            - "docs/*"
    pull_request:
        branches: [ main ]
        paths:
            - "mkdocs.yml"
            - "catalog-info.yml"
            - "docs/*"

jobs:
    techdocs_build_job:
        runs-on: ubuntu-latest

        name: A job to build and publish techdocs content
        steps:
            -   name: Checkout
                uses: actions/checkout@v4
				with:
					fetch-depth: 0
            -   name: Build TechDocs
                uses: bcgov/devhub-techdocs-publish@stable  # `stable` will always get the most stable, working version of the Action. If you are asked or wish to use a specific version, you can update this value as needed.  Note `stable` in this case is a GitHub branch *not* a Docker tag.
                id: build_and_publish
                with:
                    publish: 'true'
                    production:  ${{ github.ref == 'refs/heads/main' && 'true' || 'false' }} # You may also wish change the logic in the `production` flag. This example only pushes to the prod DevHub backend when the changes that triggered the job are in `main` branch 
                    bucket_name: ${{ secrets.TECHDOCS_S3_BUCKET_NAME }}
                    s3_access_key_id: ${{ secrets.TECHDOCS_AWS_ACCESS_KEY_ID }}
                    s3_secret_access_key: ${{ secrets.TECHDOCS_AWS_SECRET_ACCESS_KEY }}
                    s3_region: ${{ secrets.TECHDOCS_AWS_REGION }}
                    s3_endpoint: ${{ secrets.TECHDOCS_AWS_ENDPOINT }}
```

## How to use the Docker image to preview content locally

If you have a local folder or repo containing markdown content for which you wish to view a "preview" to get an idea of what it would look like in DevHub, you can use the Docker image, as shown below.

- Change to your local clone of your documentation repo:

```shell
cd <your folder or repo with mkdocs.yml and docs folder>
```

- If you're using `docker` or `colima`, pull the image and use it to preview your content as follows:

```shell
docker pull ghcr.io/bcgov/devhub-techdocs-publish
docker run -it -p 3000:3000 -v $(pwd):/github/workspace ghcr.io/bcgov/devhub-techdocs-publish preview
```

- If you're using `podman`, pull the image and use it to preview your content as follows:

```shell
podman pull ghcr.io/bcgov/devhub-techdocs-publish
podman run -it -p 3000:3000 -v $(pwd):/github/workspace ghcr.io/bcgov/devhub-techdocs-publish preview
```

The above commands will:

- generate HTML from your Markdown documents using a standard set of plugins/extensions for DevHub compatibility
- validate the links in the generated HTML files using [`htmltest`](#link-validation-using-htmltest)
- start a "preview" web server on [http://localhost:3000](http://localhost:3000) for you to review your content.

## Link validation using `htmltest`

The GitHub Action has a built-in capability to check links in HTML pages that are generated from source Markdown files. This capability uses a tool called [`htmltest`](https://github.com/wjdp/htmltest). 

If `htmltest` detects errors during its run against gneerated HTML files, they will show up in the action log as shown below. 

```
Successfully built content. Continuing.
Using default htmltest configuration file.
htmltest started at 12:46:44 on site
========================================================================
content-partner-guide/index.html
  alt text empty --- content-partner-guide/index.html --> ../images/devhub_appearance.png
rocketchat/steps-to-join-rocketchat/index.html
  hash does not exist --- rocketchat/steps-to-join-rocketchat/index.html --> #join-rocketchat-with-github-acount
use-github-in-bcgov/github-enterprise-user-licenses-bc-government/index.html
  Non-OK status: 404 --- use-github-in-bcgov/github-enterprise-user-licenses-bc-government/index.html --> https://github.com/bcgoc
use-github-in-bcgov/bc-government-organizations-in-github/index.html
  hash does not exist --- use-github-in-bcgov/bc-government-organizations-in-github/index.html --> #ministry-specific-private-organizations-in-github-enterprise
welcome-to-bc-gov/index.html
  target does not exist --- welcome-to-bc-gov/index.html --> /docs/
  target does not exist --- welcome-to-bc-gov/index.html --> /docs/default/component/platform-developer-docs/docs/openshift-projects-and-access/grant-user-access-openshift/
  target does not exist --- welcome-to-bc-gov/index.html --> /docs/default/component/platform-developer-docs/docs/training-and-learning/training-from-the-platform-services-team/
  target does not exist --- welcome-to-bc-gov/index.html --> /docs/default/component/public-cloud-techdocs/provision-a-project-set/#account-access
  target does not exist --- welcome-to-bc-gov/index.html --> /docs/default/component/platform-developer-docs/#training-and-learning
content-syntax-guide/index.html
  target does not exist --- content-syntax-guide/index.html --> /docs/default/component/mobile-developer-guide/meetups/
  target does not exist --- content-syntax-guide/index.html --> ../../mobile-developer-guide/meetups/
  target does not exist --- content-syntax-guide/index.html --> ../../mobile-developer-guide/meetups/
accessibility-resources/index.html
  Non-OK status: 503 --- accessibility-resources/index.html --> https://www.w3.org/WAI/eval/report-tool/evaluation/define-scope
  Non-OK status: 503 --- accessibility-resources/index.html --> https://www.w3.org/TR/WCAG22/
========================================================================
✘✘✘ failed in 46.230009005s
14 errors in 21 documents
/entrypoint.sh: line 80: htmltest: command not found
Link validation with  failed. The workflow will continue because strict validation is not enabled. Please refer to documentation at https://github.com/bcgov/devhub-techdocs-publish/blob/main/docs/index.md and https://github.com/wjdp/htmltest for assistance fixing errors or configuring htmltest.
```

Ideally, teams will use this output to remedy the errors so none show up and the html status is "green" and output is as shown below.

```
Successfully built content. Continuing.
Using provided htmltest configuration file: './.htmltest.yml'.
htmltest started at 12:57:04 on site
========================================================================
✔✔✔ passed in 3.060296912s
tested 2 documents
```

### Enabling strict validation (failing build when there are link errors)

How link validation errors impact the workflow run is controlled with the optional action parameter `strict_validation`. With the example workflow file above, the `strict_validation` isn't present, and `htmltest` will validate links, but the workflow run will not fail if link validation errors are encountered.  Setting `strict_validation` to `true` will cause the run to fail if any errors are encountered.  A snippet from a workflow file with this value set is shown below.

```yaml
...
	id: build_and_publish
	with:
		strict_validation: 'true'
		publish: 'false'
...
```

### Configuring `htmltest`

The fine-grained behaviour of `htmltest` is controlled by a configuration file called `.htmltest.yml`. The action will look for an `.htmltest.yml` file in the root of the repository that the Action is running against. If no file is found, a default one is provided within the action with "sensible defaults". A reference for the configuration options for this file can be found in the [`htmltest` documentation](https://github.com/wjdp/htmltest). An annotated version of the default file is provided below.

```yaml
CheckLinks: false # don't check URLs in <link> elements
IgnoreDirectoryMissingTrailingSlash: true # don't fail when directory links don't have a trailing slash - techdocs generates a lot of valid links that would cause this check to fail
IgnoreURLs:
    - "localhost" # suppress failures of URLs containing localhost
```

If users of the action wish to provide their own `.htmltest.yml` they will likely want to include most or all of the above settings in their own file, along with any additions of their own.

#### Configuring `htmltest` to ignore specific links 

The `data-proofer-ignore` attribute referenced in the `IgnoreTagAttribute` value in the default `.htmltest.yml` above, file is useful for links that require authentication, or that aren't available in the environment where the action runs, or that otherwise will commonly cause validation failures. See below for an example of adding this attribute to a link. In this case, the link requires authentication, so would fail validation if it did not have the `data-proofer-ignore` attribute. Note the example below is using the [Python-Markdown syntax](https://python-markdown.github.io/extensions/attr_list/) to add an attribute to a Markdown link.

 ```markdown
 [text external link that requires authentication](https://ssbc-client.gov.bc.ca/services/AppHosting/base.htm#databackup){:data-proofer-ignore}
 ```

# License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

