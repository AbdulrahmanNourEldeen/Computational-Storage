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