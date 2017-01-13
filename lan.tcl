Unicasting over LAN Scenario
#There are 6 nodes in a network, three of which are forming bus topology.
#There are 2 senders and two receivers, one of which is using CBR traffic and the other is using FTP traffic.
#Congestion window is plotted for the given network

set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set outfile [open congestion.xg w]

set tra [open trace6.tr w]
$ns trace-all $tra

set anim [open namfile6.nam w]
$ns namtrace-all $anim

for {set i 1} {$i<7} {incr i} {
set n$i [$ns node]
}

$n1 color Red
$n1 shape box

$ns duplex-link $n1 $n3 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 5Mb 10ms DropTail
$ns simplex-link $n3 $n4 0.3Mb 100ms DropTail
$ns simplex-link $n4 $n3 0.3Mb 100ms DropTail
set lan [$ns newLan "$n4 $n5 $n6" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

$ns duplex-link-op $n1 $n3 orient right-down
$ns duplex-link-op $n2 $n3 orient right-up
$ns simplex-link-op $n3 $n4 orient right
$ns simplex-link-op $n4 $n3 orient left

$ns queue-limit $n3 $n4 20

set src1 [new Agent/TCP]
$ns attach-agent $n1 $src1

set dest1 [new Agent/TCPSink]
$ns attach-agent $n5 $dest1

$ns connect $src1 $dest1
$src1 set fid_ 1
$src1 set window_ 100
$src1 set packetSize_ 520
set ftp [new Application/FTP]
$ftp attach-agent $src1
set src2 [new Agent/UDP]
$ns attach-agent $n1 $src2
set dest2 [new Agent/Null]
$ns attach-agent $n5 $dest2

$ns connect $src2 $dest2
$src2 set fid_ 2

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $src2

$cbr set type_ CBR
$cbr set packet_size_ 100
$cbr set rate_ 0.01Mb
$cbr set random_ false

proc finish {} {
global ns anim
$ns flush-trace
close $anim
exec nam namfile6.nam
exit 0
}
proc plotWindow {tcpSource outfile} {
global ns
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $outfile "$now $cwnd"
$ns at [expr $now+0.1] "plotWindow $tcpSource $outfile"
}

$ns at 0.0 "plotWindow $src1 $outfile"
$ns at 1.0 "$cbr start"
$ns at 1.5 "$ftp start"
$ns at 14.0 "$ftp stop"
$ns at 15.5 "$cbr stop"
$ns at 15.6 "finish"
$ns run

#exec xgraph congestion.xg -geometry 300x300
