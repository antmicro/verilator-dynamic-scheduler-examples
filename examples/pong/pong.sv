/* verilator lint_off INFINITELOOP */
module t;
   event ping;
   event pong;

   initial
       forever begin
           @ping;
           $write("[%2t] ping\n", $time);
           #1 ->pong;
       end

   initial begin
       int cnt;

       forever begin
           #1 ->ping;
           @pong;
           $write("[%2t] pong\n", $time);
           cnt++;
           if (cnt >= 10) begin
               $write("*-* All Finished *-*\n");
               $finish;
           end
       end
   end
endmodule
