# README

## Launching

* Zip the contents of this repository and upload as Job inputs
* Select ANSYS Mechnical software tile
* Select hardware (1 node max)

Use the folllowing Command

```bash
export PYMAPDL_MAPDL_EXEC=`find /program/ -type f -name mapdl | head -1`
. launch.sh
```