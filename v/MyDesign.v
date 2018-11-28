//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// DUT




module MyDesign #(parameter OUTPUT_LENGTH       = 8,
                  parameter MAX_MESSAGE_LENGTH  = 55,
                  parameter NUMBER_OF_Ks        = 64,
                  parameter NUMBER_OF_Hs        = 8 ,
                  parameter SYMBOL_WIDTH        = 8  )
            (

            //---------------------------------------------------------------------------
            // Control
            //
            output reg                                   dut__xxx__finish     ,
            input  wire                                  xxx__dut__go         ,  
            input  wire  [ $clog2(MAX_MESSAGE_LENGTH):0] xxx__dut__msg_length ,

            //---------------------------------------------------------------------------
            // Message memory interface
            //
            output reg  [ $clog2(MAX_MESSAGE_LENGTH)-1:0]   dut__msg__address  ,  // address of letter
            output reg                                      dut__msg__enable   ,
            output reg                                      dut__msg__write    ,
            input  wire [7:0]                               msg__dut__data     ,  // read each letter
            
            //---------------------------------------------------------------------------
            // K memory interface
            //
            output reg  [ $clog2(NUMBER_OF_Ks)-1:0]     dut__kmem__address  ,
            output reg                                  dut__kmem__enable   ,
            output reg                                  dut__kmem__write    ,
            input  wire [31:0]                          kmem__dut__data     ,  // read data

            //---------------------------------------------------------------------------
            // H memory interface
            //
            output reg  [ $clog2(NUMBER_OF_Hs)-1:0]     dut__hmem__address  ,
            output reg                                  dut__hmem__enable   ,
            output reg                                  dut__hmem__write    ,
            input  wire [31:0]                          hmem__dut__data     ,  // read data


            //---------------------------------------------------------------------------
            // Output data memory 
            //
            output reg  [ $clog2(OUTPUT_LENGTH)-1:0]    dut__dom__address  ,
            output reg  [31:0]                          dut__dom__data     ,  // write data
            output reg                                  dut__dom__enable   ,
            output reg                                  dut__dom__write    ,


            //-------------------------------
            // General
            //
            input  wire                 clk             ,
            input  wire                 reset  

            );

  //---------------------------------------------------------------------------
  //
  //<<<<----  YOUR CODE HERE    ---->>>>

 // `include "v564.vh"
reg rst,go,finish;
reg [ $clog2(MAX_MESSAGE_LENGTH):0] dut_msg_length;
reg msg_enable, k_enable, h_enable, out_enable;
reg msg_write, k_write, h_write, out_write;
reg [31:0] w[0:15];
reg [31:0] k;
reg [31:0] h[0:7];
reg [31:0] a_reg,b_reg,c_reg,d_reg,e_reg,f_reg,g_reg,h_reg;
reg [31:0] T1,T2;
reg [511:0] msg;
reg [$clog2(MAX_MESSAGE_LENGTH)-1:0] address;
reg [$clog2(MAX_MESSAGE_LENGTH):0]length_count;
reg [$clog2(NUMBER_OF_Ks)-1:0] k_address;
reg [$clog2(NUMBER_OF_Hs)-1:0] h_address;
reg [$clog2(NUMBER_OF_Ks)-1:0] k_length;
reg [$clog2(NUMBER_OF_Hs)-1:0] h_length;
reg [7:0] i;
reg [7:0] j;
reg [7:0] n;
reg [7:0] m;
reg msg_first;
reg k_first;
reg h_first;
reg comp_first;
reg out_first;
reg start,start_w,start_k;
reg [7:0] iteration;
reg done;
reg done1;
reg [4:0] output_length_count;
reg [2:0] output_address;
reg control_for_go;
reg compute_k;
reg [31:0] w_val;
reg [7:0] msg_in;

// Registering inputs
always @(posedge clk)
begin
	rst <= reset;
	go <= xxx__dut__go;
	dut_msg_length <= xxx__dut__msg_length;
end

// Registering outputs
always @(posedge clk)
begin
	dut__msg__enable <= msg_enable;
	dut__msg__write <= msg_write;
	dut__kmem__enable <= k_enable;
	dut__kmem__write <= k_write;
	dut__hmem__enable <= h_enable;
	dut__hmem__write <= h_write;
	dut__dom__enable <= out_enable;
	dut__dom__write <= out_write;
	dut__xxx__finish <= finish;
end

// Controlling Control_for_go signal which is used for neglecting intermediate go signals
always@(posedge clk)
begin
if(rst)
	begin 
	control_for_go <= 1'b0;
	end
else if(go)
	begin 
	control_for_go <= 1'b1;
	end
else if(finish)
	begin 
	control_for_go <= 1'b0;
	end
end

// Control lines for input message
always@(posedge clk)
begin
if(rst)
	begin 
	msg_enable <= 1'b0; 
	msg_write  <= 1'b0;
	end
else if((go) && (control_for_go !=1))
	begin
	msg_enable <= 1'b1;
	msg_write  <= 1'b0;
	end
else if(length_count > dut_msg_length)
	begin
	msg_enable <= 1'b0;
	msg_write  <= 1'b0;
	end
end

always@(posedge clk) 
begin
if(rst)
	begin 
        dut__msg__address <= 8'b0;
        address <= 8'b0;
        length_count <= 7'b0;
	end
else if(go && (control_for_go !=1))
	begin
	dut__msg__address <= 8'b0;
	address <= 8'b0;
	length_count <= 7'b0;
	end
else if(msg_enable)
	begin
       	if(msg_first)
		begin
		dut__msg__address <= 8'b0;
		address <= 8'b0;
		length_count <= 7'b0;
		end
	else
		begin
        	dut__msg__address <= address;
        	address <= add5(address,1'b1,1'b0,1'b0,1'b0);
        	length_count <= add5(length_count,1'b1,1'b0,1'b0,1'b0);
		end
	end
else if(msg_enable == 0)
	begin
        dut__msg__address <= 8'b0;
	address <= 8'b0;
	length_count <= 7'b0;
	end
end

always @(posedge clk)
begin
	msg_in <= msg__dut__data;
end

//Getting the input message
always@(posedge clk)
begin
if(rst)
	begin 
	msg <= 512'b0;
	i <= 8'b0;
	msg_first <= 1'b1;
	end
else if(go && (control_for_go !=1))
	begin
	msg <= 512'b0;
	i <= 8'b0;
	msg_first <= 1'b1;
	end
else if(msg_enable)
	begin
	if(msg_first)
		begin
		msg <= 512'b0;
		i <= 8'b0;
		msg_first <= 1'b0;
		end
	else
		begin
		if(msg_in > 0)
			begin
			msg[(511 - i*8)] <= msg_in[7]; 
			msg[(510 - i*8)] <= msg_in[6];
			msg[(509 - i*8)] <= msg_in[5]; 
			msg[(508 - i*8)] <= msg_in[4];  
			msg[(507 - i*8)] <= msg_in[3]; 
			msg[(506 - i*8)] <= msg_in[2]; 
			msg[(505 - i*8)] <= msg_in[1]; 
			msg[(504 - i*8)] <= msg_in[0]; 
			i <= add5(i,1'b1,1'b0,1'b0,1'b0);
			end
		end
	end
else if (length_count >  dut_msg_length)
	begin
	msg <= msg<<8;
        msg[511-(dut_msg_length*8)] <= 1'b1;
        msg[63:0] <= dut_msg_length*8;
	end
end 

// Generating first 15 values of W array
integer gv1;
always @(posedge clk) 
begin
if(rst)
	begin
	gv1 <= 'd16;
	w[0] <= 32'b0;
	w[1] <= 32'b0;
	w[2] <= 32'b0;
	w[3] <= 32'b0;
	w[4] <= 32'b0;
	w[5] <= 32'b0;
	w[6] <= 32'b0;
	w[7] <= 32'b0;
	w[8] <= 32'b0;
	w[9] <= 32'b0;
	w[10] <= 32'b0;
	w[11] <= 32'b0;
	w[12] <= 32'b0;
	w[13] <= 32'b0;
	w[14] <= 32'b0;
	w[15] <= 32'b0;
	end
else if (go && (control_for_go !=1))
	begin
	gv1 <= 'd16;
	w[0] <= 32'b0;
	w[1] <= 32'b0;
	w[2] <= 32'b0;
	w[3] <= 32'b0;
	w[4] <= 32'b0;
	w[5] <= 32'b0;
	w[6] <= 32'b0;
	w[7] <= 32'b0;
	w[8] <= 32'b0;
	w[9] <= 32'b0;
	w[10] <= 32'b0;
	w[11] <= 32'b0;
	w[12] <= 32'b0;
	w[13] <= 32'b0;
	w[14] <= 32'b0;
	w[15] <= 32'b0;
	end
else if(finish)
	begin
	gv1 <= 'd16;
	w[0] <= 32'b0;
	w[1] <= 32'b0;
	w[2] <= 32'b0;
	w[3] <= 32'b0;
	w[4] <= 32'b0;
	w[5] <= 32'b0;
	w[6] <= 32'b0;
	w[7] <= 32'b0;
	w[8] <= 32'b0;
	w[9] <= 32'b0;
	w[10] <= 32'b0;
	w[11] <= 32'b0;
	w[12] <= 32'b0;
	w[13] <= 32'b0;
	w[14] <= 32'b0;
	w[15] <= 32'b0;
	end
else if(start_w == 1'b0)
	begin
	w[0] <= msg[511:480];
	w[1] <= msg[479:448];
	w[2] <= msg[447:416];
	w[3] <= msg[415:384];
	w[4] <= msg[383:352];
	w[5] <= msg[351:320];
	w[6] <= msg[319:288];
	w[7] <= msg[287:256];
	w[8] <= msg[255:224];
	w[9] <= msg[223:192];
	w[10] <= msg[191:160];
	w[11] <= msg[159:128];
	w[12] <= msg[127:96];
	w[13] <= msg[95:64];
	w[14] <= msg[63:32];
	w[15] <= msg[31:0];
	end
else if(start_w)
	begin
	if(iteration == 'd15 || iteration == 'd31 || iteration == 'd47)
		w[0] <= add5(sigma1(w[14]),w[9],sigma0(w[1]),w[0],1'b0);
	else if(iteration == 'd16 || iteration == 'd32 || iteration == 'd48)
		w[1] <= add5(sigma1(w[15]),w[10],sigma0(w[2]),w[1],1'b0);
	else if(iteration == 'd17 || iteration == 'd33 || iteration == 'd49)
		w[2] <= add5(sigma1(w[0]),w[11],sigma0(w[3]),w[2],1'b0);
	else if(iteration == 'd18 || iteration == 'd34 || iteration == 'd50)
		w[3] <= add5(sigma1(w[1]),w[12],sigma0(w[4]),w[3],1'b0);
	else if(iteration == 'd19 || iteration == 'd35 || iteration == 'd51)
		w[4] <= add5(sigma1(w[2]),w[13],sigma0(w[5]),w[4],1'b0);
	else if(iteration == 'd20 || iteration == 'd36 || iteration == 'd52)
		w[5] <= add5(sigma1(w[3]),w[14],sigma0(w[6]),w[5],1'b0);
	else if(iteration == 'd21 || iteration == 'd37 || iteration == 'd53)
		w[6] <= add5(sigma1(w[4]),w[15],sigma0(w[7]),w[6],1'b0);
	else if(iteration == 'd22 || iteration == 'd38 || iteration == 'd54)
		w[7] <= add5(sigma1(w[5]),w[0],sigma0(w[8]),w[7],1'b0);
	else if(iteration == 'd23 || iteration == 'd39 || iteration == 'd55)
		w[8] <= add5(sigma1(w[6]),w[1],sigma0(w[9]),w[8],1'b0);
	else if(iteration == 'd24 || iteration == 'd40 || iteration == 'd56)
		w[9] <= add5(sigma1(w[7]),w[2],sigma0(w[10]),w[9],1'b0);
	else if(iteration == 'd25 || iteration == 'd41 || iteration == 'd57)
		w[10] <= add5(sigma1(w[8]),w[3],sigma0(w[11]),w[10],1'b0);
	else if(iteration == 'd26 || iteration == 'd42 || iteration == 'd58)
		w[11] <= add5(sigma1(w[9]),w[4],sigma0(w[12]),w[11],1'b0);
	else if(iteration == 'd27 || iteration == 'd43 || iteration == 'd59)
		w[12] <= add5(sigma1(w[10]),w[5],sigma0(w[13]),w[12],1'b0);
	else if(iteration == 'd28 || iteration == 'd44 || iteration == 'd60)
		w[13] <= add5(sigma1(w[11]),w[6],sigma0(w[14]),w[13],1'b0);
	else if(iteration == 'd29 || iteration == 'd45 || iteration == 'd61)
		w[14] <= add5(sigma1(w[12]),w[7],sigma0(w[15]),w[14],1'b0);
	else if(iteration == 'd30 || iteration == 'd46 || iteration == 'd62)
		w[15] <= add5(sigma1(w[13]),w[8],sigma0(w[0]),w[15],1'b0);
//	end
       	end
end


always @(posedge clk)
begin
if(rst)
	begin
	start_w <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	start_w <= 1'b0;
	end
else if((start && start_w && start_k) && (iteration >= 8'd63))
	begin
	start_w <= 1'b0;
	end
else if(finish)
	begin
	start_w <= 1'b0;
	end
else
	begin
	if(w[15] != 32'b0)
		begin
		start_w <= 1'b1;
		end
	else
		begin
		start_w <= 1'b0;
		end
	end
end

//Control lines for K array
always@(posedge clk)
begin
if(rst)
	begin 
	k_enable <= 1'b0; 
	k_write  <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	k_enable <= 1'b1;
	k_write  <= 1'b0;
	end
else if((k_enable == 0)&&(2**k_length) > NUMBER_OF_Ks)
	begin
	k_enable <= 1'b0;
	k_write  <= 1'b0;
	end
end

always@(posedge clk) 
begin
if(rst)
	begin 
        dut__kmem__address <= 8'b0;
        k_address <= 8'b0;
        k_length <= 6'b0;
	compute_k <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	dut__kmem__address <= 8'b0;
	k_address <= 8'b0;
	k_length <= 6'b0;
	compute_k <= 1'b0;
	end
else if(k_enable)
	begin
	if(start && start_w)
		begin
        	dut__kmem__address <= k_address;
        	k_address <= add5(k_address,1'b1,1'b0,1'b0,1'b0);
        	k_length <= add5(k_length,1'b1,1'b0,1'b0,1'b0);
		compute_k <= 1'b1;
		end
	end
else if(k_enable == 0)
	begin
        dut__kmem__address <= 8'b0;
	k_address <= 8'b0;
	k_length <= 6'b0;
	compute_k <= 1'b0;
	end
end

// Loading K values
always@(posedge clk)
begin
if(start && compute_k)
	begin
	k <= kmem__dut__data;
	start_k <= 1'b1;
	end
else if(dut__kmem__address == 0)
	begin
	k <= 32'b0;
	start_k <= 1'b0;
	end
end


//Control lines for H array
always@(posedge clk)
begin
if(rst)
	begin 
	h_enable <= 1'b0; 
	h_write  <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	h_enable <= 1'b1;
	h_write  <= 1'b0;
	end
else if((h_enable == 0)&&(2**h_length) > NUMBER_OF_Hs)
	begin
	h_enable <= 1'b0;
	h_write  <= 1'b0;
	end
end

always@(posedge clk) 
begin
if(rst)
	begin 
        dut__hmem__address <= 8'b0;
        h_address <= 8'b0;
        h_length <= 3'b0;
	end
else if(go && (control_for_go !=1))
	begin
	dut__hmem__address <= 8'b0;
	h_address <= 8'b0;
	h_length <= 3'b0;
	end
else if(h_enable)
	begin
        dut__hmem__address <= h_address;
        h_address <= add5(h_address,1'b1,1'b0,1'b0,1'b0);
        h_length <= add5(h_length,1'b1,1'b0,1'b0,1'b0);
	end
else if(h_enable == 0)
	begin
        dut__hmem__address <= 8'b0;
	h_address <= 8'b0;
	h_length <= 3'b0;
	end
end

// Loading H values
always@(posedge clk)
begin
if(rst)
	begin 
	n <= 8'b0;
	h[n] <= 32'b0;
	h_first <= 1'b1;
	done1 <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	n <= 8'b0;
	h[n] <= 32'b0;
	h_first <= 1'b1;
	done1 <= 1'b0;
	end
else if(done && ~done1)
	begin
	h[0] <= add5(h[0],a_reg,1'b0,1'b0,1'b0);
	h[1] <= add5(h[1],b_reg,1'b0,1'b0,1'b0);
	h[2] <= add5(h[2],c_reg,1'b0,1'b0,1'b0);
	h[3] <= add5(h[3],d_reg,1'b0,1'b0,1'b0);
	h[4] <= add5(h[4],e_reg,1'b0,1'b0,1'b0);
	h[5] <= add5(h[5],f_reg,1'b0,1'b0,1'b0);
	h[6] <= add5(h[6],g_reg,1'b0,1'b0,1'b0);
	h[7] <= add5(h[7],h_reg,1'b0,1'b0,1'b0);
	done1 <= 1'b1;
	end
else if(finish)
	begin
	h[0] <= 32'b0;
	h[1] <= 32'b0;
	h[2] <= 32'b0;
	h[3] <= 32'b0;
	h[4] <= 32'b0;
	h[5] <= 32'b0;
	h[6] <= 32'b0;
	h[7] <= 32'b0;
	end
else if(h_enable)
	begin
	if (h_first)
		begin
		h[n] <= 32'b0;
		h_first <= 1'b0;
		end
	else
		begin
		h[n] <= hmem__dut__data;
		n <= add5(n,1'b1,1'b0,1'b0,1'b0);
		end
	end
end

always @(posedge clk)
begin
if(iteration == 'd0)
	begin
	w_val <= w[0];
	end
else if(iteration == 'd1)
	begin
	w_val <= w[1];
	end
else if(iteration == 'd2)
	begin
	w_val <= w[2];
	end
else if(iteration == 'd3)
	begin
	w_val <= w[3];
	end
else if(iteration == 'd4)
	begin
	w_val <= w[4];
	end
else if(iteration == 'd5)
	begin
	w_val <= w[5];
	end
else if(iteration == 'd6)
	begin
	w_val <= w[6];
	end
else if(iteration == 'd7)
	begin
	w_val <= w[7];
	end
else if(iteration == 'd8)
	begin
	w_val <= w[8];
	end
else if(iteration == 'd9)
	begin
	w_val <= w[9];
	end
else if(iteration == 'd10)
	begin
	w_val <= w[10];
	end
else if(iteration == 'd11)
	begin
	w_val <= w[11];
	end
else if(iteration == 'd12)
	begin
	w_val <= w[12];
	end
else if(iteration == 'd13)
	begin
	w_val <= w[13];
	end
else if(iteration == 'd14)
	begin
	w_val <= w[14];
	end
else if(iteration == 'd15)
	begin
	w_val <= w[15];
	end
else if(iteration == 'd16)
	begin
	w_val <= w[0];
	end
else if(iteration == 'd17)
	begin
	w_val <= w[1];
	end
else if(iteration == 'd18)
	begin
	w_val <= w[2];
	end
else if(iteration == 'd19)
	begin
	w_val <= w[3];
	end
else if(iteration == 'd20)
	begin
	w_val <= w[4];
	end
else if(iteration == 'd21)
	begin
	w_val <= w[5];
	end
else if(iteration == 'd22)
	begin
	w_val <= w[6];
	end
else if(iteration == 'd23)
	begin
	w_val <= w[7];
	end
else if(iteration == 'd24)
	begin
	w_val <= w[8];
	end
else if(iteration == 'd25)
	begin
	w_val <= w[9];
	end
else if(iteration == 'd26)
	begin
	w_val <= w[10];
	end
else if(iteration == 'd27)
	begin
	w_val <= w[11];
	end
else if(iteration == 'd28)
	begin
	w_val <= w[12];
	end
else if(iteration == 'd29)
	begin
	w_val <= w[13];
	end
else if(iteration == 'd30)
	begin
	w_val <= w[14];
	end
else if(iteration == 'd31)
	begin
	w_val <= w[15];
	end
else if(iteration == 'd32)
	begin
	w_val <= w[0];
	end
else if(iteration == 'd33)
	begin
	w_val <= w[1];
	end
else if(iteration == 'd34)
	begin
	w_val <= w[2];
	end
else if(iteration == 'd35)
	begin
	w_val <= w[3];
	end
else if(iteration == 'd36)
	begin
	w_val <= w[4];
	end
else if(iteration == 'd37)
	begin
	w_val <= w[5];
	end
else if(iteration == 'd38)
	begin
	w_val <= w[6];
	end
else if(iteration == 'd39)
	begin
	w_val <= w[7];
	end
else if(iteration == 'd40)
	begin
	w_val <= w[8];
	end
else if(iteration == 'd41)
	begin
	w_val <= w[9];
	end
else if(iteration == 'd42)
	begin
	w_val <= w[10];
	end
else if(iteration == 'd43)
	begin
	w_val <= w[11];
	end
else if(iteration == 'd44)
	begin
	w_val <= w[12];
	end
else if(iteration == 'd45)
	begin
	w_val <= w[13];
	end
else if(iteration == 'd46)
	begin
	w_val <= w[14];
	end
else if(iteration == 'd47)
	begin
	w_val <= w[15];
	end
else if(iteration == 'd48)
	begin
	w_val <= w[0];
	end
else if(iteration == 'd49)
	begin
	w_val <= w[1];
	end
else if(iteration == 'd50)
	begin
	w_val <= w[2];
	end
else if(iteration == 'd51)
	begin
	w_val <= w[3];
	end
else if(iteration == 'd52)
	begin
	w_val <= w[4];
	end
else if(iteration == 'd53)
	begin
	w_val <= w[5];
	end
else if(iteration == 'd54)
	begin
	w_val <= w[6];
	end
else if(iteration == 'd55)
	begin
	w_val <= w[7];
	end
else if(iteration == 'd56)
	begin
	w_val <= w[8];
	end
else if(iteration == 'd57)
	begin
	w_val <= w[9];
	end
else if(iteration == 'd58)
	begin
	w_val <= w[10];
	end
else if(iteration == 'd59)
	begin
	w_val <= w[11];
	end
else if(iteration == 'd60)
	begin
	w_val <= w[12];
	end
else if(iteration == 'd61)
	begin
	w_val <= w[13];
	end
else if(iteration == 'd62)
	begin
	w_val <= w[14];
	end
else if(iteration == 'd63)
	begin
	w_val <= w[15];
	end
end


// Hashing a,b,c,d,e,f,g,h
always @(posedge clk)
begin
if(rst)
	begin
	comp_first <= 1'b1;
	start <= 1'b0;
	iteration <= 8'b0;
	done <= 1'b0;
	start <= 1'b0;
	a_reg = 32'b0;
	b_reg = 32'b0;
	c_reg = 32'b0;
	d_reg = 32'b0;
	e_reg = 32'b0;
	f_reg = 32'b0;
	g_reg = 32'b0;
	h_reg = 32'b0;
	T1 = 32'b0;
	T2 = 32'b0;
	end
else if(go && (control_for_go !=1))
	begin
	comp_first <= 1'b1;
	start <= 1'b0;
	iteration <= 8'b0;
	done <= 1'b0;
	start <= 1'b0;
	a_reg = 32'b0;
	b_reg = 32'b0;
	c_reg = 32'b0;
	d_reg = 32'b0;
	e_reg = 32'b0;
	f_reg = 32'b0;
	g_reg = 32'b0;
	h_reg = 32'b0;
	T1 = 32'b0;
	T2 = 32'b0;
	end
else if (comp_first)
	begin
	a_reg = h[0];
	b_reg = h[1];
	c_reg = h[2];
	d_reg = h[3];
	e_reg = h[4];
	f_reg = h[5];
	g_reg = h[6];
	h_reg = h[7];
	T1 = 32'b0;
	T2 = 32'b0;
	if(a_reg != 32'b0 && b_reg != 32'b0 && c_reg != 32'b0 && d_reg != 32'b0 && e_reg != 32'b0 && f_reg != 32'b0 && g_reg != 32'b0 && h_reg != 32'b0)
		begin
		start <= 1'b1;
		comp_first <= 1'b0;
		iteration <= 8'b0;
		done <= 1'b0;
		end
	end
else if(start && start_w && start_k)
	begin
	w_val = w[iteration%16];
	T1 = add5(h_reg,epsilon1(e_reg),Ch(e_reg,f_reg,g_reg),k,w_val);
	T2 = add5(epsilon0(a_reg),Maj(a_reg,b_reg,c_reg),1'b0,1'b0,1'b0);
	h_reg = g_reg;
	g_reg = f_reg;
	f_reg = e_reg;
	e_reg = add5(d_reg,T1,1'b0,1'b0,1'b0);
	d_reg = c_reg;
	c_reg = b_reg;
	b_reg = a_reg;
	a_reg = add5(T1,T2,1'b0,1'b0,1'b0);
	iteration <= add5(iteration,1'b1,1'b0,1'b0,1'b0);
	if(iteration != 8'd63)
		done <= 1'b0;
	else
		begin
		done <= 1'b1;
		start <= 1'b0;
		end
	end
else if(done1)
	begin
	done <= 1'b0;
	end
end

// Finishing the process
always@(posedge clk)
begin
if(rst)
	begin 
	out_enable <= 1'b0; 
	out_write  <= 1'b0;
	finish <= 1'b1;
	end
else if(go && (control_for_go !=1))
	begin 
	out_enable <= 1'b0; 
	out_write  <= 1'b0;
	finish <= 1'b0;
	end
else if(output_length_count >= 'd7)
	begin
	out_enable <= 1'b0;
	out_write  <= 1'b0;
	finish <= 1'b1;
	end
else if(done)
	begin
	out_enable <= 1'b1;
	out_write  <= 1'b1;
	finish <= 1'b0;
	end
end

always@(posedge clk) 
begin
if(rst)
	begin 
        dut__dom__address <= 3'b0;
        output_address <= 3'b0;
        output_length_count <= 4'b0;
	end
else if(go && (control_for_go !=1))
	begin
	dut__dom__address <= 3'b0;
	output_address <= 3'b0;
	output_length_count <= 4'b0;
	end
else if(out_enable && out_write)
	begin
	if (out_first)
		begin
		dut__dom__address <= 3'b0;
		output_address <= 3'b0;
		output_length_count <= 4'b0;
		end
	else
		begin
        	dut__dom__address <= output_address;
        	output_address <= add5(output_address,1'b1,1'b0,1'b0,1'b0);
        	output_length_count <= add5(output_length_count,1'b1,1'b0,1'b0,1'b0);
		end
	end
else if(out_enable == 0)
	begin
        dut__dom__address <= 3'b0;
	output_address <= 3'b0;
	output_length_count <= 4'b0;
	end
end

//Setting the output message
always@(posedge clk)
begin
if(rst)
	begin 
	dut__dom__data <= 32'b0;
	m <= 8'b0;
	out_first <= 1'b0;
	end
else if(go && (control_for_go !=1))
	begin
	dut__dom__data <= 32'b0;
	m <= 8'b0;
	out_first <= 1'b1;
	end
else if(out_enable && out_write)
	begin
	if (out_first)
		begin
		dut__dom__data <= 32'b0; 
		out_first <= 1'b0;
		m <= 8'b0;
		end
	else
		begin
		dut__dom__data <= h[m]; 
		m <= add5(m,1'b1,1'b0,1'b0,1'b0);
		end
	end
end 

// Function sigma1
function [31:0] sigma1;
	input [31:0] temp;
	reg [63:0] x1, x2;
	reg [31:0] x3;
	begin
		x1 = {temp,temp} >> 17;
		x2 = {temp,temp} >> 19;
		x3 = temp >> 10;
		sigma1 = ((x1 ^ x2) ^ x3);
	end
endfunction 

// Function sigma0
function [31:0] sigma0;
	input [31:0] temp;
	reg [63:0] x1, x2;
	reg [31:0] x3;
	begin
		x1 = {temp,temp} >> 7;
		x2 = {temp,temp} >> 18;
		x3 = temp >> 3;
		sigma0 = ((x1 ^ x2) ^ x3);
	end
endfunction 

// Function epsilon0
function [31:0] epsilon0;
	input [31:0] temp;
	reg [63:0] x1, x2, x3;
	begin
		x1 = {temp,temp} >> 2;
		x2 = {temp,temp} >> 13;
		x3 = {temp,temp} >> 22;
		epsilon0 = ((x1 ^ x2) ^ x3);
	end
endfunction 

// Function epsilon1
function [31:0] epsilon1;
	input [31:0] temp;
	reg [63:0] x1, x2, x3;
	begin
		x1 = {temp,temp} >> 6;
		x2 = {temp,temp} >> 11;
		x3 = {temp,temp} >> 25;
		epsilon1 = ((x1 ^ x2) ^ x3);
	end
endfunction 

// Function Ch
function [31:0] Ch;
	input [31:0] temp1,temp2,temp3;
	reg [31:0] x1, x2, x3;
	begin
		x1 = temp1 & temp2;
		x2 = ~temp1;
		x3 = x2 & temp3;
		Ch = x1 ^ x3;
	end
endfunction

// Function Maj
function [31:0] Maj;
	input [31:0] temp1,temp2,temp3;
	reg [31:0] x1, x2, x3;
	begin
		x1 = temp1 & temp2;
		x2 = temp1 & temp3;
		x3 = temp2 & temp3;
		Maj = ((x1 ^ x2) ^ x3);
	end
endfunction


function [31:0] add5;
	input [31:0] temp1,temp2,temp3,temp4,temp5;
	begin
		add5 = temp1+temp2+temp3+temp4+temp5;
	end
endfunction


endmodule 
