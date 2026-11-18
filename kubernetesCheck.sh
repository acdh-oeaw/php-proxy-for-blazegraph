#!/bin/sh
# Check the HTTP listener and prune the local proxy cache.
set -eu

curl --fail --silent --show-error --max-time 5 --output /dev/null "http://127.0.0.1:${PORT:-5000}/healthz"

if [ -n "${MAX_CACHE_SIZE:-}" ]; then
    set -- "$MAX_CACHE_SIZE"
else
    set --
fi
exec php /app/clearCache.php "$@"
