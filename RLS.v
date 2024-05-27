module RLS (
    input Clk, Rst,
    input signed [15:0] x_in, // Input signal
    output signed [15:0] y_out, // Output signal
    output signed [15:0] w0, w1, w2, w3, // Weights
    output signed [15:0] err, // Errors
  output signed [15:0] p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16 // Auto correlation Matrix
  
);
// Here 4 bits are used for decimal and 12 bits are used for representing fractions

  parameter signed [15:0] gamma = 16'b0000111100111111, gamma_inverse = 16'b0001000011000101 ; // gamma = 0.95


  reg signed [15:0]  p[0:15]; // Inverse of Auto Correlarion Function
  wire signed [15:0]  p_u[0:15], r[0:15] , p_u_raw_wire[0:15]; // Temp value for storing past values of p
  reg signed [15:0] k[0:3]; // Gain Vector
  
  
  reg signed [15:0] wn[0:3], x[0:3] ;
  wire signed [15:0] wn_u[0:3], k_1[0:3], q[0:3];
  wire signed [15:0] m1,m2,m3,m4,l, k_scale;
  wire signed [31:0] m11, m21, m31, m41, y_out1, p_11, p_12, p_13, p_14, p_21, p_22, p_23, p_24, p_31, p_32, p_33, p_34, p_41, p_42, p_43, p_44;
  reg signed [15:0] d_in;

  FIR_Filter fir(
    .Clk(Clk),
    .Rst(Rst),
    .x(x_in),
    .d(d_in)
  );
  

  MAT_VECT_Mul M1(
    .Mat(p),
    .Vect(x),
    .Vect_out(k_1)
  );
  
  
  VECT_VECT_Mul M2(
    .Vect1(x),
    .Vect2(k_1),
    .Vect_out(l)
  );
  
    
  VECT_MAT_Mul M3(
    .Mat(p),
    .Vect(x),
    .Vect_out(q)
  );
  
  
  VECT_VECT_2Mul M4(
    .Vect1(k),
    .Vect2(q),
    .Mat_out(r)
  );
  
  
   Divider D0 (
     .dividend(k_1[0]),
     .divisor(k_scale),
     .quotient(k[0])
   );

   Divider D1 (
     .dividend(k_1[1]),
     .divisor(k_scale),
     .quotient(k[1])
   );  

   Divider D2 (
     .dividend(k_1[2]),
     .divisor(k_scale),
     .quotient(k[2])
   );

   Divider D3 (
     .dividend(k_1[3]),
     .divisor(k_scale),
     .quotient(k[3])
   );
   


  always@(posedge Clk or posedge Rst)
      if(Rst)
      begin // Initializing the input x[-1] as 16'b0
      
          x[3]<=16'b0;
          x[2]<=16'b0;
          x[1]<=16'b0;
          x[0]<=16'b0;
          
      end
      else
      begin // Updating the inputs
      
          x[3]<=x[2]; 
          x[2]<=x[1];
          x[1]<=x[0];
          x[0]<=x_in;
          
      end
  
  
  
 always@( posedge Clk or posedge Rst)
    begin
    if(Rst)
        begin // Initializing the guess for the weight as wn[-1] as 16'b0
        
          wn[0] <= 16'b0;
          wn[1] <= 16'b0;
          wn[2] <= 16'b0;
          wn[3] <= 16'b0;

        end
     else
        begin	// Updating the weights
         
         wn[0] <= wn_u[0];
         wn[1] <= wn_u[1];
         wn[2] <= wn_u[2];
         wn[3] <= wn_u[3];  
         
        end
    end
  
    
  
  
 always@( posedge Clk or posedge Rst)
    begin
    if(Rst)
        begin // Initializing the value for the inverse of autocorrelation as p[-1] = (1/d)I as d tends to zero

          p[0] <= 16'b0000000011111111;
          p[1] <= 16'b0000000000000000;
          p[2] <= 16'b0000000000000000;
          p[3] <= 16'b0000000000000000;
          p[4] <= 16'b0000000000000000;
          p[5] <= 16'b0000000011111111;
          p[6] <= 16'b0000000000000000;
          p[7] <= 16'b0000000000000000;
          p[8] <= 16'b0000000000000000;
          p[9] <= 16'b0000000000000000;
          p[10] <= 16'b0000000011111111;
          p[11] <= 16'b0000000000000000;
          p[12] <= 16'b0000000000000000;
          p[13] <= 16'b0000000000000000;
          p[14] <= 16'b0000000000000000;
          p[15] <= 16'b0000000011111111;

        end
     else
        begin	// Updating the inverse of autocorrelation 
         
          p[0] <= p_u[0];
          p[1] <= p_u[1];
          p[2] <= p_u[2];
          p[3] <= p_u[3];
          p[4] <= p_u[4];
          p[5] <= p_u[5];
          p[6] <= p_u[6];
          p[7] <= p_u[7];
          p[8] <= p_u[8];
          p[9] <= p_u[9];
          p[10] <= p_u[10];
          p[11] <= p_u[11];
          p[12] <= p_u[12];
          p[13] <= p_u[13];
          p[14] <= p_u[14];
          p[15] <= p_u[15];
         
        end
    end

    assign y_out1 = $signed(wn[0])*$signed(x[0]) + $signed(wn[1])*$signed(x[1]) + $signed(wn[2])*$signed(x[2]) + $signed(wn[3])*$signed(x[3]); 
    assign y_out = y_out1[27:12];
    
    assign err = d_in - y_out;
    
    assign k_scale = gamma + l;

    assign m11 = $signed(err)*$signed(k[0]);
    assign m1 = m11[27:12];

    assign m21 = $signed(err)*$signed(k[1]);
    assign m2 = m21[27:12];

    assign m31 = $signed(err)*$signed(k[2]); 
    assign m3 = m31[27:12];

    assign m41 = $signed(err)*$signed(k[3]); 
    assign m4 = m41[27:12];


    assign wn_u[0] = wn[0] + m1;
    assign wn_u[1] = wn[1] + m2;
    assign wn_u[2] = wn[2] + m3;
    assign wn_u[3] = wn[3] + m4;
  

    assign w0 = wn[0];
    assign w1 = wn[1];
    assign w2 = wn[2];
    assign w3 = wn[3];
  
    assign p1 = p_u[0];
    assign p2 = p_u[1];
    assign p3 = p_u[2];
    assign p4 = p_u[3];
    assign p5 = p_u[4];
    assign p6 = p_u[5];
    assign p7 = p_u[6];
    assign p8 = p_u[7];
    assign p9 = p_u[8];
    assign p10 = p_u[9];
    assign p11 = p_u[10];
    assign p12 = p_u[11];
    assign p13 = p_u[12];
    assign p14 = p_u[13];
    assign p15 = p_u[14];
    assign p16 = p_u[15];
  
    assign p_11 = gamma_inverse * p_u_raw_wire[0];
    assign p_u[0] = p_11[27:12];

    assign p_12 = gamma_inverse * p_u_raw_wire[1];
    assign p_u[1] = p_12[27:12];

    assign p_13 = gamma_inverse * p_u_raw_wire[2];
    assign p_u[2] = p_13[27:12];

    assign p_14 = gamma_inverse * p_u_raw_wire[3];
    assign p_u[3] = p_14[27:12];

    assign p_21 = gamma_inverse * p_u_raw_wire[4];
    assign p_u[4] = p_21[27:12];

    assign p_22 = gamma_inverse * p_u_raw_wire[5];
    assign p_u[5] = p_22[27:12];

    assign p_23 = gamma_inverse * p_u_raw_wire[6];
    assign p_u[6] = p_23[27:12];

    assign p_24 = gamma_inverse * p_u_raw_wire[7];
    assign p_u[7] = p_24[27:12];

    assign p_31 = gamma_inverse * p_u_raw_wire[8];
    assign p_u[8] = p_31[27:12];

    assign p_32 = gamma_inverse * p_u_raw_wire[9];
    assign p_u[9] = p_32[27:12];

    assign p_33 = gamma_inverse * p_u_raw_wire[10];
    assign p_u[10] = p_33[27:12];

    assign p_34 = gamma_inverse * p_u_raw_wire[11];
    assign p_u[11] = p_34[27:12];

    assign p_41 = gamma_inverse * p_u_raw_wire[12];
    assign p_u[12] = p_41[27:12];

    assign p_42 = gamma_inverse * p_u_raw_wire[13];
    assign p_u[13] = p_42[27:12];

    assign p_43 = gamma_inverse * p_u_raw_wire[14];
    assign p_u[14] = p_43[27:12];

    assign p_44 = gamma_inverse * p_u_raw_wire[15];
    assign p_u[15] = p_44[27:12];

  

    assign p_u_raw_wire[0] = p[0] - r[0];
    assign p_u_raw_wire[1] = p[1] - r[1];
    assign p_u_raw_wire[2] = p[2] - r[2];
    assign p_u_raw_wire[3] = p[3] - r[3];
    assign p_u_raw_wire[4] = p[4] - r[4];
    assign p_u_raw_wire[5] = p[5] - r[5];
    assign p_u_raw_wire[6] = p[6] - r[6];
    assign p_u_raw_wire[7] = p[7] - r[7];
    assign p_u_raw_wire[8] = p[8] - r[8];
    assign p_u_raw_wire[9] = p[9] - r[9];
    assign p_u_raw_wire[10] = p[10] - r[10];
    assign p_u_raw_wire[11] = p[11] - r[11];
    assign p_u_raw_wire[12] = p[12] - r[12];
    assign p_u_raw_wire[13] = p[13] - r[13];
    assign p_u_raw_wire[14] = p[14] - r[14];
    assign p_u_raw_wire[15] = p[15] - r[15];


    
endmodule

// This is a Multiplier for a 4*4 Matrix to a 4*1 Vector
module MAT_VECT_Mul(
  input signed [15:0] Mat[0:15],
  input signed [15:0] Vect[0:3],
  output signed [15:0] Vect_out[0:3]
);
  wire signed [31:0] Vect_out1, Vect_out2, Vect_out3, Vect_out4;
  
  assign Vect_out1 = $signed(Vect[0])*$signed(Mat[0]) + $signed(Vect[1])*$signed(Mat[1]) +  $signed(Vect[2])*$signed(Mat[2]) +  $signed(Vect[3])*$signed(Mat[3]);
  assign Vect_out[0] = Vect_out1[27:12];
  assign Vect_out2 = $signed(Vect[0])*$signed(Mat[4]) + $signed(Vect[1])*$signed(Mat[5]) +  $signed(Vect[2])*$signed(Mat[6]) +  $signed(Vect[3])*$signed(Mat[7]);
  assign Vect_out[1] = Vect_out2[27:12];
  assign Vect_out3 = $signed(Vect[0])*$signed(Mat[8]) + $signed(Vect[1])*$signed(Mat[9]) +  $signed(Vect[2])*$signed(Mat[10]) +  $signed(Vect[3])*$signed(Mat[11]);
  assign Vect_out[2] = Vect_out3[27:12];
  assign Vect_out4 = $signed(Vect[0])*$signed(Mat[12]) + $signed(Vect[1])*$signed(Mat[13]) +  $signed(Vect[2])*$signed(Mat[14]) +  $signed(Vect[3])*$signed(Mat[15]);
  assign Vect_out[3] = Vect_out4[27:12];

endmodule


// This is a Multiplier for a 1*4 Vector to a 4*4 Matrix
module VECT_MAT_Mul(
  input signed [15:0] Mat[0:15],
  input signed [15:0] Vect[0:3],
  output signed [15:0] Vect_out[0:3]
);
  wire signed [31:0] Vect_out1, Vect_out2, Vect_out3, Vect_out4;
  
  assign Vect_out1 = $signed(Vect[0])*$signed(Mat[0]) + $signed(Vect[1])*$signed(Mat[4]) +  $signed(Vect[2])*$signed(Mat[8]) +  $signed(Vect[3])*$signed(Mat[12]);
  assign Vect_out[0] = Vect_out1[27:12];
  assign Vect_out2 = $signed(Vect[0])*$signed(Mat[1]) + $signed(Vect[1])*$signed(Mat[5]) +  $signed(Vect[2])*$signed(Mat[9]) +  $signed(Vect[3])*$signed(Mat[13]);
  assign Vect_out[1] = Vect_out2[27:12];
  assign Vect_out3 = $signed(Vect[0])*$signed(Mat[2]) + $signed(Vect[1])*$signed(Mat[6]) +  $signed(Vect[2])*$signed(Mat[10]) +  $signed(Vect[3])*$signed(Mat[14]);
  assign Vect_out[2] = Vect_out3[27:12];
  assign Vect_out4 = $signed(Vect[0])*$signed(Mat[3]) + $signed(Vect[1])*$signed(Mat[7]) +  $signed(Vect[2])*$signed(Mat[11]) +  $signed(Vect[3])*$signed(Mat[15]);
  assign Vect_out[3] = Vect_out4[27:12];

endmodule

// This is a Multiplier for a 1*4 Vector to a 4*1 Vector
module VECT_VECT_Mul(
  input signed [15:0] Vect1[0:3],
  input signed [15:0] Vect2[0:3],
  output signed [15:0] Vect_out
);
  wire signed [31:0] Vect_out1;
  
  assign Vect_out1 = $signed(Vect1[0])*$signed(Vect2[0]) + $signed(Vect1[1])*$signed(Vect2[1]) +  $signed(Vect1[2])*$signed(Vect2[2]) +  $signed(Vect1[3])*$signed(Vect2[3]);
  assign Vect_out = Vect_out1[27:12];

endmodule







// This is a Multiplier for a 4*1 Vector to a 1*4 Vector
module VECT_VECT_2Mul(
  input signed [15:0] Vect1[0:3],
  input signed [15:0] Vect2[0:3],
  output signed [15:0] Mat_out[0:15]
);
  wire signed [31:0] Mat_out1[0:15];
  
  assign Mat_out1[0] = $signed(Vect1[0])*$signed(Vect2[0]);
  assign Mat_out[0] = Mat_out1[0][27:12];
  assign Mat_out1[1] = $signed(Vect1[0])*$signed(Vect2[1]);
  assign Mat_out[1] = Mat_out1[1][27:12];
  assign Mat_out1[2] = $signed(Vect1[0])*$signed(Vect2[2]);
  assign Mat_out[2] = Mat_out1[2][27:12];
  assign Mat_out1[3] = $signed(Vect1[0])*$signed(Vect2[3]);
  assign Mat_out[3] = Mat_out1[3][27:12];
  assign Mat_out1[4] = $signed(Vect1[1])*$signed(Vect2[0]);
  assign Mat_out[4] = Mat_out1[4][27:12];
  assign Mat_out1[5] = $signed(Vect1[1])*$signed(Vect2[1]);
  assign Mat_out[5] = Mat_out1[5][27:12];
  assign Mat_out1[6] = $signed(Vect1[1])*$signed(Vect2[2]);
  assign Mat_out[6] = Mat_out1[6][27:12];
  assign Mat_out1[7] = $signed(Vect1[1])*$signed(Vect2[3]);
  assign Mat_out[7] = Mat_out1[7][27:12];
  assign Mat_out1[8] = $signed(Vect1[2])*$signed(Vect2[0]);
  assign Mat_out[8] = Mat_out1[8][27:12];
  assign Mat_out1[9] = $signed(Vect1[2])*$signed(Vect2[1]);
  assign Mat_out[9] = Mat_out1[9][27:12];
  assign Mat_out1[10] = $signed(Vect1[2])*$signed(Vect2[2]);
  assign Mat_out[10] = Mat_out1[10][27:12];
  assign Mat_out1[11] = $signed(Vect1[2])*$signed(Vect2[3]);
  assign Mat_out[11] = Mat_out1[11][27:12];
  assign Mat_out1[12] = $signed(Vect1[3])*$signed(Vect2[0]);
  assign Mat_out[12] = Mat_out1[12][27:12];
  assign Mat_out1[13] = $signed(Vect1[3])*$signed(Vect2[1]);
  assign Mat_out[13] = Mat_out1[13][27:12];
  assign Mat_out1[14] = $signed(Vect1[3])*$signed(Vect2[2]);
  assign Mat_out[14] = Mat_out1[14][27:12];
  assign Mat_out1[15] = $signed(Vect1[3])*$signed(Vect2[3]);
  assign Mat_out[15] = Mat_out1[15][27:12];

endmodule





// Divider for Signed bit fixed point numbers

module Divider(
    input signed [15:0] dividend,
    input signed [15:0] divisor,
    output signed [15:0] quotient
);
    reg signed [31:0] scaled_dividend;
    reg signed [15:0] result;

    always @(*) begin
        if (divisor == 0) begin
            result = 16'b0111111111111111; // Max positive value to indicate error
        end else begin
            scaled_dividend = dividend <<< 12;
            result = scaled_dividend / divisor;
        end
    end

    assign quotient = result;
endmodule





// FIR Filter Module
module FIR_Filter (
  input Clk,
  input Rst,
  input signed [15:0] x,
  output signed [15:0] d
);

  reg signed [15:0] w0, w1, w2, w3;
  reg signed [15:0] xn_0, xn_1, xn_2, xn_3;
  reg signed [31:0] d1;
    

  always @(posedge Clk) 
  begin
    if (Rst) 
	    begin
	      xn_0 <= 0;
	      xn_1 <= 0;
	      xn_2 <= 0;
	      xn_3 <= 0;
	      d1 <= 0;
	    end 
    else 
	    begin
	      xn_3 <= xn_2;
	      xn_2 <= xn_1;
	      xn_1 <= xn_0;
	      xn_0 <= x;
	      d1 <= w0*xn_0 + w1*xn_1 + w2*xn_2 + w3*xn_3;
	    end
  end
  
  assign d = d1[27:12];
  
  initial 
  begin
    w0 =  16'b0000100000000000;
    w1 =  16'b0000100000000000;
    w2 =  16'b0000100000000000;
    w3 =  16'b0000100000000000;
  end

endmodule
