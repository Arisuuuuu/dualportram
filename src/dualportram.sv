module dualportram
#(
  parameter RAM_SIZE = 8192,
  parameter INIT = ""
)
(
  input   logic       clk_i,
  input   logic       rst_n_i,
  
  input   logic       req1_i,
  input   logic       we1_i,
  input   logic[3:0]  be1_i,
  input   logic[31:0] addr1_i,
  input   logic[31:0] wdata1_i,
  output  logic       rvalid1_o,
  output  logic[31:0] rdata1_o,

  input   logic       req2_i,
  input   logic       we2_i,
  input   logic[3:0]  be2_i,
  input   logic[31:0] addr2_i,
  input   logic[31:0] wdata2_i,
  output  logic       rvalid2_o,
  output  logic[31:0] rdata2_o
);


  logic [31:0] ram[RAM_SIZE];
  logic [$clog2(RAM_SIZE)-1:0] addr1, addr2;
  assign addr1 = addr1_i[$clog2(RAM_SIZE)+1 : 2];
  assign addr2 = addr2_i[$clog2(RAM_SIZE)+1 : 2];


  always_ff @(posedge clk_i) begin
    if(req1_i && we1_i) begin
      $display("we wrint");
      if(be1_i[0]) ram[addr1][7:0] <= wdata1_i[7:0];
      if(be1_i[1]) ram[addr1][15:8] <= wdata1_i[15:8];
      if(be1_i[2]) ram[addr1][23:16] <= wdata1_i[23:16];
      if(be1_i[3]) ram[addr1][31:24] <= wdata1_i[31:24];
    end else begin
      rdata1_o <= ram[addr1];
    end
    

    if(req2_i && we2_i) begin
      if(be2_i[0]) ram[addr2][7:0] <= wdata2_i[7:0];
      if(be2_i[1]) ram[addr2][15:8] <= wdata2_i[15:8];
      if(be2_i[2]) ram[addr2][23:16] <= wdata2_i[23:16];
      if(be2_i[3]) ram[addr2][31:24] <= wdata2_i[31:24];
    end else begin
      rdata2_o <= ram[addr2];
    end


  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
      rvalid1_o <= '0;
      rvalid2_o <= '0;
    end else begin
      rvalid1_o <= req1_i;
      rvalid2_o <= req2_i;
    end
  end

  initial begin
    integer i;
    for(i=0; i<RAM_SIZE; i=i+1) begin
      ram[i] = 32'h0;
    end
    if(INIT != "") $readmemh(INIT, ram);
  end

endmodule
