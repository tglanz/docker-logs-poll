#!/bin/bash

idx=1000
while [ $idx -gt 0 ]; do
    echo "INDEX: $idx"
    sleep 1
    let idx=idx-1
done