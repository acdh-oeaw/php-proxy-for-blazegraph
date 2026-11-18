#!/bin/sh
# Check the HTTP listener and prune the local proxy cache.
set -eu

curl --silent --show-error --output /dev/null "http://127.0.0.1:${PORT:-5000}/"

if [ -n "${MAX_CACHE_SIZE:-}" ]; then
    set -- "$MAX_CACHE_SIZE"
else
    set --
fi
exec php /app/clearCache.php "$@"
