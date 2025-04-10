`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 12:19:51 PM
// Design Name: 
// Module Name: Top_tb
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


module Top_tb(

    );
    
    reg enable           ;
    reg [31:0] addr      ;
    reg [31:0] w_data    ;
    reg [1:0] htrans     ;
    reg [2:0] hsize      ;
    reg hwrite           ;
    reg [2:0]hburst      ;
    reg Master_ready , Slave_ready ;
    reg HCLK             ;
    reg HRESETn          ;
    reg [1:0] HSELx      ;
    wire  [31:0] data_out ;
    
    reg [31:0] mem1 [1023 : 0];
    reg [31:0] mem2 [1023 : 0];
    reg [31:0] mem3 [1023 : 0];
    reg [31:0] mem4 [1023 : 0];
    integer i;
    Top dut (enable,addr,w_data,htrans,hsize,hwrite,hburst,Master_ready,Slave_ready,HCLK,HRESETn,HSELx,data_out);
    
   /* initial begin
        for(i = 0 ; i < 1024 ; i=i+1) begin
                mem1[i] = i+ 0;
                mem2[i] = i+ 1024;
                mem3[i] = i+ 2048;
                mem4[i] = i+ 3072;
        end   
    end*/
    
    always begin
        HCLK = ~HCLK; #5;
    end
    
    
     initial begin
        HCLK=0;
        enable=1;
       
        
        HRESETn=1; #5;
        HRESETn = 0 ; #5;
        HRESETn=1; #5;
       
       
       
        write_INCR4(0,60,60);
        simple_write(0 , 76,76);
        write_WRAP4(1,100,100);
        write_INCR4_with_wait(2,60,60);
        simple_read(0,60);
        simple_read(0,64);
        simple_read(0,68);
        simple_read(0,72);
        simple_read(0,76);
        simple_read(1,100);
        simple_read(1,104);
        simple_read(1,108);
        simple_read(1,96);
        simple_read(2,60);
        simple_read(2,64);
        simple_read(2,68);
        simple_read(2,72);
        #60;
        $finish;
        
        
    end
    
    
   task simple_read(input [1:0] sel, input [31:0] addrr);
        begin
             @(posedge HCLK);
           HSELx = sel;
            hsize =2;
            htrans = 2;
            hburst =0;
            Master_ready =1;
            Slave_ready =1;
            addr = addrr;
            hwrite =0;
            @(posedge HCLK);
             HSELx = sel;
             @( negedge HCLK);
            check(sel , addr);
        end
   endtask
    
    
   task simple_write(input [1:0] sel, input [31:0] addrr , input [31:0] data);
        begin
            @(posedge HCLK);
            HSELx = sel;
            hsize =2;
            htrans = 2;
            hburst =0;
            Master_ready =1;
            Slave_ready =1;
            addr = addrr;
            hwrite =1;
            w_data = data;
            case(sel)
            0: begin
                mem1[addr >> 2] = w_data;
            end
            1: begin
                mem2[addr >> 2] = w_data;
            end
            2: begin
                mem3[addr >> 2] = w_data;
            end
            3: begin
               mem4[addr >> 2] = w_data;
            end
        
            endcase
          
        end
   endtask
    task write_INCR4(input [1:0] sel, input [31:0] addrr , input [31:0] data);
        begin
            @(posedge HCLK);
            HSELx = sel;
            hsize =2;
            htrans = 2;
            hburst =3;
            Master_ready =1;
            Slave_ready =1;
            addr = addrr;
             w_data = data ;
            hwrite =1;
            store(sel , addr , w_data);           
            @(posedge HCLK);
            htrans = 3;
            w_data = data + 4;
            store(sel , addr + 4, w_data);
            @(posedge HCLK);
            w_data = data + 8;
            store(sel , addr + 8, w_data);
            @(posedge HCLK);
            w_data = data + 12;
            store(sel , addr + 12, w_data);
          
        end
    endtask
    
     task write_INCR4_with_wait(input [1:0] sel, input [31:0] addrr , input [31:0] data);
        begin
            @(posedge HCLK);
            HSELx = sel;
            hsize =2;
            htrans = 2;
            hburst =3;
            Master_ready =1;
            Slave_ready =1;
            addr = addrr;
             w_data = data ;
            hwrite =1;
            store(sel , addr , w_data);           
            @(posedge HCLK);
            htrans = 3;
            w_data = data + 4;
            store(sel , addr + 4, w_data);
            @(posedge HCLK);
            
            w_data = data + 8;
            store(sel , addr + 8, w_data);
            @(posedge HCLK);
            Master_ready =0;
            Slave_ready =0;
            w_data = data + 12;
            store(sel , addr + 12, w_data);
            @(posedge HCLK);
            Master_ready =1;
            Slave_ready =1;
            w_data = data + 12;
            store(sel , addr + 12, w_data);
          
        end
    endtask
    
    task write_WRAP4(input [1:0] sel, input [31:0] addrr , input [31:0] data);
        begin
            @(posedge HCLK);
            HSELx = sel;
            hsize =2;
            htrans = 2;
            hburst =2;
            Master_ready =1;
            Slave_ready =1;
            addr = addrr;
             w_data = data ;
            hwrite =1;
            store(sel , addr , w_data);           
            @(posedge HCLK);
            htrans = 3;
            w_data = data + 4;
            store(sel , addr + 4, w_data);
            @(posedge HCLK);
            w_data = data + 8;
            store(sel , addr + 8, w_data);
            @(posedge HCLK);
            w_data = data + 12;
            store(sel ,96, w_data);
            
            
        end
    endtask
    
    
   task check (input [1:0] sel, input [31:0] addr );
    begin
        case(sel)
            0: begin
                if(mem1[addr >> 2 ] == data_out) $display("Slave1 SUccess ");
                else $display ("Slave 1 FAIL mem = %0d, data_out = %0d at t = %0t" , mem1[addr >> 2] , data_out,$time);
            end
            1: begin
                if(mem2[addr >> 2 ] == data_out) $display("Slave2 SUccess ");
                else $display ("Slave 2 FAIL mem = %0d, data_out = %0d" , mem2[addr >> 2] , data_out);
            end
            2: begin
                if(mem3[addr >> 2 ] == data_out) $display("Slave3 SUccess ");
                else $display ("Slave 3 FAIL mem = %0d, data_out = %0d" , mem3[addr >> 2] , data_out);
            end
            3: begin
                if(mem4[addr >> 2 ] == data_out) $display("Slave4 SUccess ");
                else $display ("Slave 4 FAIL mem = %0d, data_out = %0d" , mem4[addr >> 2] , data_out);
            end
        
        endcase
    end
   endtask 
    
   task store(input [1:0] sel, input [31:0] addr , input [31:0] data);
    begin
        case(sel)
            0: begin
                mem1[addr >> 2] = data;
            end
            1: begin
                mem2[addr >> 2] = data;
            end
            2: begin
                mem3[addr >> 2] = data;
            end
            3: begin
               mem4[addr >> 2] = data;
            end
        
            endcase
    end
   
   endtask 
    
endmodule
