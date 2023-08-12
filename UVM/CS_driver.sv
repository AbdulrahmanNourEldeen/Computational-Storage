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