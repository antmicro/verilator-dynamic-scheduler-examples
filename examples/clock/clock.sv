/* verilator lint_off INFINITELOOP */
module t;
   logic clk;
   int   cyc = 0;

   initial begin
       forever begin
           clk = 1'b0;
           #1;
           clk = 1'b1;
           #1;
       end
   end

   always @(negedge clk) begin
      $write("[%2t] negedge; clk == %b\n", $time, clk);
   end

   always @(posedge clk) begin
      cyc <= cyc + 1;
      if (cyc == 10) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
      $write("[%2t] posedge; clk == %b\n", $time, clk);
   end

endmodule
