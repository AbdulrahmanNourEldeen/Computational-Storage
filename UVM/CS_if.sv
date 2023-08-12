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