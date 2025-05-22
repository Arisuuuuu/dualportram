`timescale 1ns / 1ps

module dualportram_tb ();


  parameter RAM_SIZE = 8192;

  logic       clk = 0;
  logic       rst_n = 0;

  logic       req1_i, we1_i;
  logic[3:0]  be1_i;
  logic[31:0] addr1_i, wdata1_i;
  logic       rvalid1_o;
  logic[31:0] rdata1_o;

  logic       req2_i, we2_i;
  logic[3:0]  be2_i;
  logic[31:0] addr2_i, wdata2_i;
  logic       rvalid2_o;
  logic[31:0] rdata2_o;

  logic[31:0] rdata;


  always #10 clk = ~clk;


  task write_port1(input [31:0] addr, input [31:0] data, input [3:0] be);
    addr1_i = addr;
    wdata1_i = data;
    be1_i = be;
    we1_i = 1;
    req1_i = 1;
    @(posedge clk);
    #1;
    req1_i = 0;
    we1_i = 0;
  endtask

  task write_port2(input [31:0] addr, input [31:0] data, input [3:0] be);
    addr2_i = addr;
    wdata2_i = data;
    be2_i = be;
    we2_i = 1;
    req2_i = 1;
    @(posedge clk);
    #1;
    req2_i = 0;
    we2_i = 0;
  endtask

  task read_port1(input [31:0] addr, output [31:0] data);
    @(posedge clk);
    addr1_i = addr;
    req1_i = 1;
    we1_i = 0;
    @(posedge clk);
    req1_i = 0;
    @(posedge clk);
    data = rdata1_o;
  endtask

  task read_port2(input [31:0] addr, output [31:0] data);
    addr2_i = addr;
    req2_i = 1;
    we2_i = 0;
    @(posedge clk);
    req2_i = 0;
    @(posedge clk);
    data = rdata2_o;
  endtask

  //test stimulus
  initial begin
    req1_i = 0;
    we1_i = 0;
    be1_i = 0;
    addr1_i = 0;
    wdata1_i = 0;

    req2_i = 0;
    we2_i = 0;
    be2_i = 0;
    addr2_i = 0;
    wdata2_i = 0;

    rst_n = 0;
    #20;
    @(posedge clk);
    rst_n = '1;
    @(posedge clk);

    //full write
    #1;
    write_port1(32'h0000_0000, 32'hDEADBEEF, 4'b1111);
    read_port1(32'h0000_0000, rdata);
    assert (rdata == 32'hDEADBEEF) else $fatal(1,"failed 1");

    //partial write
    write_port2(32'h0000_0004, 32'hFFFFAAAA, 4'b1100);
    read_port2(32'h0000_0004, rdata);
    assert (rdata[31:16] == 16'hFFFF) else $fatal(1,"failed 2");
    assert (rdata[15:0] == 16'h0000) else $fatal(1,"failed 3");

    //write to different address
    fork
      write_port1(32'h0000_0010, 32'h11112222, 4'b1111);
      write_port2(32'h0000_0020, 32'h33334444, 4'b1111);
    join
    read_port1(32'h0000_0010, rdata);
    assert (rdata == 32'h11112222) else $fatal(1,"failed 4");

    read_port2(32'h0000_0020, rdata);
    assert (rdata == 32'h33334444) else $fatal(1,"failed 5");

    //write same address differen bytes
    write_port1(32'h0000_0030, 32'hFFFFFFFF, 4'b0011);
    write_port2(32'h0000_0030, 32'hAAAA0000, 4'b1100);
    read_port1(32'h0000_0030, rdata);
    assert (rdata == 32'hAAAAFFFF) else $fatal(1,"failed 6");

    $finish;
  end

  //dump waves
  initial begin
    $dumpfile("dualportram_tb.vcd");
    $dumpvars(0, dualportram_tb);
  end

  dualportram #(
    .RAM_SIZE(RAM_SIZE)
  ) dut (
    .clk_i(clk),
    .rst_n_i(rst_n),
    .req1_i(req1_i),
    .we1_i(we1_i),
    .be1_i(be1_i),
    .addr1_i(addr1_i),
    .wdata1_i(wdata1_i),
    .rvalid1_o(rvalid1_o),
    .rdata1_o(rdata1_o),
    .req2_i(req2_i),
    .we2_i(we2_i),
    .be2_i(be2_i),
    .addr2_i(addr2_i),
    .wdata2_i(wdata2_i),
    .rvalid2_o(rvalid2_o),
    .rdata2_o(rdata2_o)
  );
  

endmodule
