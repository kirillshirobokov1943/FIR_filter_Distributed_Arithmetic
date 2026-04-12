`timescale 1ns/1ns
module tb#(
	parameter T = 10,  //период тактового сигнала
	parameter N = 16 //число коэфицентов фильтра
	)
();

logic signed [16-1:0] x [0:99];
logic signed [15:0] h [0:15];
logic signed [15 : 0] y [0:100];
int c;
//инициализация массива входных отсчетов (синус с частотой в полосе пропускания)
initial begin
	
	x[0] = 16'h0000;
	x[1] = 16'h100B;
	x[2] = 16'h1FD5;
	x[3] = 16'h2F1F;
	x[4] = 16'h3DAA;
	x[5] = 16'h4B3D;
	x[6] = 16'h579F;
	x[7] = 16'h62A0;
	x[8] = 16'h6C13;
	x[9] = 16'h73D1;
	x[10] = 16'h79BC;
	x[11] = 16'h7DBC;
	x[12] = 16'h7FBF;
	x[13] = 16'h7FBF;
	x[14] = 16'h7DBC;
	x[15] = 16'h79BC;
	x[16] = 16'h73D1;
	x[17] = 16'h6C13;
	x[18] = 16'h62A0;
	x[19] = 16'h579F;
	x[20] = 16'h4B3D;
	x[21] = 16'h3DAA;
	x[22] = 16'h2F1F;
	x[23] = 16'h1FD5;
	x[24] = 16'h100B;
	x[25] = 16'h0000;
	x[26] = 16'hEFF5;
	x[27] = 16'hE02B;
	x[28] = 16'hD0E1;
	x[29] = 16'hC256;
	x[30] = 16'hB4C3;
	x[31] = 16'hA861;
	x[32] = 16'h9D60;
	x[33] = 16'h93ED;
	x[34] = 16'h8C2F;
	x[35] = 16'h8644;
	x[36] = 16'h8244;
	x[37] = 16'h8041;
	x[38] = 16'h8041;
	x[39] = 16'h8244;
	x[40] = 16'h8644;
	x[41] = 16'h8C2F;
	x[42] = 16'h93ED;
	x[43] = 16'h9D60;
	x[44] = 16'hA861;
	x[45] = 16'hB4C3;
	x[46] = 16'hC256;
	x[47] = 16'hD0E1;
	x[48] = 16'hE02B;
	x[49] = 16'hEFF5;
	x[50] = 16'h0000;
	x[51] = 16'h100B;
	x[52] = 16'h1FD5;
	x[53] = 16'h2F1F;
	x[54] = 16'h3DAA;
	x[55] = 16'h4B3D;
	x[56] = 16'h579F;
	x[57] = 16'h62A0;
	x[58] = 16'h6C13;
	x[59] = 16'h73D1;
	x[60] = 16'h79BC;
	x[61] = 16'h7DBC;
	x[62] = 16'h7FBF;
	x[63] = 16'h7FBF;
	x[64] = 16'h7DBC;
	x[65] = 16'h79BC;
	x[66] = 16'h73D1;
	x[67] = 16'h6C13;
	x[68] = 16'h62A0;
	x[69] = 16'h579F;
	x[70] = 16'h4B3D;
	x[71] = 16'h3DAA;
	x[72] = 16'h2F1F;
	x[73] = 16'h1FD5;
	x[74] = 16'h100B;
	x[75] = 16'h0000;
	x[76] = 16'hEFF5;
	x[77] = 16'hE02B;
	x[78] = 16'hD0E1;
	x[79] = 16'hC256;
	x[80] = 16'hB4C3;
	x[81] = 16'hA861;
	x[82] = 16'h9D60;
	x[83] = 16'h93ED;
	x[84] = 16'h8C2F;
	x[85] = 16'h8644;
	x[86] = 16'h8244;
	x[87] = 16'h8041;
	x[88] = 16'h8041;
	x[89] = 16'h8244;
	x[90] = 16'h8644;
	x[91] = 16'h8C2F;
	x[92] = 16'h93ED;
	x[93] = 16'h9D60;
	x[94] = 16'hA861;
	x[95] = 16'hB4C3;
	x[96] = 16'hC256;
	x[97] = 16'hD0E1;
	x[98] = 16'hE02B;
	x[99] = 16'hEFF5;

	
end

//объявление сигналов для подключеняи к блоку
logic clk, rst, vld_in, vld_out;
logic [16-1: 0] x_in [0: N-1];
logic signed [15 : 0] y_out;

//подключение dut
FIR_filter_DA #(.N(N)) DUT
(
	.clk(clk),
	.rst(rst),
	.x_in(x_in[0: N-1]),
	.vld_in(vld_in),
	.y_out(y_out),
	.vld_out(vld_out)
);

//заведение clk, rst)
initial begin
	clk <= 0;
	forever begin
		#(T/2);
		clk <= ~clk;
	end
end

initial begin
	rst <= 0;
	#(T/2);
	rst <= 1;
	#(T/2);
	rst <= 0;
end


//основной initial блок
//тест с подачей синуса в области пропускания:

initial begin
	vld_in <= 0;
	wait(rst);
	wait(~rst);
	for(int i = 0; i <=84; i++) begin
		@(posedge clk);
		vld_in <= 1;
		for (int j = 0; j < 16; j++) x_in[j] <= x[i+j];
		@(posedge clk);
		vld_in <= 0;
		repeat(20) @(posedge clk);
	end
	
	vld_in <= 0;
	repeat(20) @(posedge clk);
	for (int k = 0; k < c; k++) $display("%h", y[k]);
	$stop();
end



//сбор данных в массив
initial begin
	c = 0;
	forever begin
		@(posedge clk);
		if (vld_out) begin
			y[c] = y_out;
			c = c+1;
		end
	end
end

endmodule