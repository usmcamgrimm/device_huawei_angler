#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

function get-set-forall() {
    for f in $1 ; do
        cat $f
        write $f $2
    done
}

################################################################################

# disable thermal bcl hotplug to switch governor
write /sys/module/msm_thermal/core_control/enabled 0
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
bcl_hotplug_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask 0`
bcl_hotplug_soc_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask 0`
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# some files in /sys/devices/system/cpu are created after the restorecon of
# /sys/. These files receive the default label "sysfs".
# Restorecon again to give new files the correct label.
restorecon -R /sys/devices/system/cpu

# ensure at most one A57 is online when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

#LITTLE
write /sys/devices/system/cpu/cpu0/online 1
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1708800

write /sys/devices/system/cpu/cpu1/online 1
write /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq 1708800

write /sys/devices/system/cpu/cpu2/online 1
write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq 1708800

write /sys/devices/system/cpu/cpu3/online 1
write /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq 1708800

#big.
write /sys/devices/system/cpu/cpu4/online 1
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 1958400

write /sys/devices/system/cpu/cpu5/online 1
write /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq 1958400

write /sys/devices/system/cpu/cpu6/online 1
write /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq 1958400

write /sys/devices/system/cpu/cpu7/online 1
write /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq 302400
write /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 1958400

# input boost configuration
write /sys/module/cpu_boost/parameters/input_boost_enabled 1
write /sys/module/cpu_boost/parameters/boost_ms 40
write /sys/module/cpu_boost/parameters/input_boost_freq "0:600000 1:672000 2:0 3:0 4:0 5:0 6:0 7:0"
write /sys/module/cpu_boost/parameters/input_boost_ms 30
write /sys/module/cpu_boost/parameters/load_based_syncs Y
write /sys/module/cpu_boost/parameters/sync_threshold 1248000

# Setting B.L scheduler parameters
write /proc/sys/kernel/sched_migration_fixup 1
write /proc/sys/kernel/sched_upmigrate 95
write /proc/sys/kernel/sched_downmigrate 85
write /proc/sys/kernel/sched_freq_inc_notify 400000
write /proc/sys/kernel/sched_freq_dec_notify 400000

# android background processes are set to nice 10. Never schedule these on the a57s.
write /proc/sys/kernel/sched_upmigrate_min_nice 9

get-set-forall  /sys/class/devfreq/qcom,cpubw*/governor bw_hwmon

# Disable sched_boost
write /proc/sys/kernel/sched_boost 0

# Enable fingerprint boost
write /sys/kernel/fp_boost/enabled 1

# re-enable thermal and BCL hotplug
write /sys/module/msm_thermal/core_control/enabled 1
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask $bcl_hotplug_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask $bcl_hotplug_soc_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# change GPU initial power level from 305MHz(level 4) to 180MHz(level 5) for power savings
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 5