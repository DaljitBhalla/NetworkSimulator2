
set ns [new Simulator -multicast on]
set tra [open trace4.tr w]
$ns trace-all $tra

set anim [open namfile4.nam w]
$ns namtrace-all $anim

proc finish {} {
global ns anim
$ns flush-trace
close $anim
exec nam namfile4.nam
exit 0
}

$ns color 1 red
#$ns color 2 blue
for {set i 1} {$i<9} {incr i} {
set n$i [$ns node]
}

$ns duplex-link $n1 $n2 1.75Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.75Mb 10ms DropTail
$ns duplex-link $n3 $n4 1.75Mb 10ms DropTail
$ns duplex-link $n4 $n5 1.75Mb 20ms DropTail
$ns duplex-link $n1 $n5 1.75Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 20ms DropTail
$ns duplex-link $n6 $n7 2Mb 20ms DropTail
$ns duplex-link $n4 $n7 2Mb 20ms DropTail
$ns duplex-link $n7 $n8 2Mb 20ms DropTail

set mproto DM
#Dense mode: Each router is involved in multicasting
set mrthandle [$ns mrtproto $mproto]

set grp1 [Node allocaddr]
set grp2 [Node allocaddr]
set src0 [new Agent/UDP]
$ns attach-agent $n1 $src0
$src0 set dst_addr_ $grp1
set traffic0 [new Application/Traffic/CBR]
$traffic0 attach-agent $src0
set src1 [new Agent/UDP]
$ns attach-agent $n5 $src1
$src1 set dst_addr_ $grp2
$src0 set class_ 1

set traffic1 [new Application/Traffic/CBR]
$traffic1 attach-agent $src1
set dest [new Agent/Null]
$ns attach-agent $n4 $dest

$ns at 0.5 "$traffic0 start"
$ns at 1.0 "$traffic1 start"
$ns at 1.2 "$n4 join-group $dest $grp1"
$ns at 2.5 "$n4 leave-group $dest $grp1"
$ns at 3.0 "$n4 join-group $dest $grp1"
$ns at 3.5 "$n4 join-group $dest $grp2"
$ns at 4.0 "$traffic0 stop"
$ns at 4.5 "$traffic1 stop"
$ns at 4.6 "finish"
$ns run
