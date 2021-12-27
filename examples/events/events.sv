module t(clk);
   input clk;
   int   cyc = 0;
   event eventA;
   event eventB;
   event eventC;
   event eventD;
   event E1;
   event E2;

   logic[2:0] event_mask;

   always @(posedge clk) begin
      cyc <= cyc + 1;
      if (cyc > 2) $write("[%2t] event_mask == %5b\n", $time, event_mask);
      if (cyc == 0) begin
         for (int i = 0; i < 3; i++) begin
            $write("[%2t] waiting for event A, B, or C...\n", $time);
            @(eventA, eventB, eventC) $write("[%2t] got the event!\n", $time);
         end
      end
      else if (cyc == 3) begin
         ->E1;
         $write("[%2t] ->E1; E1.triggered == %b\n", $time, E1.triggered);
      end
      else if (cyc == 4) begin
         $write("[%2t] ->E2\n", $time);
         ->E2;
      end
      else if (cyc == 5) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end

   initial begin
     #2 $write("[%2t] triggering event D\n", $time);
     ->eventD;
     #1 $write("[%2t] triggering event A\n", $time);
     ->eventA;
     #1 $write("[%2t] triggering event B\n", $time);
     ->eventB;
     #1 $write("[%2t] triggering event C\n", $time);
     ->eventC;
   end

   always @(E1) begin
      $write("[%2t] @E1; E1.triggered == %b\n", $time, E1.triggered);
      event_mask[1] = 1;
   end

   always @(E2) begin
      $write("[%2t] @E2\n", $time);
      event_mask[2] = 1;
   end

endmodule
