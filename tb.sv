`timescale 1ns/1ns
module tb#(
	parameter T = 10,  //период тактового сигнала
	parameter N = 16 //число коэфицентов фильтра
	)
();

logic signed [16-1:0] x [-15:300];
logic signed [15:0] h [0:15];
logic signed [15 : 0] y [0:300];
int c;

function automatic string to_hex4(input logic signed [15:0] val);
    logic [15:0] uval = $unsigned(val); // интерпретируем как беззнаковое для hex-вывода
    string s = "";
    for (int i = 3; i >= 0; i--) begin
        logic [3:0] nibble = uval[4*i +: 4];
        if (nibble < 10)
            s = {s, $sformatf("%0d", nibble)};
        else
            s = {s, $sformatf("%c", "A" + (nibble - 10))};
    end
    return s;
endfunction

//инициализация массива входных отсчетов и коэфициентов
initial begin
	int fid;
	int i;
    // Открытие файла для чтения
    fid = $fopen("x.txt", "r");
    if (fid == 0) begin
        $error("Не удалось открыть файл x.txt");
        $finish;
    end
	 for (int j = -15; j<0; j++) x[j] = 0;
    // Последовательное чтение 300 отсчетов
    for (i = 0; i < 300; i++) begin
        if ($fscanf(fid, "%h", x[i]) != 1) begin
            $warning("Чтение прервано на отсчете %0d (в файле меньше 300 строк).", i);
            break;
        end
    end
    $fclose(fid);

    $display("Успешно загружено %0d отсчетов в массив x.", i);
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
	integer fd;
	int i;
	vld_in <= 0;
	wait(rst);
	wait(~rst);
	for(int i = -15; i <=280; i++) begin
		@(posedge clk);
		vld_in <= 1;
		for (int j = 0; j < 16; j++) x_in[j] <= x[i+j];
		@(posedge clk);
		vld_in <= 0;
		repeat(20) @(posedge clk);
	end
	
	vld_in <= 0;
	
fd = $fopen("y_out.txt", "w");
if (fd == 0) begin
    $error("Не удалось открыть файл y_out.txt");
    $finish;
end

for (i = 0; i <= 300; i++) begin
    $fdisplay(fd, "%s", to_hex4(y[i]));
end

$fclose(fd);
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

