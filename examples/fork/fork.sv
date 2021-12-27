module t;
   event cont;

   initial begin
      fork
         $write("forked process\n");
         $write("forked process\n");
         $write("forked process\n");
      join
      $write("join in main process\n");
      $write("==========================\n");
      fork
         $write("forked process 1\n");
         begin
            @cont $write("forked process 2\n");
            ->cont;
         end
      join_any
      #1 $write("join_any in main process\n");
      ->cont;
      @cont;
      $write("==========================\n");
      fork
         begin
            #1 $write("forked process\n");
            $write("*-* All Finished *-*\n");
            $finish;
         end
      join_none
      $write("join_none in main process\n");
   end
endmodule
