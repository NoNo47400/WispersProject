
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
create_project: 2

00:00:072

00:00:072	
555.7112	
201.371Z17-268h px� 
�
Command: %s
1870*	planAhead2�
�read_checkpoint -auto_incremental -incremental D:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/utils_1/imports/synth_1/Modulation.dcpZ12-2866h px� 
�
;Read reference checkpoint from %s for incremental synthesis3154*	planAhead2Z
XD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/utils_1/imports/synth_1/Modulation.dcpZ12-5825h px� 
T
-Please ensure there are no constraint changes3725*	planAheadZ12-7989h px� 
`
Command: %s
53*	vivadotcl2/
-synth_design -top MODEM -part xc7a35tcpg236-1Z4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
z
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2	
xc7a35tZ17-347h px� 
j
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2	
xc7a35tZ17-349h px� 
o
HMultithreading enabled for synth_design using a maximum of %s processes.4828*oasys2
2Z8-7079h px� 
a
?Launching helper process for spawning children vivado processes4827*oasysZ8-7078h px� 
N
#Helper process launched with PID %s4824*oasys2
29332Z8-7075h px� 
�
%s*synth2v
tStarting Synthesize : Time (s): cpu = 00:00:04 ; elapsed = 00:00:04 . Memory (MB): peak = 1015.375 ; gain = 444.117
h px� 
�
synthesizing module '%s'638*oasys2
MODEM2M
ID:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/MODEM.vhd2
178@Z8-638h px� 
�
Hmodule '%s' declared at '%s:%s' bound to instance '%s' of component '%s'3392*oasys2

Modulation2P
ND:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Modulation.vhd2
52
MODU2

Modulation2M
ID:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/MODEM.vhd2
488@Z8-3491h px� 
�
synthesizing module '%s'638*oasys2

Modulation2R
ND:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Modulation.vhd2
198@Z8-638h px� 
�
Hmodule '%s' declared at '%s:%s' bound to instance '%s' of component '%s'3392*oasys2
Carrier_generator2W
UD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Carrier_generator.vhd2
52
CARRIER_GEN2
Carrier_generator2R
ND:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Modulation.vhd2
428@Z8-3491h px� 
�
synthesizing module '%s'638*oasys2
Carrier_generator2Y
UD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Carrier_generator.vhd2
178@Z8-638h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2
Carrier_generator2
02
12Y
UD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Carrier_generator.vhd2
178@Z8-256h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2

Modulation2
02
12R
ND:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Modulation.vhd2
198@Z8-256h px� 
�
Hmodule '%s' declared at '%s:%s' bound to instance '%s' of component '%s'3392*oasys2
Demodulation2R
PD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Demodulation.vhd2
52
DEMODU2
Demodulation2M
ID:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/MODEM.vhd2
608@Z8-3491h px� 
�
synthesizing module '%s'638*oasys2
Demodulation2T
PD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Demodulation.vhd2
158@Z8-638h px� 
�
Hmodule '%s' declared at '%s:%s' bound to instance '%s' of component '%s'3392*oasys2
FILTER2L
JD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/FILTER.vhd2
52
	FILTER_LP2
FILTER2T
PD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Demodulation.vhd2
348@Z8-3491h px� 
�
synthesizing module '%s'638*oasys2
FILTER2N
JD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/FILTER.vhd2
148@Z8-638h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2
FILTER2
02
12N
JD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/FILTER.vhd2
148@Z8-256h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2
Demodulation2
02
12T
PD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Demodulation.vhd2
158@Z8-256h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2
MODEM2
02
12M
ID:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/MODEM.vhd2
178@Z8-256h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
Counter_reg2Y
UD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Carrier_generator.vhd2
1108@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
Clock_divided_reg2Y
UD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/sources_1/new/Carrier_generator.vhd2
1148@Z8-6014h px� 
�
%s*synth2v
tFinished Synthesize : Time (s): cpu = 00:00:05 ; elapsed = 00:00:05 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
Finished Constraint Validation : Time (s): cpu = 00:00:05 ; elapsed = 00:00:06 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
D
%s
*synth2,
*Start Loading Part and Timing Information
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
8
%s
*synth2 
Loading part: xc7a35tcpg236-1
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:05 ; elapsed = 00:00:06 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
D
Loading part %s157*device2
xc7a35tcpg236-1Z21-403h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
7
%s
*synth2
Start Preparing Guide Design
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
�The reference checkpoint %s is not suitable for use with incremental synthesis for this design. Please regenerate the checkpoint for this design with -incremental_synth switch in the same Vivado session that synth_design has been run. Synthesis will continue with the default flow4740*oasys2Z
XD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.srcs/utils_1/imports/synth_1/Modulation.dcpZ8-6895h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2~
|Finished Doing Graph Differ : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Preparing Guide Design : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
}
3inferred FSM for state register '%s' in module '%s'802*oasys2
current_state_reg2
Carrier_generatorZ8-802h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_           first_quarter |                               00 |                               00
h p
x
� 
y
%s
*synth2a
_          second_quarter |                               01 |                               01
h p
x
� 
y
%s
*synth2a
_           third_quarter |                               10 |                               10
h p
x
� 
y
%s
*synth2a
_           forth_quarter |                               11 |                               11
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
current_state_reg2

sequential2
Carrier_generatorZ8-3354h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 1127.977 ; gain = 556.719
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
C
%s
*synth2+
)

Incremental Synthesis Report Summary:

h p
x
� 
<
%s
*synth2$
"1. Incremental synthesis run: no

h p
x
� 
O
%s
*synth27
5   Reason for not running incremental synthesis : 


h p
x
� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}4868*oasysZ8-7130h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Detailed RTL Component Info : 
h p
x
� 
(
%s
*synth2
+---Adders : 
h p
x
� 
F
%s
*synth2.
,	  32 Input   13 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    8 Bit       Adders := 3     
h p
x
� 
+
%s
*synth2
+---Registers : 
h p
x
� 
H
%s
*synth20
.	               15 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                8 Bit    Registers := 37    
h p
x
� 
H
%s
*synth20
.	                1 Bit    Registers := 3     
h p
x
� 
'
%s
*synth2
+---Muxes : 
h p
x
� 
F
%s
*synth2.
,	   2 Input    8 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   4 Input    2 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   4 Input    1 Bit        Muxes := 1     
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Finished RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
Z
$Part: %s does not have CEAM library.966*device2
xc7a35tcpg236-1Z21-9227h px� 
p
%s
*synth2X
VPart Resources:
DSPs: 90 (col length:60)
BRAMs: 100 (col length: RAMB18 60 RAMB36 30)
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
E
%s
*synth2-
+Start Cross Boundary and Area Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
H
&Parallel synthesis criteria is not met4829*oasysZ8-7080h px� 
i
%s
*synth2Q
ODSP Report: Generating DSP MODU/Counter_sig1, operation Mode is: (A:0xc350)*B.
h p
x
� 
i
%s
*synth2Q
ODSP Report: operator MODU/Counter_sig1 is absorbed into DSP MODU/Counter_sig1.
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:00:10 ; elapsed = 00:00:12 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
]
%s
*synth2E
C Sort Area is  MODU/Counter_sig1_0 : 0 0 : 303 303 : Used 1 time 0
h p
x
� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Start ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
;
%s*synth2#
!
ROM: Preliminary Mapping Report
h px� 
t
%s*synth2\
Z+------------------+-----------------------------------+---------------+----------------+
h px� 
u
%s*synth2]
[|Module Name       | RTL Object                        | Depth x Width | Implemented As | 
h px� 
t
%s*synth2\
Z+------------------+-----------------------------------+---------------+----------------+
h px� 
u
%s*synth2]
[|Carrier_generator | carrier_table[0]                  | 256x8         | LUT            | 
h px� 
u
%s*synth2]
[|MODEM             | MODU/CARRIER_GEN/carrier_table[0] | 256x8         | LUT            | 
h px� 
u
%s*synth2]
[+------------------+-----------------------------------+---------------+----------------+

h px� 
v
%s*synth2^
\
DSP: Preliminary Mapping Report (see note below. The ' indicates corresponding REG is set)
h px� 
�
%s*synth2
}+------------+--------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h px� 
�
%s*synth2�
~|Module Name | DSP Mapping  | A Size | B Size | C Size | D Size | P Size | AREG | BREG | CREG | DREG | ADREG | MREG | PREG | 
h px� 
�
%s*synth2
}+------------+--------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h px� 
�
%s*synth2�
~|Modulation  | (A:0xc350)*B | 8      | 16     | -      | -      | 24     | 0    | 0    | -    | -    | -     | 0    | 0    | 
h px� 
�
%s*synth2�
~+------------+--------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+

h px� 
�
%s*synth2�
�Note: The table above is a preliminary report that shows the DSPs inferred at the current stage of the synthesis flow. Some DSP may be reimplemented as non DSP primitives later in the synthesis flow. Multiple instantiated DSPs are reported only once.
h px� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
4
%s
*synth2
Start Timing Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2
}Finished Timing Optimization : Time (s): cpu = 00:00:11 ; elapsed = 00:00:12 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
3
%s
*synth2
Start Technology Mapping
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2~
|Finished Technology Mapping : Time (s): cpu = 00:00:11 ; elapsed = 00:00:12 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
-
%s
*synth2
Start IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
?
%s
*synth2'
%Start Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
B
%s
*synth2*
(Finished Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2x
vFinished IO Insertion : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Start Renaming Generated Instances
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Instances : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start Rebuilding User Hierarchy
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Renaming Generated Ports
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Ports : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
;
%s
*synth2#
!Start Handling Custom Attributes
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
8
%s
*synth2 
Start Renaming Generated Nets
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Nets : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Writing Synthesis Report
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
W
%s
*synth2?
=
DSP Final Report (the ' indicates corresponding REG is set)
h p
x
� 
�
%s
*synth2~
|+------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h p
x
� 
�
%s
*synth2
}|Module Name | DSP Mapping | A Size | B Size | C Size | D Size | P Size | AREG | BREG | CREG | DREG | ADREG | MREG | PREG | 
h p
x
� 
�
%s
*synth2~
|+------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h p
x
� 
�
%s
*synth2
}|Modulation  | A*B         | 8      | 16     | -      | -      | 24     | 0    | 0    | -    | -    | -     | 0    | 0    | 
h p
x
� 
�
%s
*synth2
}+------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+

h p
x
� 
/
%s
*synth2

Report BlackBoxes: 
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
8
%s
*synth2 
| |BlackBox name |Instances |
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
/
%s*synth2

Report Cell Usage: 
h px� 
3
%s*synth2
+------+--------+------+
h px� 
3
%s*synth2
|      |Cell    |Count |
h px� 
3
%s*synth2
+------+--------+------+
h px� 
3
%s*synth2
|1     |BUFG    |     1|
h px� 
3
%s*synth2
|2     |CARRY4  |    61|
h px� 
3
%s*synth2
|3     |DSP48E1 |     1|
h px� 
3
%s*synth2
|4     |LUT1    |     6|
h px� 
3
%s*synth2
|5     |LUT2    |    22|
h px� 
3
%s*synth2
|6     |LUT3    |   153|
h px� 
3
%s*synth2
|7     |LUT4    |   114|
h px� 
3
%s*synth2
|8     |LUT5    |    15|
h px� 
3
%s*synth2
|9     |LUT6    |    45|
h px� 
3
%s*synth2
|10    |MUXF7   |     5|
h px� 
3
%s*synth2
|11    |FDCE    |   276|
h px� 
3
%s*synth2
|12    |FDPE    |    15|
h px� 
3
%s*synth2
|13    |FDRE    |    39|
h px� 
3
%s*synth2
|14    |IBUF    |    12|
h px� 
3
%s*synth2
|15    |OBUF    |     1|
h px� 
3
%s*synth2
+------+--------+------+
h px� 
3
%s
*synth2

Report Instance Areas: 
h p
x
� 
N
%s
*synth26
4+------+----------------+------------------+------+
h p
x
� 
N
%s
*synth26
4|      |Instance        |Module            |Cells |
h p
x
� 
N
%s
*synth26
4+------+----------------+------------------+------+
h p
x
� 
N
%s
*synth26
4|1     |top             |                  |   766|
h p
x
� 
N
%s
*synth26
4|2     |  DEMODU        |Demodulation      |   593|
h p
x
� 
N
%s
*synth26
4|3     |    FILTER_LP   |FILTER            |   584|
h p
x
� 
N
%s
*synth26
4|4     |  MODU          |Modulation        |   159|
h p
x
� 
N
%s
*synth26
4|5     |    CARRIER_GEN |Carrier_generator |    80|
h p
x
� 
N
%s
*synth26
4+------+----------------+------------------+------+
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Writing Synthesis Report : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
`
%s
*synth2H
FSynthesis finished with 0 errors, 1 critical warnings and 3 warnings.
h p
x
� 
�
%s
*synth2�
Synthesis Optimization Runtime : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:00:14 ; elapsed = 00:00:15 . Memory (MB): peak = 1324.676 ; gain = 753.418
h p
x
� 
B
 Translating synthesized netlist
350*projectZ1-571h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0052

1329.5312
0.000Z17-268h px� 
T
-Analyzing %s Unisim elements for replacement
17*netlist2
67Z29-17h px� 
X
2Unisim Transformation completed in %s CPU seconds
28*netlist2
0Z29-28h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
Q
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02
0Z31-138h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

1419.9882
0.000Z17-268h px� 
l
!Unisim Transformation Summary:
%s111*project2'
%No Unisim elements were transformed.
Z1-111h px� 
V
%Synth Design complete | Checksum: %s
562*	vivadotcl2

d50a7247Z4-1430h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
~
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
322
32
12
0Z4-41h px� 
L
%s completed successfully
29*	vivadotcl2
synth_designZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
synth_design: 2

00:00:152

00:00:172

1419.9882	
857.359Z17-268h px� 
c
%s6*runtcl2G
ESynthesis results are not added to the cache due to CRITICAL_WARNING
h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write ShapeDB Complete: 2

00:00:002
00:00:00.0022

1419.9882
0.000Z17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2E
CD:/VIVADO_projects/MODEM_WISPER/MODEM_WISPER.runs/synth_1/MODEM.dcpZ17-1381h px� 
�
Executing command : %s
56330*	planAhead2U
Sreport_utilization -file MODEM_utilization_synth.rpt -pb MODEM_utilization_synth.pbZ12-24828h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Sun Jan 26 23:51:28 2025Z17-206h px� 


End Record