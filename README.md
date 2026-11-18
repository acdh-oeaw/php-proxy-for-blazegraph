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

## Deployment

Pull requests targeting the default branch build and smoke-test the image.
Pushes to the default branch and manual runs from it use `.github/workflows/starter.yaml`
to call the
[shared AutoDevOps workflows](https://github.com/acdh-oeaw/gl-autodevops-minimal-port)
to publish the image to GHCR and deploy its commit-derived tag with Helm
to the cluster selected by the target environment. The shared Helm chart uses
`.github/auto-deploy-values.yaml` from this repository.

Create a GitHub environment for each deployment and configure its variables
and secrets below. Pushes use the environment named by the repository variable
`DEPLOY_ENVIRONMENT`, or `production` if that variable is unset. A manual run
can select a different environment.

| Name | GitHub setting | Value |
| --- | --- | --- |
| `KUBE_CONFIG` | Secret | Base64-encoded kubeconfig with deploy permissions in the target namespace. |
| `KUBE_NAMESPACE` | Variable | Required. Existing Kubernetes namespace for this deployment. |
| `APP_NAME` | Variable | Optional Helm release name of up to 24 characters. Defaults to the normalized repository name. |
| `K8S_SECRET_TRIPLESTORE_URL` | Variable or secret | Required upstream Blazegraph base URL. Store it as a secret if it contains sensitive details. |
| `K8S_SECRET_TRIPLESTORE_HOST_HEADER` | Variable | Optional upstream Host header. Defaults to the host from the upstream URL. |
| `K8S_SECRET_DB_USER`, `K8S_SECRET_DB_PASSWORD` | Secrets | Optional upstream HTTP Basic credentials. |
| `K8S_SECRET_CACHE_TIMEOUT` | Variable | Cache lifetime in seconds. Defaults to `604800`. |
| `K8S_SECRET_MAX_CACHE_SIZE` | Variable | Cache limit in bytes. Defaults to `536870912` (512 MiB). |
| `K8S_SECRET_WEB_CONCURRENCY` | Variable | Apache worker limit. Defaults to `8`. |
| `SERVICE_ID` | Variable | Optional Redmine ID for the Kubernetes `ID` label. |
| `PUBLIC_URL` | Variable | Optional public endpoint for the deployment link and Helm Ingress. |
| `KUBE_INGRESS_BASE_DOMAIN` | Variable | Optional domain suffix for generating a public URL when `PUBLIC_URL` is unset. |
| `HELM_UPGRADE_EXTRA_ARGS` | Variable | Optional Helm overrides, such as an image pull secret or ingress settings. |

The shared chart creates a ClusterIP service named `<release>-auto-deploy`
on port `5000`. The readiness endpoint
`/healthz` verifies that the proxy is configured without querying Blazegraph.
The liveness command also prunes the local cache.

The deployment identity needs to list Pods and manage Deployments, Services,
and Secrets in the namespace. Helm also needs read access to ReplicaSets to
check rollout readiness.

For the first rollout, keep the existing public route in place. After the
Helm workload is ready, point the existing Ingress in the target namespace at
`<release>-auto-deploy:5000`. If Helm will manage the Ingress, set
`PUBLIC_URL` and use `HELM_UPGRADE_EXTRA_ARGS` to enable the Ingress and set
the cluster's ingress class and TLS options. Use one Ingress owner per host.
