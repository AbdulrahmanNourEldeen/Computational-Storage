class CS_directed_sequence extends uvm_sequence#(CS_transaction);

`uvm_object_utils(CS_directed_sequence)

function new(input string inst = "CS_directed_sequence");
  super.new(inst);
endfunction : new

CS_transaction transaction; 
    
task body();

transaction = CS_transaction::type_id::create("transaction");

//Reset
start_item(transaction);
transaction.RESET = 1'b0;
finish_item(transaction);

/*
Write into a certain location, then read from the same location.
*/
//Write
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b01;
transaction.addC      = 'b1111;
transaction.DQ_temp   = 'b1; 
finish_item(transaction);

//Read
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b00;
transaction.addA      = 'b1111;
finish_item(transaction);

/*
Add two values , then read the result.
*/
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b11;
transaction.addA      = 'b0110;
transaction.addB      = 'b0111;
transaction.addC      = 'b1111;
finish_item(transaction);

//Read
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b00;
transaction.addA      = 'b1111;
finish_item(transaction);

/*
Sub two values , then read the result.
*/
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b10;
transaction.addA      = 'b0000;
transaction.addB      = 'b0001;
transaction.addC      = 'b1111;
finish_item(transaction);

//Read
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b00;
transaction.addA      = 'b1111;
finish_item(transaction);

/*
Add two values , store the result in the same location as one
of the operands then read the result.
*/
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b11;
transaction.addA      = 'b0000;
transaction.addB      = 'b0001;
transaction.addC      = 'b0000;
finish_item(transaction);

//Read
start_item(transaction);
transaction.RESET     = 1'b1;
transaction.OPERATION = 2'b00;
transaction.addA      = 'b0000;
finish_item(transaction);


endtask : body  

endclass : CS_directed_sequence 

