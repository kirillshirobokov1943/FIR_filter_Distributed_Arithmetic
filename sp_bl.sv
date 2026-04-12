module sp_bl
#(
	parameter N = 16,
	parameter logic signed [15:0] h0,     
	parameter logic signed [15:0] h1,
	parameter logic signed [15:0] h2,
	parameter logic signed [15:0] h3
)
(
	input logic clk, 
	input logic rst,
	input logic [16-1:0] x_in [0:3],
	input logic vld_in,
	output logic [16+10:0] y,
	input logic [3:0] cnt
);

logic signed [16-1:16/2] x_reg_up [0:3]; //регистры для хранения старших битов входных данных 
always_ff @(posedge clk, posedge rst)
	if (rst)
		for (int i = 0; i <4; i ++)  x_reg_up[i] <= '0;
	else if (vld_in) //параллельная загрузка
		for (int i = 0; i < 4; i ++) x_reg_up[i] <= x_in[i][16-1:16/2];
	else //последовательная выгрузка
		for (int i = 0; i < 4; i ++) begin
			for (int j = 16/2; j < 16 -1; j ++) x_reg_up[i][j] <= x_reg_up[i][j+1];
			                                    x_reg_up[i][16-1] <= 0;
		end
	
logic signed [16/2 -1 :0] x_reg_down [0:3]; //регистры для хранения младших битов входных данных 
always_ff @(posedge clk, posedge rst)
	if (rst)
		for (int i = 0; i <4; i ++)  x_reg_down[i] <= '0;
	else if (vld_in) //параллельная загрузка
		for (int i = 0; i < 4; i ++) x_reg_down[i] <= x_in[i][16/2-1:0];
	else //последовательная выгрузка
		for (int i = 0; i < 4; i ++) begin
			for (int j = 0; j < 16/2 -1; j ++) x_reg_down[i][j] <= x_reg_down[i][j+1];
			                                   x_reg_down[i][16/2-1] <= 0;
		end

//описание LUT
logic signed [16+1:0] LUT_out_up, LUT_out_down;
logic signed [16-1:0] h [0:3];      //= '{h0, h1, h2, h3}; //массив коэфицентов
assign h[0] = h0;
assign h[1] = h1;
assign h[2] = h2;
assign h[3] = h3;

// LUT_out_up = h[0]*x_reg_up[3][16/2] + h[1]*x_reg_up[2][16/2] + h[2]*x_reg_up[1][16/2] + h[3]*x_reg_up[0][16/2];
assign LUT_out_up =     ({h[0][15], h[0][15], h[0]} & {18{x_reg_up[3][8]}}) +
								({h[1][15], h[1][15], h[1]} & {18{x_reg_up[2][8]}}) + 
								({h[2][15], h[2][15], h[2]} & {18{x_reg_up[1][8]}}) +
								({h[3][15], h[3][15], h[3]} & {18{x_reg_up[0][8]}});
								
								
// LUT_out_down = h[0]*x_reg_down[3][0] + h[1]*x_reg_down[2][0] + h[2]*x_reg_down[1][0] + h[3]*x_reg_down[0][0];
assign LUT_out_down =   ({h[0][15], h[0][15], h[0]} & {18{x_reg_down[3][0]}}) +
								({h[1][15], h[1][15], h[1]} & {18{x_reg_down[2][0]}}) + 
								({h[2][15], h[2][15], h[2]} & {18{x_reg_down[1][0]}}) +
								({h[3][15], h[3][15], h[3]} & {18{x_reg_down[0][0]}});

//блоки регистров после LUT
logic signed [16+1:0] up_reg, down_reg;
always_ff @(posedge clk, posedge rst)
	if (rst) begin
		up_reg   <= '0;
		down_reg <= '0;
	end
	else begin
		up_reg   <= LUT_out_up;
		down_reg <= LUT_out_down;
	end

//умноженный на 2:^8 сигнал от верхней таблицы
wire signed [16+9:0] mul_up = up_reg << 8;


//адаптивный сумматор
logic signed [16+10:0] adaptive_sum;
always_comb
	if (cnt ==8) adaptive_sum = down_reg - mul_up;
	else         adaptive_sum = down_reg + mul_up;


//регистрованный выход
always_ff @(posedge clk, posedge rst)
	if (rst) y <= '0;
	else     y <= adaptive_sum;
	
endmodule