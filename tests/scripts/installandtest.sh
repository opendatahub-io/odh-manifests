#!/bin/bash

set -x
/peak/install.sh
/peak/operator-tests/run.sh
set +x
if [ "$?" -ne 0 ]; then
    echo "The tests failed"
fi
