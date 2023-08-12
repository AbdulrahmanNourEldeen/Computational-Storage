import uvm_pkg::*;
`include "uvm_macros.svh"      

import CS_pkg::*;



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