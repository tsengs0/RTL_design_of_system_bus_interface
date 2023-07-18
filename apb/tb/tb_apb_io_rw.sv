module tb_apb_io_rw;

localparam CLK_PERIOD=100;
localparam APB_ADDR_WIDTH = 5;
localparam APB_DATA_WIDTH = 32;
// system
logic          rstn;
logic          clk_en; // clock gating 
// APB
logic         pclk;
logic [ 15:0] paddr; // ls 2 bits are unused 
logic         pwrite;
logic         psel;
logic         penable;
logic [ 31:0] pwdata;
logic [ 31:0] prdata;
logic         pready;
logic         pslverr;

// Interface
logic  [ 31:0] status32b;
logic  [ 15:0] status16b;
logic  [  7:0] status8b;
logic [ 31:0] control32b;
logic [ 15:0] control16b;
logic [  7:0] control8b;

apb_bus #(
   .CLKPER(CLK_PERIOD)
) apb_bus0 (
// APB
   .pclk     (pclk),
   .paddr    (paddr),
   .pwrite   (pwrite),
   .psel     (psel),
   .penable  (penable),
   .pwdata   (pwdata),
   .prdata   (prdata),
   .pready   (pready),
   .pslverr  (pslverr)
); 

apb_io_rw # (
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .APB_DATA_WIDTH(APB_DATA_WIDTH)
) apb_io_rw_dut (
  .clk_en (clk_en), // clock gating
  .PRDATA(prdata),
  .PREADY(pready),
  .PSLVERR(pslverr),
  .PCLK(pclk),
  .PRESETn(rstn),
  .PSEL(psel),
  .PENABLE(penable),
  .PWRITE(pwrite),
  .PADDR(paddr[4:0]),
  .PWDATA(pwdata),
  .control32b_o(control32b),
  .control16b_o(control16b),
  .control8b_o(control8b),
  .status32b_i(status32b),
  .status16b_i(status16b),
  .status8b_i(status8b)
);

initial begin
// system
   rstn    = 1'b0;
   clk_en     = 1'b1;

// Interface
   status32b   = 32'h9c4e9a31;
   status16b   = 16'h7832;
   status8b    = 16'h2a;
      
   @(posedge pclk) #(CLK_PERIOD*100); 
   rstn = 1'b1;
    
   #(CLK_PERIOD*5) ; 
   apb_bus0.read(16'h00,32'h9c4e9a31);
   apb_bus0.read(16'h04,32'h7832);
   apb_bus0.read(16'h08,32'h2a);
   apb_bus0.read(16'h14,32'h1234); // reset value 
       
   apb_bus0.write(16'h10,32'h11223344);
   apb_bus0.write(16'h14,32'hAABB);
   apb_bus0.write(16'h18,32'hDD);
   apb_bus0.read(16'h10,32'h11223344);
   apb_bus0.read(16'h14,32'hxxxxAABB);
   apb_bus0.read(16'h18,32'hxxxxxxDD);
   apb_bus0.read(16'h1C,32'h00216948); // Expect "Hi!" (Reverse endian)
   apb_bus0.delay(3);
   if (apb_bus0.errors==0)
      $display("apb_regs test passed");
   else
      $display("apb_regs test FAILED!");
	#500 $stop;       
end

property apb_write_phase;
   @(posedge apb_io_rw_dut.PCLK) apb_io_rw_dut.apb_write_access == 1'b1 |-> (apb_io_rw_dut.PSEL && apb_io_rw_dut.PENABLE && apb_io_rw_dut.PWRITE);
endproperty
apb_write_phase_check: assert property(apb_write_phase)
                        else $error("Write phase is not compliant with APB protocol.");


// dump wave
initial begin
   $dumpfile("tb_apb_io_rw.vcd");
   $dumpvars(5, tb_apb_io_rw);
end
endmodule
