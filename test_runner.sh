#!/bin/sh
# set -x # Enable execution tracing (REMOVED FOR FINAL REPORT)

# Path to the modified script
TARGET_SCRIPT="./periodic-snapshot"

# Make sure the target script is executable
chmod +x "$TARGET_SCRIPT"

echo "### Test Case 1: Issue Example ###"
export snapshot_schedule="/j/jails/*:2:8:24@8 /j/jails/ftpsync-master,/j/jails/cgit:0:0:0@8 /j/jails/xyz:1:7:16@8"
export time_hour=8
echo "snapshot_schedule_case1='$snapshot_schedule', time_hour_case1=$time_hour, time_tag_case1='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true # grep || true to not fail if no output

echo ""
echo "### Test Case 2: Global Wildcard Only ###"
export snapshot_schedule="*:1:2:3@0,8,16"
export time_hour=8
echo "snapshot_schedule_case2='$snapshot_schedule', time_hour_case2=$time_hour, time_tag_case2='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true

echo ""
echo "### Test Case 3: Overlapping Wildcards ###"
export snapshot_schedule="/j/*:1:1:1@10 /j/jails/*:2:2:2@10 /j/jails/foo:3:3:3@10"
export time_hour=10
echo "snapshot_schedule_case3='$snapshot_schedule', time_hour_case3=$time_hour, time_tag_case3='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true

echo ""
echo "### Test Case 4: Default Time Specs ###"
export snapshot_schedule="/data/app1 /data/app2:1:1:1@10"
echo "Part 1: time_hour=12 (for app1 default)"
export time_hour=12
echo "snapshot_schedule_case4_part1='$snapshot_schedule', time_hour_case4_part1=$time_hour, time_tag_case4_part1='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true
echo "Part 2: time_hour=10 (for app2 specific and app1 no output)"
export time_hour=10
echo "snapshot_schedule_case4_part2='$snapshot_schedule', time_hour_case4_part2=$time_hour, time_tag_case4_part2='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true


echo ""
echo "### Test Case 5: Fallback to Global * & No Match ###"
export snapshot_schedule="/data/app1:1:1:1@10 *:0:0:2@12"
echo "Part 1: time_hour=10"
export time_hour=10
echo "snapshot_schedule_case5_part1='$snapshot_schedule', time_hour_case5_part1=$time_hour, time_tag_case5_part1='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true
echo "Part 2: time_hour=12"
export time_hour=12
echo "snapshot_schedule_case5_part2='$snapshot_schedule', time_hour_case5_part2=$time_hour, time_tag_case5_part2='hourly'"
sh "$TARGET_SCRIPT" "hourly" | grep "SNAPSHOT_TEST_OUTPUT:" || true
