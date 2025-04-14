//Design of a 4-bit Multiplier
module mul_4bit(input1,input2,mul_output);
  input logic [3:0] input1,input2;
  output logic [7:0] mul_output;
  
  always_comb
    begin
      mul_output = input1 * input2;
    end
  
endmodule
