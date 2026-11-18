# PHP proxy for Blazegraph

The container runs PHP 8.5 with Apache on port 5000. Composer installs the
dependencies from `composer.lock` when building the image.

## Local Docker build

```sh
docker build --pull -t php-proxy-for-blazegraph .
docker run --rm -p 127.0.0.1:5000:5000 \
  -e TRIPLESTORE_URL=https://blazegraph.example.org/blazegraph/namespace/kb/sparql \
  php-proxy-for-blazegraph
```

## INTAVIA deployment

Pull requests targeting `master` build and smoke-test the image. Pushes to
`master` and manual runs on `master` call the
[shared AutoDevOps workflows](https://github.com/acdh-oeaw/gl-autodevops-minimal-port)
to publish the image to GHCR and deploy its commit-derived tag with Helm on
ACDH Cluster 2. The shared Helm chart uses
`.github/auto-deploy-values.yaml` from this repository.

Create the GitHub environment `intavia` and set its variables and secrets
there. Keep the settings for any additional deployment in its own environment
and point its deploy job to that environment.

| Name | GitHub setting | Value |
| --- | --- | --- |
| `C2_KUBE_CONFIG` | Secret | Base64-encoded kubeconfig with access to the target namespace on Cluster 2. |
| `KUBE_NAMESPACE` | Variable | Existing namespace for the INTAVIA release. Without this setting the shared workflow uses `intavia-sparql`. |
| `K8S_SECRET_TRIPLESTORE_URL` | Variable or secret | Required upstream Blazegraph base URL. Store it as a secret if it contains sensitive details. |
| `K8S_SECRET_TRIPLESTORE_HOST_HEADER` | Variable | Optional upstream Host header. Defaults to the host from the upstream URL. |
| `K8S_SECRET_DB_USER`, `K8S_SECRET_DB_PASSWORD` | Secrets | Optional upstream HTTP Basic credentials. |
| `K8S_SECRET_CACHE_TIMEOUT` | Variable | Cache lifetime in seconds. Defaults to `604800`. |
| `K8S_SECRET_MAX_CACHE_SIZE` | Variable | Cache limit in bytes. Defaults to `536870912` (512 MiB). |
| `K8S_SECRET_WEB_CONCURRENCY` | Variable | Apache worker limit. Defaults to `8`. |
| `SERVICE_ID` | Variable | Optional Redmine ID for the Kubernetes `ID` label. |
| `PUBLIC_URL` | Variable | Optional public endpoint for the deployment link and Helm ingress. |
| `HELM_UPGRADE_EXTRA_ARGS` | Variable | Optional Helm overrides, such as an image pull secret or ingress settings. |

The release is named `intavia-sparql` and creates a ClusterIP service
`intavia-sparql-auto-deploy` on port `5000`. The readiness endpoint
`/healthz` verifies that the proxy is configured without querying Blazegraph.
The liveness command also prunes the local cache.

For the first rollout, keep the existing public route in place. After the
Helm workload is ready, point the existing Ingress in the target namespace at
`intavia-sparql-auto-deploy:5000`. If Helm will manage the Ingress, set
`PUBLIC_URL` and use `HELM_UPGRADE_EXTRA_ARGS` to enable the Ingress and set
the cluster's ingress class and TLS options. Use one Ingress owner per host.
