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