module LMS_TB;
  reg Clk, Rst;
  reg signed [15:0] x_in;
  reg signed [15:0] x_gen;
  wire signed [15:0] y_out;
  reg[15:0] input_data[0:100];
  wire signed [15:0] d, err, w0, w1, w2, w3;
  integer i;

  localparam SF = 2.0**-12.0;

  LMS dut(
    .Clk(Clk),
    .Rst(Rst),
    .x_in(x_in),
    .w0(w0),
    .w1(w1),
    .w2(w2),
    .w3(w3),
    .y_out(y_out),
    .err(err)
  );
  
  FIR_Filter F1(
    .Clk(Clk),
    .Rst(Rst),
    .x(x_in),
    .d(d)
  );

  always begin
    #5 Clk = ~Clk;
  end

   initial begin
    drive_reset();
  
     $readmemb("LMS_inputs.txt", input_data);
      
     for( i=0; i<100;i=i+1)
        begin
          drive_input(input_data[i]);
          check_output();
        end
      
      repeat(30)@(negedge Clk)
      $finish;
    end

  
    task drive_reset();
    $display ("Driving the reset");
    Clk <= 1'b0;
    x_in<= 0;
    @ (negedge Clk)
    Rst = 1;
    @ (posedge Clk)
    Rst = 1;

    @ (negedge Clk)
    Rst = 0;
  endtask

  task drive_input(input [15:0] x_gen);
    $display ("Recieved the ready signal and driving the input");
    @ (negedge Clk)
    x_in = x_gen;
    $display(x_in*SF);
    $display ($itor(x_in*SF));
  endtask

  task check_output();
    $display("Time: %f, Iteration: %f, Input: %f, Output: %f, Error: %f w0: %f, w1 : %f, w2 : %f, w3 : %f", $time, i, x_in*SF, y_out*SF, err*SF,w0*SF,w1*SF,w2*SF,w3*SF);

  endtask
  
  initial begin
  $dumpfile("dump_lms.vcd");
  $dumpvars;
  end

endmodule