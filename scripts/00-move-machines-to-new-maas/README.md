## Move machines from a MAAS installation to a new one

Modify `dumper.sh` according to your maas location and authentication. 

Modify `importer.sh` the same way and point to the new MAAS. 

Known limitations: 
- does not work for LXD power drivers
- only the first flag in the `workaround_flags` is reported for IPMI
