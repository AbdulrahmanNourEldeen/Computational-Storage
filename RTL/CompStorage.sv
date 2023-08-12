module CompStorage #(parameter WIDTH = 32, parameter DEPTH = 1024)
(
inout [WIDTH-1:0] DQ,
output overflow,

input CLK,
input RESET,
input [$clog2(DEPTH)-1:0] addA,
input [$clog2(DEPTH)-1:0] addB,
input [$clog2(DEPTH)-1:0] addC,
input [1:0] OPERATION
);

localparam  RD_MEM_CMD = 2'b00,
            WR_MEM_CMD = 2'b01,
            ADD_CMD    = 2'b11,
            SUB_CMD    = 2'b10;

reg [WIDTH-1:0]   DQ_temp;
/*
Defining temp variable to be used to detect the overflow.
*/
reg [WIDTH:0]     tempResult;

//Memory
reg [WIDTH-1:0] MEM [0:DEPTH-1];
initial
  begin
    $readmemh("MEM_PRE_HEX.txt", MEM);
  end

//Procedurals
always @(posedge CLK or negedge RESET) 
begin
if(!RESET)
  begin
    $readmemh("MEM_PRE_HEX.txt", MEM);
  end
else
  begin
      case (OPERATION)
      RD_MEM_CMD:
        begin
          DQ_temp <= MEM[addA];
        end

      WR_MEM_CMD:
        begin
          MEM[addC] <= DQ;
        end

      ADD_CMD:
        begin
          MEM[addC] <= MEM[addA] + MEM[addB];   
          tempResult <= MEM[addA] + MEM[addB];
        end

      SUB_CMD:
        begin
          MEM[addC] <= MEM[addA] - MEM[addB];   
        end   
      default:
        begin
          DQ_temp <= MEM[addA];
        end
      endcase
  end
end

//Continous assignments
/*
Drive "DQ" only during read opertaion. 
*/
assign DQ = (OPERATION == 2'b00)? DQ_temp : 'bz ;
/*
Assert overflow flag when addition result overflows.
*/
assign overflow = (OPERATION == 2'b11 && tempResult[WIDTH])? 1'b1 : 1'b0;
endmodule

