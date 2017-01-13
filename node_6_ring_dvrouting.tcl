set ns [new Simulator]

set tra [open tr6.tr w]
$ns trace-all $tra

set anim [open namfile6.nam w]
$ns namtrace-all $anim

for {set i 0} {$i<6} {incr i} {
set n$i [$ns node] }

$ns duplex-link $n0 $n1 1.75Mb 1ms DropTail
$ns duplex-link $n1 $n2 1.75Mb 1ms DropTail
$ns duplex-link $n2 $n3 1.75Mb 1ms DropTail
$ns duplex-link $n3 $n4 1.75Mb 1ms DropTail
$ns duplex-link $n4 $n5 1.75Mb 1ms DropTail
$ns duplex-link $n5 $n0 1.75Mb 1ms DropTail
 
$ns rtproto DV

set src [new Agent/UDP]
$ns attach-agent $n0 $src
$src set fid_ 1

set dest [new Agent/Null]
$ns attach-agent $n2 $dest

$ns connect $src $dest

set traffic [new Application/Traffic/CBR]
$traffic attach-agent $src

proc finish {} {
global ns anim
$ns flush-trace
close $anim
exec nam namfile6.nam
exit 0 }

$ns at 1.0 "$traffic start"
$ns rtmodel-at 2.0 down $n0 $n1
$ns rtmodel-at 3.5 up $n0 $n1
$ns at 4.0 "$traffic stop"
$ns at 4.5 "finish"
$ns run
