module tb_fsm_8bit_shift; 
  logic clk = 0; 
  always #5 clk = ~clk; 
   
  logic reset = 1; 
  logic [7:0] data_in1 = '0; 
  logic [7:0] data_in2 = '0; 
  logic [15:0] data_out; 
   
  covergroup cg_fsm @(posedge clk); 
    state_cp: coverpoint tb_fsm_8bit_shift.uut.state { 
      bins idle    = {2'b00}; 
      bins shift   = {2'b01}; 
      bins combine = {2'b10}; 
      illegal_bins invalid = {2'b11}; 
    } 
    data_in1_cp: coverpoint data_in1 { 
      bins zero     = {0}; 
      bins low      = {[1:85]}; 
      bins mid      = {[86:170]}; 
      bins high     = {[171:255]}; 
      bins edges[]  = {8'h00, 8'hFF}; 
    } 
    data_in2_cp: coverpoint data_in2 { 
      bins zero     = {0}; 
      bins low      = {[1:85]}; 
      bins mid      = {[86:170]}; 
      bins high     = {[171:255]}; 
    } 
    data_out_cp: coverpoint data_out { 
      bins zero     = {0}; 
      bins shifted  = {[1:1020]};  
      bins combined = {[256:65535]}; 
    } 
     
    state_data1_cross: cross state_cp, data_in1_cp; 
    state_data2_cross: cross state_cp, data_in2_cp; 
  endgroup 
   
  cg_fsm cg_obj; 
   
  fsm_8bit_shift uut ( 
    .clk(clk), 
    .reset(reset), 
    .data_in1(data_in1), 
    .data_in2(data_in2), 
    .data_out(data_out) 
  ); 
   
  initial begin 
    cg_obj = new(); 
     
    #15; 
    reset = 0; 
     
    $display("=== Basic ==="); 
    data_in1 = 8'h01; 
    data_in2 = 8'h02; 
    #60; 
     
    $display("=== Shift ==="); 
    data_in1 = 8'h0F;  // Должен стать 0x3C  
    data_in2 = 8'h55; 
    #60; 
     
    $display("=== Combine ==="); 
    data_in1 = 8'hAA; 
    data_in2 = 8'h55;  // Должен стать 0xAA55 
    #60; 
     
    $finish; 
  end 
   
  sequence state_transition_seq; 
    (uut.state == uut.IDLE) ##1  
    (uut.state == uut.SHIFT) ##1  
    (uut.state == uut.COMBINE) ##1  
    (uut.state == uut.IDLE); 
  endsequence 
   
  property valid_state_transitions; 
    @(posedge clk) disable iff (reset) 
    (uut.state == uut.IDLE) |-> state_transition_seq; 
  endproperty 
   
  property shift_output_correct; 
    @(posedge clk) disable iff (reset) 
    (uut.state == uut.SHIFT) |-> (data_out == (data_in1 << 2)); 
  endproperty 
   
  property combine_output_correct; 
    @(posedge clk) disable iff (reset) 
    (uut.state == uut.COMBINE) |-> (data_out == {data_in1, data_in2}); 
  endproperty 
 
  assert_state_transition: assert property (valid_state_transitions) 
    $display("[%t] PASS: Valid state transition sequence", $time); 
  else 
    $error("[%t] FAIL: Invalid state transition. Current state: %b",  
           $time, uut.state); 
   
 
  assert_shift_output: assert property (shift_output_correct) 
  else 
    $error("[%t] FAIL: SHIFT output incorrect. in1=%h, out=%h, expected=%h",  
           $time, data_in1, data_out, (data_in1 << 2)); 
   
 
  assert_combine_output: assert property (combine_output_correct) 
  else 
    $error("[%t] FAIL: COMBINE output incorrect. in1=%h, in2=%h, out=%h, expected=%h",  
           $time, data_in1, data_in2, data_out, {data_in1, data_in2}); 
   
  
   
  always @(posedge clk) begin 
    if (!reset) begin 
      case (uut.state) 
        uut.IDLE:  
          $strobe("[%t] State: IDLE, out=%h", $time, data_out); 
        uut.SHIFT:  
          $strobe("[%t] State: SHIFT, in1=%h, out=%h (in1<<2=%h)",  
                 $time, data_in1, data_out, (data_in1 << 2)); 
        uut.COMBINE:  
          $strobe("[%t] State: COMBINE, in1=%h, in2=%h, out=%h ({in1,in2}=%h)",  
                 $time, data_in1, data_in2, data_out, {data_in1, data_in2}); 
      endcase 
    end 
  end 
   
 
endmodule
