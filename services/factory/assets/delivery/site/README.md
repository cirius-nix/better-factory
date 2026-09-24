# Documentation site

This project renders the `docs/` tree as one browsable site with Docusaurus.
The file `site.json` holds the site settings and the derived feature order.
Run the site locally with `npm install` and `npm start` in this folder.
Build the site with `npm run build` in this folder.

## Manual steps

The factory cannot make repository settings and cannot create cloud resources.
Do these steps by hand after the first generation.

1. For the `github-pages` target: set the Pages source in the repository
   settings to GitHub Actions, or to the `gh-pages` branch when the CI
   provider is `azure-pipelines`.
2. For the `azure-static-web-app` target: create one Static Web App resource
   in Azure.
3. Copy the deployment token of the resource.
4. Store the token as a CI secret with the name `SITE_SWA_DEPLOYMENT_TOKEN`.
5. Set the site `url` and `baseUrl` values to the Static Web App address.
