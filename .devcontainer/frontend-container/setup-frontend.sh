#!/bin/sh

sed -i 's|__API_URL__|http://localhost:8002/api|g' src/environments/environment.ts

apk add --no-cache nodejs npm
npm install
