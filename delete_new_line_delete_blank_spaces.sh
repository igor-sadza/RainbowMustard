#!/bin/bash

sed -i -e ':a;N;$!ba;s/\n/ /g' -e 's/ //g' $1
