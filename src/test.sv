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

task reset();
    rst = 0; @(negedge clk)
    rst = 1; @(negedge clk)
    rst = 0;
endtask

function bit is_nan(int a);
    return (a[30:23] == 'hFF) & (a[22:0] != 0);
endfunction

function bit not_eq(int a, int b);
    return (is_nan(a) & is_nan(b)) ? 0 : (a != b);
endfunction

task test_input();
    reset();
    $display("Process %x %x", arg0, arg1);

    real_res = mul_real(arg0, arg1);

    res_ack = 0;
    dut_running = 1;
    stb0 = 1; @(posedge ack0)
    stb1 = 1; @(posedge ack1)

    @(posedge res_stb)
    dut_running = 0; @(posedge clk)

    if (not_eq(real_res, res))
    begin
        $display("%x != %x", real_res, res);
        $fatal(1, "Test failed!");
    end
endtask

reg dut_running;
int timer;
parameter TIMEOUT=1000;

always @(posedge clk)
begin
    if (dut_running)
        timer <= timer + 1;
    else
        timer <= 0;
    if (rst)
    begin
        stb0 <= 0;
        stb1 <= 0;
    end

    if (timer == TIMEOUT)
    begin
        $display("Timeout! DUT has been running too long.");
        $finish;
    end
end

initial
begin
    if ($value$plusargs("arg0=%x", arg0))
    begin
        $value$plusargs("arg1=%x", arg1);
        test_input();
    end
    else if ($value$plusargs("file=%s", filename))
    begin
        file = $fopen(filename, "r");
        while ($fgets(line, file))
        begin
            $sscanf(line, "%x %x", arg0, arg1);
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
