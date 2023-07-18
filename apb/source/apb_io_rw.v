/*
* Create: 18th July, 2020
* Revise: 18th July, 2023
* Developer: Bo-Yu Tseng
* Email: tsengs0@gamil.com
* Module name: apb_io_rw
* 
* # I/F
* 1) Output:
*
* 2) Input:
*
* # Param

* # Description:
    0x00: 32 bits read of status32_i port
    0x04: 32 bit read & write of control32_o port
    0x08: 
        a) write phase: 16 bits wire of control16_o port
        b) read phase: 32 bits read of concatenation of 16-bit status16b_i and 16-bit control16_o ports
    0x0C: 
        a) write phase: 8-bit wire of control8_o port
        b) read phase: 32-bit read of concatenation of 8-bit status8b_i and 8-bit control8_o ports
* # Dependencies
*
* # Xilinx 7-series or Ultrascale+ Resource utilisation:
*		LUT: 14
        Logic LUT: 8
        LUTRAM: 6
		FF: 3
        I/O: 22
        Freq: 400MHz
        WNS: +1.998 ns
        TNS: 0.0 ns
        WHS: +0.093 ns
        THS: 0.0 ns
        WPWS: 0.718 ns
        TPWS: 0.0 ns
**/
module apb_io_rw #(
    parameter APB_ADDR_WIDTH = 5,
    parameter APB_DATA_WIDTH = 32
)(
    // AMBA 3 APB I/F
    output reg [APB_DATA_WIDTH-1:0] PRDATA,
    output wire PREADY,
    output wire PSLVERR,

    input wire PCLK,
    input wire PRESETn,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [APB_ADDR_WIDTH-1:0] PADDR,
    input wire [APB_DATA_WIDTH-1:0] PWDATA,

    // Register and system control I/F
    output reg [31:0] control32b_o,
    output reg [15:0] control16b_o,
    output reg [7:0]  control8b_o,
    input wire [31:0] status32b_i,
    input wire [15:0] status16b_i,
    input wire [7:0]  status8b_i,

    input wire clk_en // clock gating
);

wire apb_access_phase = PSEL & PENABLE;
wire apb_write_access = apb_access_phase & PWRITE;
wire apb_read_access = apb_access_phase & ~PWRITE;
wire rstn;
wire gclk; // gated clock sourcd
assign PREADY = 1'b1;
assign PSLVERR = 1'b0;
assign rstn = PRESETn;
assign gclk = clk_en & PCLK;


// To generate control signal (GPIO) by APB write
always @(posedge gclk) begin
    if(rstn == 1'b0) begin
        control32b_o <= 0;
        control16b_o <= 0;
        control8b_o  <= 0;
    end
    else if(apb_write_access==1'b1) begin
        case (PADDR)
            4'h4: control32b_o <= PWDATA[31:0];
            4'h8: control16b_o <= PWDATA[15:0];
            4'hC: control8b_o  <= PWDATA[7:0];
            default: begin
                control32b_o <= {32{1'bx}};
                control16b_o <= {16{1'bx}};
                control8b_o <= {8{1'bx}};
            end
        endcase
    end
end

// To read status register by APB read
always @(posedge gclk) begin
    if(!rstn) begin
        PRDATA <= 0;
    end
    else if(apb_read_access==1'b1) begin
        case (PADDR)
            4'h0: PRDATA[APB_DATA_WIDTH-1:0] <= status32b_i[31:0];
            4'h4: PRDATA[APB_DATA_WIDTH-1:0] <= control32b_o[31:0];
            4'h8: PRDATA[APB_DATA_WIDTH-1:0] <= {status16b_i[15:0], control16b_o[15:0]};
            4'hC: PRDATA[APB_DATA_WIDTH-1:0] <= {8'h00, status8b_i[7:0], 8'h00, control8b_o[7:0]};
        endcase
    end
    else PRDATA[APB_DATA_WIDTH-1:0] <= 32'd0;
end
endmodule