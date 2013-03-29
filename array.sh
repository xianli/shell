#!/bin/bash
hosts=(192.168.131.10 192.168.131.10 192.168.131.10)
ports=(12000 12010 12020)
for ((i=0;i<3;i=i+1)) do
(
sleep 5;
echo "flush_all";
) | telnet ${hosts[$i]} ${ports[$i]}
done