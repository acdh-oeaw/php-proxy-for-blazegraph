# PHP proxy for Blazegraph

The container runs PHP 8.5 with Apache and listens on port 5000 by default.
Composer installs the dependencies from `composer.lock` during the image build.

## Local Docker build

```sh
docker build --pull -t php-proxy-for-blazegraph .
docker run --rm -p 127.0.0.1:5000:5000 \
  -e TRIPLESTORE_URL=https://blazegraph.example.org/blazegraph/namespace/kb/sparql \
  php-proxy-for-blazegraph
```

## Deployment on Kubernetes

1. Create or update the Rancher workload with the image
   `ghcr.io/acdh-oeaw/php-proxy-for-blazegraph:latest` and container port `5000`.
2. Configure the environment variables for the workload.

   | Variable | Value |
   | --- | --- |
   | `TRIPLESTORE_URL` | Required. Base URL of the upstream Blazegraph endpoint. |
   | `TRIPLESTORE_HOST_HEADER` | Optional upstream Host header. Defaults to the host in `TRIPLESTORE_URL`. |
   | `CACHE_TIMEOUT` | Cache lifetime in seconds. Defaults to `604800`. |
   | `DB_USER`, `DB_PASSWORD` | Optional upstream HTTP Basic credentials. |
   | `MAX_CACHE_SIZE` | Cache size limit in bytes. Defaults to `536870912` (512 MiB). |
   | `WEB_CONCURRENCY` | Maximum number of Apache workers. Defaults to `8`. |

3. Set the Rancher `ID` label to the Redmine issue ID and configure the existing
   command probe to run `/app/kubernetesCheck.sh`. The command checks the local
   HTTP listener and prunes the cache. Use a probe interval of at least 60 seconds
   if the cache is large.

## GitHub Actions

Pull requests targeting `master` build and smoke-test the container. A push to
`master` also publishes the tested image to GHCR with the commit SHA and
`latest` tags, then requests redeploys for ARCHE SPARQL and SK SPARQL.

The redeploy jobs use the repository secrets `RANCHERURL_ARCHE_SPARQL`,
`RANCHERURL_SK_SPARQL`, and `RANCHER_BARER_TOKEN`. To add another workload,
create its Rancher URL secret and add it to the deployment matrix in
`.github/workflows/build-and-deploy.yml`.

## Deployment on docker-tools

* Use a `PHPL` environment with PHP 8.5 and the cURL extension, and install the
  dependencies with Composer.
* Set `TRIPLESTORE_URL` and any optional environment variables in the
  `EnvVars` property of `config.yaml`.
