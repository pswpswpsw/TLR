#! /bin/bash

ql_list="0.99"
systems="lorenz"
sim_list="chaotic"

for system in $systems; do
    for ql in $ql_list; do
        for chaos_str in $sim_list; do
            echo " "
            echo python3 driver_lorenz_plotting.py ../data/datasets ${system}_${chaos_str} $ql 50 0
            python3 driver_lorenz_plotting.py ../data/datasets ${system}_${chaos_str} $ql 50 0
        done
    done
done