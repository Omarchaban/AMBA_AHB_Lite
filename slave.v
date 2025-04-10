`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2025 01:16:44 PM
// Design Name: 
// Module Name: slave
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

/*

*/
module slave
#(parameter ADDR_DEPTH = 1024 , hsel = 1 , mem_rst = 0)
    (
    //Inputs
    input HCLK,
    input HRESETn,
    input HREADY,
    input HWRITE,
    input HMASTLOCK,
    input [1:0] HTRANS,
    input [2:0] HBURST,
    input [2:0] HSIZE,
    input  HSELx,
    input [3:0] HPROT,
    input [31:0] HWDATA,
    input [31:0] HADDR,
    
    //Outputs
    output reg HREADYout,
    output reg HRESP,
    output reg [31:0] HRDATA
    
    );
    
    parameter OKAY =0 , error = 1 ;
    
    parameter IDLE=0 , WRITE = 1 , READ = 2 , BUSY = 3 ,ERROR = 4; 
    
    reg [2:0] current_state , next_state;
    
    
    reg [31:0] mem [ADDR_DEPTH-1 : 0];
    
    reg [31:0]  ADDR_buf;
    reg [31:0] HRDATA_buf1,HRDATA_buf2;
    reg sel_buf1 ;
    reg  Busy_flag;
    integer i;
    always @(posedge HCLK or negedge HRESETn ) begin
        if(!HRESETn) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    //dont forget to make the read delayed cycle after the address is received
    always @(posedge HCLK or negedge HRESETn ) begin
        if(!HRESETn) begin
           
            HRDATA_buf1 <=0;
            HRDATA_buf2 <=0;
            ADDR_buf <=0;
            sel_buf1 <=0;
            for(i = 0 ; i < 1024 ; i=i+1) begin
                mem[i] = i+ mem_rst;              
            end             
        end
        else begin
        
            if(HREADY) begin
                HRDATA_buf1 <= mem[HADDR >> 2];
                HRDATA_buf2 <= HRDATA_buf1 ;
                ADDR_buf <= HADDR >>2;
                sel_buf1 <= HSELx;
               
            end
           
        end
    end
    always @(posedge HCLK or negedge HRESETn ) begin
        if(!HRESETn) begin
            Busy_flag <=0;
        end
        else begin
            if(current_state == BUSY) begin
                Busy_flag <=1;
             
            end
            else begin
                Busy_flag <=0;
            end
        end
        
    end
   
    
    always @(*) begin
        case(current_state)
            IDLE: begin
                if(HWRITE && HREADY /*&& HSELx == hsel*/) begin
                    next_state = WRITE;
                end
                else if (~HWRITE && HREADY /*&& HSELx == hsel*/) begin
                    next_state = READ;
                end
                else begin
                    next_state = IDLE;
                end
            end
            WRITE: begin
                if(HREADY) begin
                    if(ADDR_buf > ADDR_DEPTH) begin
                        next_state = ERROR;
                    end
                    else if(HTRANS == 1 ) begin
                        next_state = BUSY;
                    end
                    else if ( HTRANS == 2 || HTRANS == 3) begin
                         if(HWRITE && HREADY && HSELx == hsel) begin
                             next_state = WRITE;
                         end
                         else if (~HWRITE && HREADY && HSELx == hsel) begin
                              next_state = READ;
                          end
                          else begin
                             next_state =IDLE;
                         end 
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    if(HTRANS == 0) begin 
                        next_state = IDLE;
                    end
                    else begin
                        next_state =next_state;
                    end
                end
            end
            READ: begin
                 if(HREADY) begin
                    if(ADDR_buf > ADDR_DEPTH) begin
                        next_state = ERROR;
                    end
                    else if(HTRANS == 1 ) begin
                        next_state = BUSY;
                    end
                    else if ( HTRANS == 2 || HTRANS == 3) begin
                         if(HWRITE && HREADY && HSELx == hsel) begin
                             next_state = WRITE;
                         end
                         else if (~HWRITE && HREADY && HSELx == hsel) begin
                              next_state = READ;
                         end 
                         else begin
                             next_state =IDLE;
                         end
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    if(HTRANS == 0) begin 
                        next_state = IDLE;
                    end
                    else begin
                        next_state =next_state;
                    end
                end
            end
            BUSY: begin
                if(HTRANS == 1 ) begin
                        next_state = BUSY;
                end
                else if ( HTRANS == 2 || HTRANS == 3) begin
                         if(HWRITE && HREADY && HSELx == hsel) begin
                             next_state = WRITE;
                         end
                         else if (~HWRITE && HREADY && HSELx == hsel) begin
                              next_state = READ;
                         end 
                end
                else begin
                        next_state = IDLE;
                end
            end
            ERROR: begin
              
                    next_state = IDLE;
                
            end
            default : begin
            end
        endcase
    end
    
    always @(*) begin
        case(current_state)
            IDLE: begin
                HREADYout =0;
                HRESP = OKAY;
                HRDATA =0;
            end
            WRITE: begin
                HRDATA =HRDATA;
               if(ADDR_buf > ADDR_DEPTH) begin
                    HRESP = error;
                    HREADYout =0;
                    
               end
               else begin
                    case(HSIZE)
                    0: begin mem[ADDR_buf] = {{24{1'b0}},HWDATA[7:0]};      end
                    1: begin mem[ADDR_buf] = {{16{1'b0}},HWDATA[15:0]};     end
                    2: begin mem[ADDR_buf] = HWDATA;                        end
                    default: begin mem[ADDR_buf] = HWDATA;                  end
                    endcase
                    HRESP = OKAY;
                    HREADYout =1;
               end
            end
            READ: begin
               if(ADDR_buf > ADDR_DEPTH) begin
                    HRESP = error;
                    HREADYout =0;
                    HRDATA =HRDATA;
               end
               else begin
                    if(Busy_flag ) begin
                        HRDATA =HRDATA ;
                        HRESP = HRESP;
                        HREADYout = HREADYout;
                    end
                    else begin
                        if(HREADY) begin
                            //HRDATA = mem[ADDR_buf];
                            HRDATA = HRDATA_buf1;
                            HREADYout =1;
                            HRESP = OKAY;
                        end
                        else begin
                            HRDATA =HRDATA_buf2 ;
                            HRESP = HRESP;
                            HREADYout = HREADYout;
                        end
                    end
               end
            end
            BUSY: begin
              
                if(Busy_flag == 0) begin
                    HRDATA =HRDATA_buf2 ;
                end
                else begin
                    HRDATA = HRDATA ;
                end
               
                HRESP = HRESP;
                HREADYout = HREADYout;
            end
            ERROR: begin
                HRESP = error;
                HREADYout =1;
            end
            default : begin
                HREADYout =0;
                HRESP = OKAY;
                HRDATA =0;
            end
        endcase
    end
    
    
endmodule
