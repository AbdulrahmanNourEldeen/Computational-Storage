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