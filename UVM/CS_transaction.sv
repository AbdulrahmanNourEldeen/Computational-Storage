class CS_transaction extends uvm_sequence_item;

//Constructor
function new(input string inst = "transaction");
super.new(inst);
endfunction : new
            
//Data members
bit		                          RESET;

rand	bit	[$clog2(`DEPTH)-1:0]	   addA;
rand	bit	[$clog2(`DEPTH)-1:0]	   addB;
rand	bit	[$clog2(`DEPTH)-1:0]	   addC;

rand	bit	[1:0]	                  OPERATION;
rand  bit   [`WIDTH-1:0]            DQ_temp; 

bit	      [`WIDTH-1:0]	         DQ;
bit                                 overflow;

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