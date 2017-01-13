set ns [new Simulator]

set tra [open trace1.tr w]
$ns trace-all $tra

set anim [open namfile.nam w]
$ns namtrace-all $anim

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns simplex-link $n0 $n2 1.5Mb 1ms DropTail
$ns simplex-link $n1 $n2 1.5Mb 1ms DropTail
$ns simplex-link $n2 $n3 2Mb 1ms DropTail

$ns queue-limit $n2 $n3 10
$ns simplex-link-op $n2 $n3 queuePos 0.5

$ns simplex-link-op $n0 $n2 orient right-down
$ns simplex-link-op $n1 $n2 orient right-up
$ns simplex-link-op $n2 $n3 orient right

set src0 [new Agent/UDP]
$ns attach-agent $n0 $src0
$src0 set fid_ 1
$ns color 1 red

set src1 [new Agent/UDP]
$ns attach-agent $n1 $src1
$src1 set fid_ 2
$ns color 2 blue

set dest [new Agent/Null]
$ns attach-agent $n3 $dest
$ns connect $src0 $dest
$ns connect $src1 $dest

set traffic0 [new Application/Traffic/CBR]
$traffic0 set packetSize_ 500
$traffic0 set interval_ 5ms
$traffic0 attach-agent $src0

set traffic1 [new Application/Traffic/CBR]
$traffic1 set packetSize_ 500
$traffic1 set interval_ 5ms
$traffic1 attach-agent $src1

proc finish {} {
	global ns anim
	$ns flush-trace
	close $anim
	exec nam namfile.nam
	exit 0
}

$ns at 1.0 "$traffic0 start"
$ns at 1.5 "$traffic1 start"
$ns at 2.0 "$traffic0 stop"
$ns at 2.5 "$traffic1 stop"
$ns at 3.0 "finish"
$ns run
