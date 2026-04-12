module FIR_filter_DA
#(
	parameter N = 16, //число коэфицентов фильтра
	// массив коэфцициентов как параметры
	parameter logic signed [16-1:0] h [0:N-1] = 
		'{16'hFFEC,   16'hFF9E ,  16'h010E ,  16'h0254  , 16'hFB6E ,  16'hF766 ,  16'h114F ,  16'h38F0   ,
		16'h38F0 ,  16'h114F  , 16'hF766 ,  16'hFB6E ,  16'h0254 ,  16'h010E  , 16'hFF9E  , 16'hFFEC }
)
(
	input logic clk,
	input logic rst,
	input logic [16-1: 0] x_in [0: N-1], //входные данные, поступающие параллельно - сразу все
	input logic vld_in, //входной сигнал валидности 
	output logic signed [15 : 0] y_out, 
	output logic vld_out //выходной сигнал валидности
);

logic signed [16+10:0] y0, y1, y2, y3;

// СЧЕТЧИК ДЛЯ АДАПТИВНОГО СУММАТОРА И ФОРМИРОВАНИЯ СИГНАЛА VLD_OUT
logic [3:0] cnt;
// при загрузке отсчетов (vld_in на входе), начинается отсчет, и когда перед выходным регистром
// 7-ой и 15-ый бит, сумматор переходит в вычитатель (из 7-ого бита вычистаем 15-ый умноженый на 256)
logic flag; // флаг, означающий, что блоке обрабатываются данные
always_ff @(posedge clk, posedge rst)
	if (rst) flag <= 0;
	else if (vld_in) flag <= 1;
	else if (cnt == 12) flag <= 0; // сброс флага при окончании обработки данных

always_ff @(posedge clk, posedge rst)
	if (rst) cnt <= 0;
	else if (cnt == 12) cnt <= 0; //сброс счетчика при окончании обработки данных
	else if (flag) cnt <= cnt +1;

assign vld_out = (cnt == 12);


sp_bl #( .N(N), .h0(h[0]), .h1(h[1]), .h2(h[2]), .h3(h[3]) ) sp_bl_0 
(
	.clk(clk),
	.rst(rst),
	.x_in(x_in[12:15] ),
	.vld_in(vld_in),
	.y(y0),
	.cnt(cnt)
);

sp_bl #(.N(N), .h0(h[4]), .h1(h[5]), .h2(h[6]), .h3(h[7]) ) sp_bl_1 
(
	.clk(clk),
	.rst(rst),
	.x_in(x_in[8:11] ),
	.vld_in(vld_in),
	.y(y1),
	.cnt(cnt)
);

sp_bl #(.N(N), .h0(h[8]), .h1(h[9]), .h2(h[10]), .h3(h[11]) ) sp_bl_2 
(
	.clk(clk),
	.rst(rst),
	.x_in(x_in[4:7] ),
	.vld_in(vld_in),
	.y(y2),
	.cnt(cnt)
);

sp_bl #(.N(N), .h0(h[12]), .h1(h[13]), .h2(h[14]), .h3(h[15]) ) sp_bl_3 
(
	.clk(clk),
	.rst(rst),
	.x_in(x_in[0:3] ),
	.vld_in(vld_in),
	.y(y3),
	.cnt(cnt)
);

wire signed [16+11:0] up_sum   = y2 + y3;
wire signed [16+11:0] down_sum = y0 + y1;
logic signed [16+11:0] up_reg, down_reg;
always_ff @(posedge clk, posedge rst)
	if (rst) begin
		up_reg   <= '0;
		down_reg <= '0;
	end
	else begin
		up_reg   <= up_sum;
		down_reg <= down_sum;
	end
	
wire signed [16+12:0] central_sum = up_reg + down_reg;

logic signed [16+12:0] pre_last_reg;
always_ff @(posedge clk, posedge rst)
	if (rst) pre_last_reg <= '0;
	else     pre_last_reg <= central_sum;
	
logic signed [16+13 : 0] y_pre_out	;

wire signed [16+13:0] last_sum = pre_last_reg + (y_pre_out >>> 1);
always_ff @(posedge clk, posedge rst)
	if (rst) y_pre_out <= '0;
	else     y_pre_out <= last_sum;
	
	// учечение: Q7.23 -> Q1.15
	assign y_out = y_pre_out[23:8] ;

endmodule








	
	
