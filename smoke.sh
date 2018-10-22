#!/bin/bash

#export SOCK_SHOP_URL=$(kubectl -n sock-shop get svc front-end --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
#SOCK_SHOP_URL=35.231.224.62

SOCK_SHOP_URL=$1
SOCK_SHOP_PORT=80
NUM_VUS=5
NUM_ITERATIONS=10

echo Running smoke test against $SOCK_SHOP_URL...
./launch_test.sh basiccheck.jmx results $SOCK_SHOP_URL $SOCK_SHOP_PORT $NUM_VUS $NUM_ITERATIONS "SmokeTest"
