# Number of nodes = 3 is fixed in the program.
# Nodes are configured with specific parameters of a mobile wireless node.
# Initial locations of the nodes are fixed.
# Nodes are given mobility with fixed speed and fixed destination location.
# AODV(Ad hoc On-Demand Distance Vector Routing) routing protocol is used and
# communication over TCP is set among the nodes.

set val(nn) 3
set val(rp) AODV
set val(chan) Channel/WirelessChannel
set val(mac) Mac/802_11
set val(ll) LL
set val(netif) Phy/WirelessPhy
set val(ifqType) Queue/DropTail/PriQueue
set val(prop) Propagation/TwoRayGround
set val(ifqlen) 50
set val(x) 500
set val(y) 500
set val(ant) Antenna/OmniAntenna

set ns [new Simulator]

set outfile [open congestion.xg w]
set nt [open trace5.tr w]
$ns trace-all $nt
set nf [open namfile5.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

$ns node-config -addressingType flat \
-adhocRouting $val(rp) \
-phyType $val(netif) \
-macType $val(mac) \
-llType $val(ll) \
-propType $val(prop) \
-antType $val(ant) \
-channelType $val(chan) \
-ifqType $val(ifqType) \
-ifqLen $val(ifqlen) \
-topoInstance $topo \
-routerTrace ON \
-movementTrace ON \
-macTrace OFF \
-addressTrace ON \
-agentTrace ON

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$n0 color black
$n0 set X_ 150.0
$n0 set Y_ 250.0
$n0 set Z_ 0.0

$n1 color blue
$n1 set X_ 490.0
$n1 set Y_ 285.0
$n1 set Z_ 0.0

$n2 color red
$n2 set X_ 5.0
$n2 set Y_ 5.0
$n2 set Z_ 0.0

$ns initial_node_pos $n0 30
$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30

set src1 [new Agent/TCP]
$src1 set fid_ 1
$ns color 1 red
$ns attach-agent $n0 $src1

set d1 [new Agent/TCPSink]
$ns attach-agent $n1 $d1
$ns connect $src1 $d1

set ftp [new Application/FTP]
$ftp set packetSize_ 2000B
$ftp set interval_ 5ms
$ftp attach-agent $src1
set src2 [new Agent/TCP]
$src2 set fid_ 2
$ns color 2 blue
$ns attach-agent $n0 $src2

set d2 [new Agent/TCPSink]
$ns attach-agent $n2 $d2
$ns connect $src2 $d2

set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 2000
$ftp1 set interval_ 5ms
$ftp1 attach-agent $src2

proc plotWindow {tcpSource outfile} {
global ns
set now1 [$ns now]
set cwnd1 [$tcpSource set cwnd_]
puts $outfile "$now1 $cwnd1"
$ns at [expr $now1+0.1] "plotWindow $tcpSource stdout"
}

proc finish {} {
global ns nf
close $nf
exec nam namfile5.nam
$ns flush-trace
exit 0
}

$ns at 0.0 "plotWindow $src1 $outfile"
$ns at 0.5 "$ftp start"
$ns at 0.5 "$ftp1 start"
$ns at 2.0 "$n0 setdest 220.0 230.0 15.0"
$ns at 2.0 "$n1 setdest 220.0 235.0 30.0"
$ns at 2.0 "$n2 setdest 200.0 205.0 20.0"
$ns at 12.0 "$n0 setdest 100.0 130.0 35.0"
$ns at 13.0 "$n1 setdest 425.0 335.0 20.0"
$ns at 29.0 "$n0 reset"
$ns at 29.0 "$n1 reset"
$ns at 29.0 "$n2 reset"
$ns at 29.0 "$ftp stop"
$ns at 29.0 "$ftp1 stop"
$ns at 30.0 "finish"

$ns run
#exec xgraph congestion.xg -geometry 300x300
