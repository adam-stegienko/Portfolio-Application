#!/bin/bash

pushd ./jenkins/ > /dev/null
    command docker compose up --detach
popd > /dev/null