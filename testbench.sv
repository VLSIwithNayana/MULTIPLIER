
`timescale 1ns/1ns

import uvm_pkg::* ;
`include "uvm_macros.svh"
///////////////////////////////

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  
  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [7:0] y;
  
  function new (input string path = "transaction");
    super.new (path);
  endfunction
  
endclass

//////////////////////////////////////

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils (generator)
  transaction tr;
  
  function new( input string path ="generator");
    super.new(path);
  endfunction
  
  virtual task body ();
    repeat (15)
      begin 
        tr = transaction :: type_id::create("tr");
        start_item(tr);
        assert (tr.randomize());
        `uvm_info ("SEQ", $sformatf("a: %0d , b: %0d ,y: %0d", tr.a,tr.b,tr.y),UVM_NONE);
        finish_item(tr);
      end
  endtask
  
endclass


//////////////////////////////////////////////

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  transaction tr;
  virtual mul_if mif;
  
  function new (input string path = "drv", uvm_component parent = null);
    super.new (path,parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual mul_if):: get (this,"","mif",mif) )
      `uvm_error("drv","unable to access interface");
  endfunction

  virtual task run_phase (uvm_phase phase);
    tr =transaction ::type_id::create("tr");
    forever begin
      seq_item_port.get_next_item(tr);
      mif.a <= tr.a;
      mif.b <= tr.b;
      `uvm_info ("drv",$sformatf("a: %0d ,b: %0d ,y: %0d",tr.a,tr.b,tr.y),UVM_NONE);
      seq_item_port.item_done();
      #20;
    end
  endtask
  
endclass

///////////////////////////////////////////////

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  uvm_analysis_port #(transaction) send;
  transaction tr;
  virtual mul_if mif;
  
  function new (input string path = "monitor", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send =new("send",this);
    if (!uvm_config_db #(virtual mul_if) :: get(this,"","mif",mif))
      `uvm_error("MON","unable to access interface through config_db");
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    forever begin
      #20;
      tr.a = mif.a;
      tr.b= mif.b;
      tr.y = mif.y;
      `uvm_info ("MON",$sformatf("a: %0d ,b: %0d ,y: %0d", tr.a,tr.b,tr.y),UVM_NONE);
      send.write(tr);
    end
  endtask
endclass
      

//////////////////////////////////////////////////////

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(transaction,scoreboard) recv;
  
  function new(input string path = "scoreboard" , uvm_component parent);
    super.new(path,parent);
  endfunction
  
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv",this);
  endfunction
  
  virtual function void write (transaction tr);
    if(tr.y == tr.a * tr.b)
      begin
      `uvm_info("sco", $sformatf("test passed => a: %0d ,b: %0d ,y: %0d ",tr.a,tr.b,tr.y),UVM_NONE)
        end
    else
      begin
      `uvm_error("SCO",$sformatf("TEST FAILED => a: %0d ,b: %0d ,y: %0d",tr.a,tr.b,tr.y));
      end
      $display("----------------------------------------------");
  endfunction
endclass


/////////////////////////////////////////////////////////////

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  function new(input string path = "agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  driver drv;
  uvm_sequencer #(transaction) seqr;
  monitor mon;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver ::type_id::create ("drv",this);
    seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
    mon =monitor ::type_id::create("mon",this);
  endfunction
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase (phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass


//////////////////////////////////////////////////////////
    
class env extends uvm_env;
  `uvm_component_utils(env)
  
  function new(input string path = "env", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  agent a;
  scoreboard sco;
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    a= agent::type_id::create("a",this);
    sco = scoreboard ::type_id::create("sco",this);
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    a.mon.send.connect(sco.recv);
  endfunction
  
endclass


//////////////////////////////////////////////////////

class test extends uvm_test;
  `uvm_component_utils(test);
  
  function new(input string path = "test", uvm_component parent =null);
    super.new(path, parent);
  endfunction
  
  env e;
  generator gen;
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    gen = generator :: type_id::create("gen");
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
  endtask
  
endclass

/////////////////////////////////////////////////////////

module tb;
  mul_if mif();
  mul dut_mul (.a(mif.a), .b(mif.b), .y(mif.y));
  
  initial begin
    uvm_config_db #(virtual mul_if) :: set (null, "*","mif",mif) ;
    
    run_test("test");
    
  end
endmodule


    


  
  




