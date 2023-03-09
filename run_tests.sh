#!/bin/bash

run_inst () {

    while [ $# -gt 0 ] ; do
	eval $1
	shift
    done

    echo 3 > /proc/sys/vm/drop_caches 
    iostat \
	-N \
	-d \
	-c \
	-o JSON \
	1 > iostat_out.json &

    iostat_pid=$!
    sleep 1

    fio \
	--bs=128K \
	--direct=1 \
	--filename=$device \
	--group_reporting \
	--iodepth=$iodepth \
	--ioengine=$ioengine \
	--norandommap \
	--numjobs=$numjobs \
	--rw=$iopattr \
	--runtime=$duration \
	--time_based \
	--name=fiojob \
	--end_fsync=1 \
	--randrepeat=0 \
	--verify=0 \
	--ramp_time=5 \
	--output=fio_out.json \
	--output-format='json+' \
	--eta=never

    sleep 1
    kill -s SIGINT $iostat_pid
    wait $iostat_pid
    iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
    fio_out=$(<fio_out.json)
    echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . > "$fname"
    rm -rf fio_out.json iostat_out.json
}

run_tests () {

    while [ $# -gt 0 ] ; do
	eval $1
	shift
    done

    echo "Running write only test"
    run_inst device=$device iodepth=$iodepth numjobs=$numjobs ioengine=$ioengine iopattr=randwrite duration=$duration fname=write_out.json
    echo "Running read only test"
    run_inst device=$device iodepth=$iodepth numjobs=$numjobs ioengine=$ioengine iopattr=randread duration=$duration fname=read_out.json
    echo "Running rw test"
    run_inst device=$device iodepth=$iodepth numjobs=$numjobs ioengine=$ioengine iopattr=randrw duration=$duration fname=rw_out.json

    rw_out=$(< rw_out.json)
    read_out=$(< read_out.json)
    write_out=$(< write_out.json)

    rm -rf rw_out.json read_out.json write_out.json
    echo "{ \"rw\":$rw_out, \"read\":$read_out, \"write\":$write_out }" | jq --sort-keys --compact-output . > "$ofname"

}

device=/dev/asvg0/test
duration=60

run_tests device=$device iodepth=1 numjobs=16 ioengine=mmap duration=$duration ofname=baseline.json

echo "Creating dm-integrity backed device"
# Create integrity device
dd if=/dev/zero bs=1M of="$device" count=10 oflag=sync 2>/dev/null
integritysetup --batch-mode format $device
integritysetup open $device itest

run_tests device=/dev/mapper/itest iodepth=1 numjobs=16 ioengine=mmap duration=$duration ofname=integrity.json

integritysetup close itest
