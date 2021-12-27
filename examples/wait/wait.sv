module t(/*AUTOARG*/);
   int a = 0;
   int b = 0;
   int c = 0;

   initial begin
     $write("starting with a == 0, b == 0, c == 0\n");
     #2 $write("assigning 1 to b.\n");
     b = 1;
     #1 $write("assigning 2 to a.\n");
     a = 2;
     #1 $write("assigning 3 to c.\n");
     c = 3;
     #1 $write("assigning 4 to c.\n");
     c = 4;
     #1 $write("assigning 5 to b.\n");
     b = 5;
   end

   initial begin
     #1 $write("waiting for a > b...\n");
     wait(a > b) $write("waited for a > b.\n");
     $write("waiting for a + b < c...\n");
     wait(a + b < c) $write("waited for a + b < c.\n");
     $write("waiting for a < b && b > c...\n");
     wait(a < b && b > c) $write("waited for a < b && b > c.\n");
     $write("*-* All Finished *-*\n");
     $finish;
   end
endmodule
