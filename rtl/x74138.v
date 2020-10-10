
// from https://www.programmersought.com/article/34964783614/
module x74138(En, I, O);
    input wire[2:0] En;
    input wire[2:0] I;
    output wire[7:0] O;

    assign O = (En==3'b100) ? ~(8'b0000_0001 << I) : 8'b0000_0000;

endmodule