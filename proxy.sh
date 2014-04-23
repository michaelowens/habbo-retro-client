#!/bin/sh

DEBUG=* coffee app_proxy.coffee
trap "kill 0" SIGINT SIGTERM EXIT
