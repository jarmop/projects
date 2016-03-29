#!/usr/bin/env bash

# IE crap
mkdir -p app/vendor
cp node_modules/es6-shim/es6-shim.min.js app/vendor
cp node_modules/systemjs/dist/system-polyfills.js app/vendor
cp node_modules/angular2/es6/dev/src/testing/shims_for_IE.js app/vendor

uglifyjs -o app/vendor.min.js \
    node_modules/angular2/bundles/angular2-polyfills.js \
    node_modules/systemjs/dist/system.src.js \
    node_modules/rxjs/bundles/Rx.js \
    node_modules/angular2/bundles/angular2.dev.js