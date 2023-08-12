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