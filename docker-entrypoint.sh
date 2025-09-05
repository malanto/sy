#!/bin/sh

if [ ! -e "config/config.yaml" ]; then
    echo "Resource not found, copying from defaults: config.yaml"
    cp -r "default/config.yaml" "config/config.yaml"
fi

# Execute postinstall to auto-populate config.yaml with missing values
npm run postinstall

./history/launch.sh env && ./history/launch.sh init
exec node server.js --listen "$@"
