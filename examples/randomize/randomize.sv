typedef enum bit[15:0] {
   ONE   = 3,
   TWO   = 5,
   THREE = 8,
   FOUR  = 13
} Enum;

class Cls;
   constraint A { v inside {ONE, THREE}; }
   constraint B { w == 5; x inside {1,2} || x inside {4,5}; }
   constraint C { z < 3 * 7; z > 5 + 8; }

   rand Enum v;
   rand logic[63:0] w;
   rand logic[47:0] x;
   rand logic[31:0] y;
   rand logic[23:0] z;

   function new;
      v = ONE;
      w = 0;
      x = 0;
      y = 0;
      z = 0;
   endfunction

endclass

module t (/*AUTOARG*/);
   Cls obj;

   initial begin
      int rand_result;
      longint prev_checksum;
      $display("===================\nSatisfiable constraints:");
      for (int i = 0; i < 25; i++) begin
         obj = new;
         rand_result = obj.randomize() with { 16 <= y && y <= 32; };
         $display("obj.v == %0d", obj.v);
         $display("obj.w == %0d", obj.w);
         $display("obj.x == %0d", obj.x);
         $display("obj.y == %0d", obj.y);
         $display("obj.z == %0d", obj.z);
         $display("rand_result == %0d", rand_result);
         $display("-------------------");
         if (!(obj.v inside {ONE, THREE})) $stop;
         if (obj.w != 5) $stop;
         if (!(obj.x inside {1,2,4,5})) $stop;
         if (obj.y < 16 || obj.y > 32) $stop;
         if (obj.z <= 13 || obj.z >= 21) $stop;
      end
      $display("===================\nUnsatisfiable constraints for obj.y:");
      rand_result = obj.randomize() with { 256 < y && y < 256; };
      $display("obj.y == %0d", obj.y);
      $display("rand_result == %0d", rand_result);
      if (rand_result != 0) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
