`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2025 10:17:56 AM
// Design Name: 
// Module Name: master
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


module master
    
   (

    //User inputs
    
    input enable,
    input [31:0] addr,
    input [31:0] w_data,
    input [1:0] htrans,
    input [2:0] hsize,
    input hwrite,
    input [1:0] hselx,
    input [2:0]hburst,
    //Standard inputs
    input HCLK,
    input HRESETn,
    input HREADY,
    input HRESP,
    input [31:0] HRDATA,
    
    //Standard Outputs
    output [1:0] HSELx,
    output   HWRITE,
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg [2:0]  HSIZE,
    output reg [2:0]  HBURST,
    output reg [1:0] HTRANS,
    output reg [31:0] data_out
    );
    
    parameter IDLE=0 , WRITE = 1 , READ = 2  ; 
    
      // HBURST PARAMETERS
      parameter SINGLE     = 3'b000;
      parameter INCR       = 3'b001;
      parameter WRAP4      = 3'b010;
      parameter INCR4      = 3'b011;
      parameter WRAP8      = 3'b100;
      parameter INCR8      = 3'b101;
      parameter WRAP16     = 3'b110;
      parameter INCR16     = 3'b111;
      
    parameter ERROR=1;  
    reg [1:0] current_state , next_state;
    reg [10:0] burst_counter , wrap_counter;
    reg half_of_wrap;
    /*
    These flags were made because when HTRANS is busy the HADDR must be for the new location not the old one
    but if the state took more than one cycle the address must remain stable i.e the address from the
    first busy state must remain stable
    */
    
    reg burst_counter_busy_flag,wrap_counter_busy_flag, HREADY_flag;
    //current_state logic
    reg [31:0] HWDATA_reg_c,HWDATA_reg_d;
    reg [31:0] temp_addr;   
    
  
  
    reg [31:0] wrap , address;
    
   
    assign HSELx = hselx;
    assign HWRITE = hwrite;
    always @ (*) begin
        case (hburst) 
            WRAP4: begin
                wrap= ((temp_addr >> 4) <<4);
                address = wrap + 16;
            end
            WRAP8: begin
                wrap= ((temp_addr >> 5) <<5);
                address = wrap + 32;
            end
            WRAP16: begin
                wrap= ((temp_addr >> 6) <<6);
                address = wrap + 64;
            end
            default : begin
                wrap =0;
                address =0;
            end
                
        endcase
    
    end
    
    always @(posedge HCLK or negedge HRESETn ) begin
        if(!HRESETn) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    //next_state logic
     always @(*) begin
        case(current_state) 
            IDLE: begin
                if(enable) begin
                    if(HRESP == ERROR) begin
                       next_state = IDLE; 
                    end    
                    else if(hwrite) begin
                        next_state = WRITE;
                    end
                    else begin
                        next_state = READ;
                    end
                end
                else begin
                    next_state = IDLE;
                end
               
            end
            WRITE: begin 
                if(enable) begin
                    if(HREADY) begin
                        if(HRESP == ERROR) begin
                           next_state = IDLE; 
                        end    
                        else if(hwrite) begin
                            next_state = WRITE;
                        end
                        else begin
                            next_state = READ;
                        end
                    end
                    else begin
                        next_state =next_state ;
                    end
                end
                else begin
                    next_state =IDLE ;
                end
            end
            READ: begin
                if(enable) begin
                    if(HREADY) begin
                        if(HRESP == ERROR) begin
                           next_state = IDLE; 
                        end    
                        else if(hwrite) begin
                            next_state = WRITE;
                        end
                        else begin
                            next_state = READ;
                        end
                    end
                    else begin
                        next_state =next_state ;
                    end
                end
                else begin
                    next_state =IDLE ;
                end
               
            end
          
           
            default: begin
                next_state = IDLE;
            end
        endcase
    
    end
    
   
    
    always @(*) begin
       
        case(current_state)
            IDLE: begin
         
                HADDR=0;
                HWDATA=0;
                HSIZE=0;
                HBURST=0;
                HTRANS=0;
                data_out=0;
                
            end
            WRITE: begin
                 
              if(~HREADY) begin
                HWDATA=HWDATA_reg_c;
              end
              else begin
                HWDATA=HWDATA_reg_d;
              end
              
                HSIZE=hsize;
                HBURST=hburst;
                HTRANS=htrans;
                data_out=data_out;
                case (HBURST)
                    INCR, INCR4, INCR8, INCR16: HADDR=burst_counter;
                    WRAP4, WRAP8, WRAP16 :  HADDR=wrap_counter;
                    SINGLE : HADDR= addr;
                endcase
                
            end
            READ: begin
               
               if(~HREADY) begin
                HWDATA=HWDATA_reg_c;
              end
              else begin
                HWDATA=HWDATA_reg_d;
              end
                HSIZE=hsize;
                HBURST=hburst;
                HTRANS=htrans;
                data_out = HRDATA;
            
                case (HBURST)
                    INCR, INCR4, INCR8, INCR16: HADDR=burst_counter;
                    WRAP4, WRAP8, WRAP16 :  HADDR=wrap_counter ;
                    SINGLE : HADDR= addr;
                endcase
                
            end
            
            default: begin
                data_out=0;
                HADDR=0;
                HWDATA=0;
                HSIZE=0;
                HBURST=0;
                HTRANS=0;
            end
        endcase 
    end
    
     always @(posedge HCLK or negedge HRESETn ) begin
     
         if(!HRESETn) begin
            burst_counter <=0;
            burst_counter_busy_flag <=0;
           
        end
        else begin
            if(HREADY) begin
                if ( htrans == 2 )  begin
                    burst_counter <= addr;
                    temp_addr <= addr;
                end
                else if (htrans == 3) begin
                    
                    case (hburst) 
                        INCR: begin
                            if(~burst_counter_busy_flag ) begin
                                burst_counter <= burst_counter+4;
                            end
                            else begin
                                burst_counter_busy_flag  <=0;
                            end
                        end
                        INCR4: begin
                            if(~burst_counter_busy_flag ) begin
                                if(burst_counter < temp_addr +12 ) begin
                                    burst_counter <= burst_counter+4;
                                end
                            end    
                            else begin
                                burst_counter_busy_flag  <=0;
                            end
                        end
                        INCR8: begin
                            if(~burst_counter_busy_flag ) begin
                                if(burst_counter < temp_addr +28 ) begin
                                    burst_counter <= burst_counter+4;
                                end
                            end    
                            else begin
                                burst_counter_busy_flag  <=0;
                            end
                        end
                        INCR16: begin
                            if(~burst_counter_busy_flag ) begin
                                if(burst_counter < temp_addr +60 ) begin
                                    burst_counter <= burst_counter+4;
                                end
                            end    
                            else begin
                                burst_counter_busy_flag  <=0;
                            end
                        end
                        default : begin
                            burst_counter <=burst_counter;
                        end
                    endcase
                end
                else if (htrans == 1 ) begin
                    if(burst_counter_busy_flag) begin
                         burst_counter <=burst_counter;
                    end     
                     else begin 
                         burst_counter <=burst_counter +4 ;
                         burst_counter_busy_flag <=1;
                     end    
                end
                else begin
                    burst_counter <=burst_counter;
                end
            end
            else if (htrans == 1 )begin
                if(~burst_counter_busy_flag) begin
                    burst_counter <=burst_counter + 4;
                    burst_counter_busy_flag <=1;
                end
                else begin 
                    burst_counter <=burst_counter  ;                    
                end 
            end
        end
     
     end
    
    always @(posedge HCLK or negedge HRESETn ) begin
     
         if(!HRESETn) begin
            HWDATA_reg_c <= 0;
            HWDATA_reg_d <=0;
            
        end
        else begin
            if(HREADY ) begin
                HWDATA_reg_c <= w_data;
                HWDATA_reg_d <=HWDATA_reg_c;
                
            end
            
            
        end
     
     end
     
      always @(posedge HCLK or negedge HRESETn ) begin
     
         if(!HRESETn) begin
            wrap_counter <= 0;
            wrap_counter_busy_flag <=0;
           
        end
        else begin
            if(HREADY) begin
                if(htrans == 2) begin
                    wrap_counter <= addr;
                end
                else if (htrans == 3) begin
                    if(~wrap_counter_busy_flag) begin
                        if(wrap_counter >= address - 4) begin
                            wrap_counter <= wrap;
                        end
                        else begin
                            wrap_counter <= wrap_counter+4;
                        end
                    end
                    else begin
                       wrap_counter_busy_flag <=0;                
                    end
                end
                else if (htrans == 1 ) begin
                    if(wrap_counter_busy_flag) begin
                         wrap_counter <=wrap_counter;
                    end     
                    else begin 
                         wrap_counter <=wrap_counter +4 ;
                         wrap_counter_busy_flag <=1;
                    end    
                end
            end
            else begin
                if(~wrap_counter_busy_flag) begin
                    wrap_counter <=wrap_counter + 4;
                    wrap_counter_busy_flag <=1;
                end
                else begin 
                    wrap_counter <=wrap_counter  ;
                    
                end 
            end
         end 
      end
     
     
     
    

endmodule
