//CALCULATOR
module Calculator(oprand1, oprand2, opSelect, result);
  input [4:0] oprand1;
  input [3:0] oprand2;
  input opSelect;
  output reg [7:0] result;

  always @(oprand1 or oprand2 or posedge opSelect) begin
    if (opSelect == 0) begin
      result <= oprand1 * oprand2;
    end
    else begin
      result <= oprand1 / oprand2;
    end
  end 
endmodule

module Calculator( input [3:0] operand1,
input [3:0] operand2,
input opSelect,
input calculate,
input clk,
output [6:0] seg,
output reg [3:0] an
); reg [3:0] result;

SevenSegmentDisplay SSD (
    .number(result),
    .seg(seg),
    .an(an)
);

// Logic for the calculation
always @(posedge clk) begin
    if (calculate) begin
        if (opSelect == 0) begin
            // Using only the LSB of each operand
            result <= operand1[0] * operand2[0];
        end else begin
            // For division, use the 2 LSBs of operand1 and the LSB of operand2
            if (operand2[0] != 0) begin
                result <= operand1[1:0] / operand2[0];
            end else begin
                result <= 0; // Handle division by zero
            end
        end
    end
end
endmodule

// Someone should put the seven segment code here
