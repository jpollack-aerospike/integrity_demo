#!/bin/bash

DURATION=60
NUMJOBS=16
IODEPTH=16
TEST_DEV=/dev/asvg0/test

dd if=/dev/zero bs=1M of="$TEST_DEV" count=10 oflag=sync

# randwrite
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
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randwrite \
    --runtime=$DURATION \
    --time_based \
    --name=randwrite \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >write-normal.json
rm -rf fio_out.json iostat_out.json

# randread
echo 3 > /proc/sys/vm/drop_caches 
iostat \
    -N \
    -d \
    -c \
    -o JSON \
    1  > iostat_out.json &

iostat_pid=$!
sleep 1

fio \
    --bs=128K \
    --direct=1 \
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randread \
    --runtime=$DURATION \
    --time_based \
    --name=randread \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >read-normal.json
rm -rf fio_out.json iostat_out.json

# randrw
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
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randrw \
    --runtime=$DURATION \
    --time_based \
    --name=randrw \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >rw-normal.json
rm -rf fio_out.json iostat_out.json

# Create integrity device
dd if=/dev/zero bs=1M of="$TEST_DEV" count=10 oflag=sync
integritysetup --batch-mode format $TEST_DEV
integritysetup open $TEST_DEV itest

# Collect integrity stats 
TEST_DEV=/dev/mapper/itest

# randwrite
echo 3 > /proc/sys/vm/drop_caches 
iostat \
    -N \
    -d \
    -c \
    -o JSON \
    1  > iostat_out.json &

iostat_pid=$!
sleep 1

fio \
    --bs=128K \
    --direct=1 \
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randwrite \
    --runtime=$DURATION \
    --time_based \
    --name=randwrite \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >write-integrity.json
rm -rf fio_out.json iostat_out.json

# randread
echo 3 > /proc/sys/vm/drop_caches 
iostat \
    -N \
    -d \
    -c \
    -o JSON \
    1  > iostat_out.json &

iostat_pid=$!
sleep 1

fio \
    --bs=128K \
    --direct=1 \
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randread \
    --runtime=$DURATION \
    --time_based \
    --name=randread \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >read-integrity.json
rm -rf fio_out.json iostat_out.json

# randrw
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
    --filename=$TEST_DEV \
    --group_reporting \
    --iodepth=$IODEPTH \
    --ioengine=mmap \
    --norandommap \
    --numjobs=$NUMJOBS \
    --rw=randrw \
    --runtime=$DURATION \
    --time_based \
    --name=randrw \
    --output=fio_out.json \
    --output-format=json

sleep 1
kill -s SIGINT $iostat_pid
wait $iostat_pid
iostat_out=$(jq .sysstat.hosts[0].statistics iostat_out.json)
fio_out=$(<fio_out.json)
echo "{ \"fio\":$fio_out, \"iostat\":$iostat_out }" | jq --sort-keys --compact-output . >rw-integrity.json
rm -rf fio_out.json iostat_out.json

integritysetup close itest
