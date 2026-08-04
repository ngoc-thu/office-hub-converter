#!/bin/bash
set -Eeuo pipefail

# Start Gotenberg in background on internal port 3001
gotenberg --api-timeout=120s --api-disable-health-check-route-telemetry=true --libreoffice-restart-after=10 --api-port=3001 &
gotenberg_pid=$!

# Wait up to 120 seconds for Gotenberg, failing the container if it exits.
echo "Waiting for Gotenberg to start..."
for _ in $(seq 1 120); do
    if curl --fail --silent http://127.0.0.1:3001/health > /dev/null; then
        break
    fi
    if ! kill -0 "$gotenberg_pid" 2>/dev/null; then
        wait "$gotenberg_pid"
        exit $?
    fi
    sleep 1
done

if ! curl --fail --silent http://127.0.0.1:3001/health > /dev/null; then
    echo "Gotenberg did not become healthy within 120 seconds" >&2
    kill -TERM "$gotenberg_pid" 2>/dev/null || true
    wait "$gotenberg_pid" 2>/dev/null || true
    exit 1
fi

echo "Gotenberg is ready!"

# Keep both processes supervised. If either one exits, terminate the other so
# Render restarts the whole service instead of leaving a broken Nginx process.
nginx -g "daemon off;" &
nginx_pid=$!

shutdown() {
    kill -TERM "$nginx_pid" "$gotenberg_pid" 2>/dev/null || true
    wait "$nginx_pid" "$gotenberg_pid" 2>/dev/null || true
}

trap shutdown TERM INT

set +e
wait -n "$gotenberg_pid" "$nginx_pid"
status=$?
set -e

shutdown
exit "$status"
