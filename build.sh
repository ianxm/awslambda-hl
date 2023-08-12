#!/bin/bash

haxe build.hxml

exitcode=$?
if [ $exitcode -ne 0 ]; then
    echo build failed
    exit $exitcode
fi

mkdir -p dist
rm -f dist/*.zip

cd bin && zip -ry ../dist/lambda_handler.zip * && cd ..

LIBNAME=awslambda-hl

if [ -a "$LIBNAME.zip" ]; then
    rm -f "$LIBNAME.zip"
fi
zip -r "$LIBNAME.zip" haxelib.json src bin/bootstrap bin/lib LICENSE lgpl-3.0.txt README.md
echo "Saved as $LIBNAME.zip"

# update lambda function with something like
# aws lambda update-function-code --function-name HashLinkTest --zip-file fileb://dist/lambda_handler.zip
