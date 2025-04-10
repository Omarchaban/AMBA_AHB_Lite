`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 12:06:14 PM
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top
    #(parameter DATA_WIDTH = 32)
    (
    input enable,
    input [31:0] addr,
    input [31:0] w_data,
    input [1:0] htrans,
    input [2:0] hsize,
    input hwrite,
    input [2:0]hburst,
    input Master_ready , Slave_ready, /////
  
    input HCLK,
    input HRESETn,
    input [1:0] hselx, /////
    output  [31:0] data_out
    );
    wire HREADY;
    wire HRESP;
    wire HRESP1;
    wire HRESP2;
    wire HRESP3;
    wire HRESP4;
    wire HREADYOUT1;
    wire HREADYOUT2;
    wire HREADYOUT3;
    wire HREADYOUT4;
    wire [DATA_WIDTH-1:0]HRDATA1;
    wire [DATA_WIDTH-1:0]HRDATA2;
    wire [DATA_WIDTH-1:0]HRDATA3;
    wire [DATA_WIDTH-1:0]HRDATA4;
    wire HSEL_1;
    wire HSEL_2;
    wire HSEL_3;
    wire HSEL_4;
    wire [1:0]HSEL , Multiplexor_SEL;
    //wire Master_ready , Slave_ready;
    
    
        wire [31:0] HWDATA;
        wire [31:0] HRDATA;
        wire [31:0] HADDR;
        wire [2:0]  HBURST;
        wire [2:0]  HSIZE;
        wire [1:0] HTRANS;
        wire HWRITE;
        wire HREADYout;
    master Master
   (

    //User inputs
    
     .enable(enable),
     .addr(addr),
     .w_data(w_data),
     .htrans(htrans),
     .hsize(hsize),
     .hwrite(hwrite),
     .hselx(hselx),
     .hburst(hburst),
  
     .HCLK(HCLK),
     .HRESETn(HRESETn),
     .HREADY(Master_ready),
     .HRESP(HRESP),
     .HRDATA(HRDATA),
     .HSELx(HSEL),
     .HWRITE(HWRITE),
    . HADDR(HADDR),
     .HWDATA(HWDATA),
     .HSIZE(HSIZE),
    . HBURST(HBURST),
    . HTRANS(HTRANS),
    . data_out(data_out)
    );
    
    slave Slave1
    
    (
    //Inputs
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HREADY(Slave_ready),
    .HWRITE(HWRITE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HSIZE(HSIZE),
    .HSELx(HSEL_1),
    .HWDATA(HWDATA),
    .HADDR(HADDR),
    .HREADYout(HREADYOUT1),
    .HRESP(HRESP1),
    .HRDATA(HRDATA1)
    );
    
    slave
     #(1024 , 1 ,  1024) 
     Slave2
    (
    //Inputs
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HREADY(Slave_ready),
    .HWRITE(HWRITE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HSIZE(HSIZE),
    .HSELx(HSEL_2),
    .HWDATA(HWDATA),
    .HADDR(HADDR),
    .HREADYout(HREADYOUT2),
    .HRESP(HRESP2),
    .HRDATA(HRDATA2)
    );
    
    slave 
    #(1024 , 1 ,  2048) 
    Slave3
    (
    //Inputs
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HREADY(Slave_ready),
    .HWRITE(HWRITE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HSIZE(HSIZE),
    .HSELx(HSEL_3),
    .HWDATA(HWDATA),
    .HADDR(HADDR),
    .HREADYout(HREADYOUT3),
    .HRESP(HRESP3),
    .HRDATA(HRDATA3)
    );
    slave 
    #(1024 , 1 ,  3072) 
    Slave4
    (
    //Inputs
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HREADY(Slave_ready),
    .HWRITE(HWRITE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HSIZE(HSIZE),
    .HSELx(HSEL_4),
    .HWDATA(HWDATA),
    .HADDR(HADDR),
    .HREADYout(HREADYOUT4),
    .HRESP(HRESP4),
    .HRDATA(HRDATA4)
    );
    
    
    Decoder Decode
    (.SEL(HSEL),
	.HSEL_1(HSEL_1),
	.HSEL_2(HSEL_2),
	.HSEL_3(HSEL_3),
	.HSEL_4(HSEL_4),
    .Multiplexor_SEL(Multiplexor_SEL)
    );

    Multiplexor Mux(
    .HRDATA1(HRDATA1),
	.HRDATA2(HRDATA2),
	.HRDATA3(HRDATA3),
	.HRDATA4(HRDATA4),
    .HRESP1(HRESP1),
	.HRESP2(HRESP2),
	.HRESP3(HRESP3),
	.HRESP4(HRESP4),
	.HREADYOUT1(HREADYOUT1),
	.HREADYOUT2(HREADYOUT2),
	.HREADYOUT3(HREADYOUT3),
	.HREADYOUT4(HREADYOUT4),
	.SEL(Multiplexor_SEL),
	.HRDATA(HRDATA),
	.HREADYOUT(HREADYout),
	.HRESP(HRESP)
 	);
    
    
    
    
    
    
    
endmodule
