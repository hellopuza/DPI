module test;

import "DPI-C" pure function int mul_real(input int a, input int b);

string filename;
string line;
int file;

int rand_num;

reg clk;
reg rst;

int  arg0; int  arg1;
reg  stb0; reg  stb1;
wire ack0; wire ack1;

wire [31:0] res;
wire        res_stb;
reg         res_ack;

int real_res;

multiplier m(
    .clk          (clk),
    .rst          (rst),
    .input_a      (arg0),
    .input_b      (arg1),
    .input_a_stb  (stb0),
    .input_b_stb  (stb1),
    .input_a_ack  (ack0),
    .input_b_ack  (ack1),
    .output_z     (res),
    .output_z_stb (res_stb),
    .output_z_ack (res_ack)
);

initial
begin
    clk = 0;
    forever #1 clk = ~clk;
end

initial
begin
    rst = 0; @(negedge clk)
    rst = 1; @(negedge clk)
    rst = 0;
end

task test_input();
    $display("Process %d %d", arg0, arg1);

    real_res = mul_real(arg0, arg1);

    stb0 = 1; @(posedge ack0)
    stb1 = 1; @(posedge ack1)

    @(posedge res_stb)

    if (real_res != res)
    begin
        $display("%d != %d", real_res, res);
        $fatal(1, "Test failed!");
    end
    res_ack = 1;
    stb0 = 0; stb1 = 0;
endtask

initial
begin
    if ($value$plusargs("arg0=%d", arg0))
    begin
        $value$plusargs("arg1=%d", arg1);
        test_input();
    end
    else if ($value$plusargs("file=%s", filename))
    begin
        file = $fopen(filename, "r");
        while ($fgets(line, file))
        begin
            $sscanf(line, "%d %d", arg0, arg1);
            test_input();
        end
    end
    else if ($value$plusargs("random_mode=%d", rand_num))
    begin
        for (int i = 0; i < rand_num; i++)
        begin
            arg0 = $urandom();
            arg1 = $urandom();
            test_input();
        end
    end
    $finish;
end

endmodule
