CPUS=2
PARALLELISM=3
TESTER_TIMEOUT=7200
platforms=(FreeBSD_32)

export LIBRARY_PATH=/usr/local/lib
