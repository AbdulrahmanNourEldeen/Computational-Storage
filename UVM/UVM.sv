import uvm_pkg::*;
`include "uvm_macros.svh"                   

//Macros
`define WIDTH 32
`define DEPTH 1024

///////////////////////////////////////////////////////////////////
//                        Interface 
///////////////////////////////////////////////////////////////////

interface CS_if (input logic CLK);

logic			                      RESET;
logic	  [$clog2(`DEPTH)-1:0]		addA;
logic	  [$clog2(`DEPTH)-1:0]		addB;
logic	  [$clog2(`DEPTH)-1:0]		addC;
logic	  [1:0]	                  OPERATION;

logic                           overflow;

/*
For the inout signal "DQ", i defined a temporary variable to facilitate 
the driving mechanism, driving "DQ" @write operation only.
*/ 
wire	  [`WIDTH-1:0]		        DQ;
logic   [`WIDTH-1:0]            DQ_temp;

assign DQ = (OPERATION == 2'b01)? DQ_temp : 'bz ;

//Clocking block
clocking cb @ (posedge CLK);
  default input #0 output #0 ;

  output addA, addB, addC, RESET, OPERATION;

  input overflow;
  inout DQ;   
endclocking : cb

endinterface: CS_if

///////////////////////////////////////////////////////////////////
//                        Sequence Item 
///////////////////////////////////////////////////////////////////

class CS_transaction extends uvm_sequence_item;

//Constructor
function new(input string inst = "transaction");
super.new(inst);
endfunction : new
            
//Data members
bit		                          RESET;

rand	bit	[$clog2(`DEPTH)-1:0]	addA;
rand	bit	[$clog2(`DEPTH)-1:0]	addB;
rand	bit	[$clog2(`DEPTH)-1:0]	addC;

rand	bit	[1:0]	                OPERATION;
rand  bit [`WIDTH-1:0]          DQ_temp; 

bit	      [`WIDTH-1:0]	        DQ;
bit                             overflow;

//Reg to Factory
`uvm_object_utils_begin(CS_transaction)
`uvm_field_int(RESET,UVM_DEFAULT)
`uvm_field_int(addA,UVM_DEFAULT)
`uvm_field_int(addB,UVM_DEFAULT)
`uvm_field_int(addC,UVM_DEFAULT)
`uvm_field_int(OPERATION,UVM_DEFAULT)
`uvm_field_int(DQ,UVM_DEFAULT)
`uvm_field_int(DQ_temp,UVM_DEFAULT)
`uvm_field_int(overflow,UVM_DEFAULT)
`uvm_object_utils_end

endclass : CS_transaction

//Finish Sequence Item

///////////////////////////////////////////////////////////////////
//                        Coverage 
///////////////////////////////////////////////////////////////////
class CS_coverage extends uvm_subscriber #(CS_transaction);
`uvm_component_utils(CS_coverage)

bit                       RESET;
bit [1:0]                 OPERATION;
bit                       overflow;
bit [$clog2(`DEPTH)-1:0]  addA;
bit [$clog2(`DEPTH)-1:0]  addB;
bit [$clog2(`DEPTH)-1:0]  addC;

//Cover group
covergroup CS_cover_group;
//Covering different operations
Operations: coverpoint OPERATION iff(RESET) {
  bins Read = {0};
  bins Write = {1};
  bins Sub = {2};
  bins Add = {3};
}

//Covering different addresses 
addA: coverpoint addA iff(RESET){
  bins Diff_values[] = {[0:$]};
}
addB: coverpoint addB iff(RESET){
  bins Diff_values[] = {[0:$]};
}
addC: coverpoint addC iff(RESET){
  bins Diff_values[] = {[0:$]};
}

//Covering overflow values (0&1)
Overflow: coverpoint overflow iff(RESET){
  bins high = {1};
  bins low = {0};
}

//Covering addition && overflow (0&1)
Add_OF: cross Operations,Overflow iff(RESET) {
  bins of1 = Add_OF with(Operations == 3 && Overflow == 1);
  bins of0 = Add_OF with(Operations == 3 && Overflow == 0);

 ignore_bins ig1 = Add_OF with (Operations !=3 && Overflow);
 ignore_bins ig2 = Add_OF with (Operations !=3 && ~Overflow);
}
endgroup

//Constructor
function new (input string name, uvm_component parent);
  super.new(name, parent);
  CS_cover_group = new();
endfunction : new

//Write method
function void write(CS_transaction t);
  RESET     = t.RESET;
  OPERATION = t.OPERATION;
  overflow  = t.overflow;
  addA      = t.addA;
  addB      = t.addB;
  addC      = t.addC;
  CS_cover_group.sample();
endfunction : write
endclass

///////////////////////////////////////////////////////////////////
//                        Sequence 
///////////////////////////////////////////////////////////////////

class CS_random_sequence extends uvm_sequence#(CS_transaction);

`uvm_object_utils(CS_random_sequence)

function new(input string inst = "CS_random_sequence");
  super.new(inst);
endfunction : new

CS_transaction transaction; 
    
task body();

transaction = CS_transaction::type_id::create("transaction");

//Reset
start_item(transaction);
transaction.RESET = 1'b0;
finish_item(transaction);


//Random sequence
repeat(10000) begin
start_item(transaction);

transaction.RESET = 1'b1;
assert(transaction.randomize())
  else `uvm_error("Sequence","Randomization failed")

finish_item(transaction);
end

//Reset
start_item(transaction);
transaction.RESET = 1'b0;
finish_item(transaction);

//Read sequence
repeat(100) begin
start_item(transaction);

transaction.RESET = 1'b1;
assert(transaction.randomize() with {OPERATION == 2'b00;})
  else `uvm_error("Sequence","Randomization failed")

finish_item(transaction);
end


endtask : body  

endclass : CS_random_sequence 
///////////////////////////////////////////////////////////////////
//                        Sequencer 
///////////////////////////////////////////////////////////////////
class CS_sequencer extends uvm_sequencer#(CS_transaction);
`uvm_component_utils(CS_sequencer)

function new(input string inst = "CS_sequencer", uvm_component parent);
super.new(inst,parent);
endfunction : new

endclass

///////////////////////////////////////////////////////////////////
//                        Driver 
///////////////////////////////////////////////////////////////////
class CS_driver extends uvm_driver#(CS_transaction);
`uvm_component_utils(CS_driver)

//Constructor
function new(string name = "CS_driver" ,  uvm_component parent = null);
 	 super.new(name,parent);
endfunction: new

//Build phase
virtual CS_if vif;
function void build_phase(uvm_phase phase);
  if(!(uvm_config_db #(virtual CS_if)::get(this, "","vif", vif)))
    `uvm_fatal("NO VIF","Interface Not Found");
endfunction : build_phase

//Run phase
virtual task run_phase(uvm_phase phase);
forever begin
CS_transaction transaction;
@(vif.cb);

seq_item_port.get_next_item(transaction);
drive(transaction);
reportInfo(transaction);
seq_item_port.item_done();

end
endtask : run_phase

task drive(CS_transaction transaction);

vif.RESET <= transaction.RESET;
vif.addA <= transaction.addA;
vif.addB <= transaction.addB;
vif.addC <= transaction.addC;
vif.OPERATION <= transaction.OPERATION;

/*
Driving "DQ_temp" which is assigned to "DQ" port.
*/
if (transaction.OPERATION == 2'b01) begin
vif.DQ_temp <= transaction.DQ_temp;
end
endtask

task reportInfo(CS_transaction transaction);
$display("############ Driving the DUV ##############");

if (transaction.RESET == 1'b0) begin
$display("- Current simulation time %0t\nXX Resetting XX",$time);
end
else if (transaction.OPERATION == 2'b00) //Read
$display("- Current simulation time:%0t\n- Operation: Read\n- Address A:%h",$time,transaction.addA);
else if (transaction.OPERATION == 2'b01) //Write
$display("- Current simulation time:%0t\n- Operation: Write\n- Address C:%h\n- Value:%h",$time,transaction.addC,transaction.DQ_temp);
else if (transaction.OPERATION == 2'b11) //Add
$display("- Current simulation time:%0t\n- Operation: Addition\n- Address A:%h\n- Address B:%h\n- Address C:%h",$time,transaction.addA,transaction.addB,transaction.addC);
else //Subtraction
$display("- Current simulation time:%0t\n- Operation: Subtraction\n- Address A:%h\n- Address B:%h\n- Address C:%h",$time,transaction.addA,transaction.addB,transaction.addC);

$display("###########################################\n");
endtask

endclass : CS_driver


///////////////////////////////////////////////////////////////////
//                        Monitor 
///////////////////////////////////////////////////////////////////
class CS_monitor extends uvm_monitor;
`uvm_component_utils(CS_monitor)

//Interface Handler
virtual CS_if vif;
//Analysis Port Handler
uvm_analysis_port #(CS_transaction) analysis_port;

//Constructor
function new(input string inst = "MON", uvm_component parent);
super.new(inst,parent);
analysis_port = new("analysis_port", this);
endfunction : new

//Build phase
virtual function void build_phase (uvm_phase phase);
super.build_phase(phase);
  if(!uvm_config_db#(virtual CS_if)::get(this, "", "vif", vif))
    `uvm_fatal("NOVIF","Interface Not Found");
endfunction : build_phase

//Run phase
virtual task run_phase (uvm_phase phase);
forever begin 
CS_transaction transaction;

@vif.cb;
transaction = CS_transaction::type_id::create("transaction");
capture(transaction);
analysis_port.write(transaction);
end
endtask : run_phase

task capture(output CS_transaction transaction);
CS_transaction temp = CS_transaction::type_id::create("transaction");
//monitoring
temp.RESET = vif.RESET;
temp.addA = vif.addA;
temp.addB = vif.addB;
temp.addC = vif.addC;

temp.OPERATION = vif.OPERATION;

temp.DQ = vif.cb.DQ;
temp.overflow = vif.cb.overflow;

transaction = temp;
endtask
endclass: CS_monitor 
///////////////////////////////////////////////////////////////////
//                        Scoreboard 
///////////////////////////////////////////////////////////////////

class CS_scoreboard extends uvm_scoreboard;
`uvm_component_utils(CS_scoreboard)
uvm_analysis_imp #(CS_transaction,CS_scoreboard) analysis_export;

function new (string name = "CS_scoreboard" , uvm_component parent = null);
super.new(name,parent);  
analysis_export = new("READ",this); 

$readmemh("MEM_PRE_HEX.txt", scbdMem); //Initiating the scoreboard memory.
endfunction

/*
Defining a 2D array to mimic the DUT memory. 
*/
reg [`WIDTH-1:0]  scbdMem [0:`DEPTH-1];
reg [`WIDTH:0]    temp;

//Write function
function void write(CS_transaction transaction);

$display("############ Scoreboard report ############");
$display("- Current simulation time:%0t",$time);

/*
Reset operation: re initiate the scoreboard memory.
*/
if (transaction.RESET == 1'b0) begin                  
$display("XX Resetting XX");
$readmemh("MEM_PRE_HEX.txt", scbdMem);
end

/*
Write operation: write the given value at the same location given to the DUT.
*/
else if (transaction.OPERATION == 2'b01) begin        
scbdMem[transaction.addC] = transaction.DQ;
end

/*
Read operation: compare the captured value from the DUT with the stored value
in the scoreboard memory; if they match, then the test passes.
*/
else if (transaction.OPERATION == 2'b00) begin        
$display("DUT output: DQ = %0h", transaction.DQ);
$display("Expected output: DQ = %0h", scbdMem[transaction.addA]);

if (scbdMem[transaction.addA] == transaction.DQ) begin
$display("Test result: Passed");
end
else begin
  `uvm_error("SCOREBOARD","Test result: Failed (The captured value does not match the expected value)")
end
end

/*
Addition operation: mimic the DUT behavior and check whether the overflow flag matches.
*/
else if (transaction.OPERATION == 2'b11) begin      
$display("DUT output: Overflow = %0h",transaction.overflow);
temp = scbdMem[transaction.addA] + scbdMem[transaction.addB];
scbdMem[transaction.addC] = scbdMem[transaction.addA] + scbdMem[transaction.addB];

if (temp[`WIDTH] == transaction.overflow) begin
$display("Test result: Passed");
end
else begin
  `uvm_error("SCOREBOARD","Test result: Failed (The captured value does not match the expected value)")
end
end

/*
Subtraction operation, mimic the DUT behavior.
*/
else begin
scbdMem[transaction.addC] = scbdMem[transaction.addA] - scbdMem[transaction.addB];
end
$display("###########################################\n");
endfunction : write
endclass : CS_scoreboard
   
///////////////////////////////////////////////////////////////////
//                        Agent 
///////////////////////////////////////////////////////////////////
class CS_agent extends uvm_agent;
`uvm_component_utils(CS_agent)

//Constructor
function new(input string inst = "AGT", uvm_component parent);
super.new(inst,parent);
endfunction : new

//Agent components
CS_driver    drv;
CS_sequencer seqr;
CS_monitor   mon;

//Build phase
virtual function void build_phase (uvm_phase phase);
super.build_phase(phase);

//check if Agent is ACTIVE
if(get_is_active() == UVM_ACTIVE) begin
  drv = CS_driver::type_id::create("drv", this);
  seqr = CS_sequencer::type_id::create("seqr", this);
end
mon = CS_monitor::type_id::create("mon", this);
endfunction : build_phase

//Connect phase
function void connect_phase(uvm_phase phase);
//check if Agent is ACTIVE
if(get_is_active() == UVM_ACTIVE) begin
  drv.seq_item_port.connect(seqr.seq_item_export);
end
endfunction : connect_phase

endclass: CS_agent 

///////////////////////////////////////////////////////////////////
//                        Environment 
///////////////////////////////////////////////////////////////////
class CS_environment extends uvm_env;
`uvm_component_utils(CS_environment)

//Constructor
function new(string name = "CS_environment" ,  uvm_component parent = null);
  super.new(name,parent);
endfunction: new

CS_agent			  ag;
CS_scoreboard		scbd;
CS_coverage     cov;

//Build phase
function void build_phase(uvm_phase phase);
  scbd  = CS_scoreboard::type_id::create("scbd",this);
  ag    = CS_agent::type_id::create("ag",this);
  cov   = CS_coverage::type_id::create("cov",this);
endfunction : build_phase

//Connect phase
function void connect_phase(uvm_phase phase);
  ag.mon.analysis_port.connect(scbd.analysis_export);
  ag.mon.analysis_port.connect(cov.analysis_export);
endfunction : connect_phase

endclass : CS_environment

///////////////////////////////////////////////////////////////////
//                        Test 
///////////////////////////////////////////////////////////////////
class CS_base_test extends uvm_test;
`uvm_component_utils(CS_base_test)

//Constructor
function new(string inst ="TEST",uvm_component c);
  super.new(inst,c);
endfunction : new 

CS_environment env;
CS_random_sequence random_seq;

//Build phase
virtual function void build_phase (uvm_phase phase);
super.build_phase(phase);
env   = CS_environment::type_id::create("ENV",this);
endfunction : build_phase

//Run phase
virtual task run_phase (uvm_phase phase);
random_seq = CS_random_sequence::type_id::create("GEN",this);
/* And other sequences*/

phase.raise_objection(this);
random_seq.start(env.ag.seqr);
/* And other sequences*/
#40;
phase.drop_objection(this);
endtask: run_phase    
endclass: CS_base_test
        
///////////////////////////////////////////////////////////////////
//                        Test module 
///////////////////////////////////////////////////////////////////

module Top;
//Clock generation
logic CLK;

initial begin    
  CLK = 1'b0;
  #10;
  forever begin
    CLK = ~ CLK;
    #10;
  end
end

//Interface instance
CS_if vif (.CLK(CLK));

//DUT instantiation
CompStorage DUT(
.CLK(CLK),
.RESET(vif.RESET),
.addA(vif.addA),
.addB(vif.addB),
.addC(vif.addC),
.OPERATION(vif.OPERATION),

.DQ(vif.DQ),
.overflow(vif.overflow)
);
     
initial begin
  $dumpfile("CS.vcd") ;       
  $dumpvars; 
  uvm_config_db#(virtual CS_if)::set(null,"*","vif",vif);
  run_test("CS_base_test");
end
endmodule