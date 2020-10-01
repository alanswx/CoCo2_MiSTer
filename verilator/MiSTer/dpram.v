
module dpram #(parameter addr_width_g = 16, parameter data_width_g = 8)  (
    input [addr_width_g-1:0] address_a,
    input [addr_width_g-1:0] address_b,
    input clock_a,
    input clock_b,
    input [data_width_g-1:0] data_a,
    input [data_width_g-1:0] data_b,
    input enable_a,
    input enable_b,
    input wren_a,
    input wren_b,
    output reg [data_width_g-1:0] q_a,
    output reg [data_width_g-1:0] q_b
);

reg [data_width_g-1:0] memory[0:(1>>addr_width_g)-1];

always @(posedge clock_a) begin
    q_a <= enable_a ? memory[address_a] : 0;
    if (wren_a) memory[address_a] <= data_a;
end

always @(posedge clock_b) begin
    q_b <= enable_b ? memory[address_b] : 0;
    if (wren_b) memory[address_b] <= data_b;
end


endmodule;