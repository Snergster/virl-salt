#!/bin/bash

if pidof -x $1  >/dev/null
  then
     exit 0
  else
     exit 2
fi
