`define DEPTH_FIFO 8

//Data that is popped out is sent as a packet to the arbiter along with REQ signal which specifies that the transaction needs to be serviced by the arbiter
typedef struct {
  logic [31:0] wdata;
  logic [31:0] addr;
  logic write;
} packet_out;


module apb_slave_fifo(
  //From APB Slave
  input logic clk,
  input logic reset,
  input logic push_in,
  input logic [31:0] push_wdata_in;
  input logic [31:0] push_addr_in;
  input logic write,
  
  //To APB Slave
  output logic data_in_ack,
  output logic full_o,
  
  //From Arbiter
  input logic pop_in; //GRANT from the Arbiter drives this
  
  //To Arbiter
  output packet_out fifo_packet_out;
  output logic arb_req
  /When the data is popped out, that means it is the transaction request   to be sent to the abiter. The data is popped out only when the arbiter  completes the previous transactions right/
);
  
  //To arbiter
  logic [31:0] pop_wdata_out;
  logic [31:0] pop_addr_out;
  logic arb_write;
  logic fifo_empty;

  //Output Assignments
  assign arb_write = write;
  assign data_in_ack = push_in && !full_o;
  assign fifo_packet_out = '{wdata : pop_wdata_out,
                             addr  : pop_addr_out,
                             write : arb_write
                            };
  
  assign arb_req = ~fifo_empty; // Only request when data is there
  
  typedef enum logic [1:0] {
    PUSH=2'b01,
    POP=2'b10,
    BOTH=2'b11 } fifo_state;
  
  localparam PTR_W = $clog2(`DEPTH_FIFO); //Pointers width in bits
  
  logic [31:0] fifo_wdata_regs [7:0]; //To store write data
  logic [31:0] fifo_addr_regs [7:0]; //To store address
  
  logic [PTR_W-1:0] rd_ptr_w,rd_ptr_a;//Read pointers
  logic [PTR_W-1:0] wr_ptr_w,wr_ptr_a;//Write pointers
  
  logic [PTR_W-1:0] nxt_rd_ptr_w,nxt_rd_ptr_a;//Next Read pointers
  logic [PTR_W-1:0] nxt_wr_ptr_w,nxt_wr_ptr_a;//Next Write pointers
  
  logic [31:0] nxt_fifo_wdata_in;
  logic [31:0] nxt_fifo_addr_in;
  
  //FIFO Pointers
  always_ff@(posedge clk or negedge reset)
    begin
      if(!reset)
        begin //All the pointers are at the bottom of the FIFO buffers
          rd_ptr_w <= PTR_W'(1'b0);
          rd_ptr_a <= PTR_W'(1'b0);
          wr_ptr_w <= PTR_W'(1'b0);
          wr_ptr_a <= PTR_W'(1'b0);
        end
      else
        begin
          rd_ptr_w <= nxt_rd_ptr_w;
          rd_ptr_a <= nxt_rd_ptr_a;
          wr_ptr_w <= nxt_wr_ptr_w;
          wr_ptr_a <= nxt_wr_ptr_a;
        end
    end
  
  //Handle Full condition of FIFO
  always_comb
    begin
      if(write)
        full_o = (nxt_wr_ptr_w == rd_ptr_w | nxt_wr_ptr_a == rd_ptr_a) ? 1 : 0;
      else
        full_o = (nxt_wr_ptr_a == rd_ptr_a) ? 1 : 0;
    end
  
  //Handle Empty condition of FIFO
  always_comb
    begin
      fifo_empty = (wr_ptr_a == rd_ptr_a && wr_ptr_w == rd_ptr_w) ? 1 : 0;
    end
  
  //Pointer logic for push and pop
  always_comb 
    begin //To avoid latches
      nxt_fifo_wdata_in = fifo_wdata_regs[wr_ptr_w];
      nxt_fifo_addr_in = fifo_addr_regs[wr_ptr_a];
      nxt_wr_ptr_w = wr_ptr_w;
      nxt_wr_ptr_a = wr_ptr_a;
      nxt_rd_ptr_w = rd_ptr_w;
      nxt_rd_ptr_a = rd_ptr_a;
      pop_wdata_out = 32'b0;
      pop_addr_out = 32'b0;
      case({pop_in,push_in}) //2-bit signal with PUSH as LSB and POP as MSB
        PUSH: 
          begin
            if(write) //WRITE
              begin
                nxt_fifo_wdata_in = push_wdata_in;
                nxt_fifo_addr_in = push_addr_in;
                //Manipulate the write pointer of FIFO
                //WDATA
                if(wr_ptr_w == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_w = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_w = wr_ptr_w + 1'b1;
                //ADDR
                if(wr_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_a = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_a = wr_ptr_a + 1'b1;
              end
            else //READ
              begin
                nxt_fifo_addr_in = push_addr_in;
                //Manipulate the write pointer of FIFO
                if(wr_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_a = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_a = wr_ptr_a + 1'b1;
              end
          end
        POP:
          begin
            //WRITE
            if(write)
              begin
                pop_wdata_out = fifo_wdata_regs[rd_ptr_w];
                pop_addr_out = fifo_addr_regs[rd_ptr_a];
                //Manipulate the write pointer of FIFO
                //WDATA
                if(rd_ptr_w == PTR_W'(`DEPTH_FIFO-1))
                  nxt_rd_ptr_w = PTR_W'(1'b0);
                else
                  nxt_rd_ptr_w = rd_ptr_w + 1'b1;
                //ADDR
                if(rd_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_rd_ptr_a = PTR_W'(1'b0);
                else
                  nxt_rd_ptr_a = rd_ptr_a + 1'b1;
              end
            else //READ
              pop_addr_out = fifo_addr_regs[rd_ptr_a];
              //Manipulate the write pointer of FIFO
              if(rd_ptr_a == PTR_W'(`DEPTH_FIFO-1))
              	nxt_rd_ptr_a = PTR_W'(1'b0);
              else
              	nxt_rd_ptr_a = rd_ptr_a + 1'b1;
          end
        BOTH:
          begin
            if(write) //WRITE
              begin
                
                /PUSH/
                nxt_fifo_wdata_in = push_wdata_in;
                nxt_fifo_addr_in = push_addr_in;
                //Manipulate the write pointer of FIFO
                //WDATA
                if(wr_ptr_w == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_w = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_w = wr_ptr_w + 1'b1;
                //ADDR
                if(wr_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_a = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_a = wr_ptr_a + 1'b1;
                
                /POP/
                pop_wdata_out = fifo_wdata_regs[rd_ptr_w];
                pop_addr_out = fifo_addr_regs[rd_ptr_a];
                //Manipulate the write pointer of FIFO
                //WDATA
                if(rd_ptr_w == PTR_W'(`DEPTH_FIFO-1))
                  nxt_rd_ptr_w = PTR_W'(1'b0);
                else
                  nxt_rd_ptr_w = rd_ptr_w + 1'b1;
                //ADDR
                if(rd_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_rd_ptr_a = PTR_W'(1'b0);
                else
                  nxt_rd_ptr_a = rd_ptr_a + 1'b1;
              end
            
            else //READ
              begin
                
                /PUSH/
                nxt_fifo_addr_in = push_addr_in;
                //Manipulate the write pointer of FIFO
                if(wr_ptr_a == PTR_W'(`DEPTH_FIFO-1))
                  nxt_wr_ptr_a = PTR_W'(1'b0);
                else
                  nxt_wr_ptr_a = wr_ptr_a + 1'b1;
                
                /POP/
                pop_addr_out = fifo_addr_regs[rd_ptr_a];
              	//Manipulate the write pointer of FIFO
             	if(rd_ptr_a == PTR_W'(`DEPTH_FIFO-1))
              		nxt_rd_ptr_a = PTR_W'(1'b0);
              	else
              		nxt_rd_ptr_a = rd_ptr_a + 1'b1;
              end
          end
        default: //FIFO would remain in the same state as it was earlier
          begin
                nxt_fifo_wdata_in = fifo_wdata_regs[wr_ptr_w];
                nxt_fifo_addr_in = fifo_addr_regs[wr_ptr_a];
                nxt_wr_ptr_w = wr_ptr_w;
                nxt_wr_ptr_a = wr_ptr_a;
                nxt_rd_ptr_w = rd_ptr_w;
                nxt_rd_ptr_a = rd_ptr_a;
          end
      endcase
  
    end
  
  //For FIFO Data
  always_ff@(posedge clk)
    begin
      //PUSH
      if (write) //WRITE
        begin
          fifo_wdata_regs[wr_ptr_w] <= nxt_fifo_wdata_in;
          fifo_addr_regs[wr_ptr_a] <= nxt_fifo_addr_in;
        end
      else //READ
        fifo_addr_regs[wr_ptr_a] <= nxt_fifo_addr_in;
    end
  
endmodule
