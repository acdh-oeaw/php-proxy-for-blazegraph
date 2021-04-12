# php proxy for Blazegraph

## Deployment on Kubernetes

To create new proxy for the Blazegraph database, clone this project to the new project, go to Gitlab --> Settings --> CI/CD --> Variables and add follwoing variables:

- KUBE_NAMESPACE yournamespace
- POSTGRES_ENABLED false
- TEST_DISABLED true
- SAST_DISABLED true
- PERFORMANCE_DISABLED true
- DOCKER_TLS_CERTDIR ""
- DOCKER_HOST tcp://docker:2375/
- DOCKER_DRIVER overlay2
- CODE_QUALITY_DISABLED true 
- HELM_UPGRADE_EXTRA_ARGS --set ingress.tls.enabled=false --set service.url=yourdomainforthebgproxy.acdh-dev.oeaw.ac.at --set livenessProbe.command=/app/kubernetesCheck.sh
- K8S_SECRET_TRIPLESTORE_URL http://193.170.85.102:8080/dbname
- K8S_SECRET_TRIPLESTORE_HOST_HEADER triplestore.acdh-dev.oeaw.ac.at
- K8S_SECRET_CACHE_TIMEOUT 604800
- K8S_SECRET_DB_USER dbuser 
- K8S_SECRET_DB_PASSWORD dbpassword
- K8S_MAX_CACHE_SIZE maximumCacheSizeInBytes
- WEB_CONCURRENCY 8

Some settings must be set up by hand in Rancher:

* The `ID` label with a Redmine issue ID
* Some health check settings (type `Command run inside the container exits with status 0`, command `/app/kubernetesCheck.sh`, it may also make sense to rise the default check interval to at least 60 seconds)

## Deployment on docker-tools

* Use `PHPL` environment
* Set `CACHE_TIMEOUT`, `DB_PASSWORD`, `DB_USER`, `TRIPLESTORE_HOST_HEADER` and `TRIPLESTORE_URL` (and optionally `CACHE_MAX_SIZE`) env vars in the config.yaml using the `EnvVars` configuration property.

