# DevHub TechDocs Publish GitHub Action

This is the documentation for the DevHub TechDocs Publisher GitHub Action. The DevHub TechDocs Publisher GitHub Action makes is easy for DevHub Content Partners to implement a CI job that will publish their content to DevHub.

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
            -   name: Build TechDocs
                uses: bcgov/devhub-techdocs-publish@stable  # `stable` will also get the most stable, working version of the Action. If you are asked or wish to use a specific version, you can update this value as needed.  
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

Change to your local clone of your documentation repo:

```shell
cd <your folder or repo with mkdocs.yml and docs folder>
```

If you're using `docker` or `colima`, pull the image and use it to preview your content as follows:
```shell
docker pull ghcr.io/bcgov/devhub-techdocs-publish:v0.0.19
docker run -it -p 3000:3000 -v $(pwd):/github/workspace ghcr.io/bcgov/devhub-techdocs-publish preview
```

If you're using `podman`, pull the image and use it to preview your content as follows:
```
podman pull ghcr.io/bcgov/devhub-techdocs-publish:v0.0.19
podman run -it -p 3000:3000 -v $(pwd):/github/workspace ghcr.io/bcgov/devhub-techdocs-publish preview
```

The above commands will:

- generate HTML from your markdown documents using a standard set of plugins/extensions for DevHub compatibility
- start a "preview" web server on [http://localhost:3000](http://localhost:3000) for you to review your content.

