#!/bin/bash

for f in *.config; do
    base="${f%.config}"
    echo "Running FIRE7 on example ${base} (file: $f)"
    /app/FIRE7/bin/FIRE7 --config "$base" || echo "FIRE7 failed on example ${base}"
done
