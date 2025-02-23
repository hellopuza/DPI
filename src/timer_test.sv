module test;

int arg;
reg arg_stb;
reg arg_ack;
reg res_stb;

reg dut_running;
int timer;
parameter TIMEOUT=100;

reg clk;
reg rst;

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
    $display("Process %x", arg);

    dut_running = 1;
    arg_stb = 1; @(posedge arg_ack)

    @(posedge res_stb)

    dut_running = 0;
    arg_stb = 0;
endtask

always @(posedge clk)
begin
    if (dut_running)
        timer <= timer + 1;
    else
        timer <= 0;
    if (timer == TIMEOUT)
    begin
        $display("Timeout! DUT has been running too long.");
        $finish;
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        arg <= 0;
        arg_stb <= 0;
        arg_ack <= 0;
        res_stb <= 0;
    end

    if (!arg_ack && arg_stb)
        arg_ack <= 1;
    if (!arg_stb)
    begin
        arg_ack <= 0;
        res_stb <= 0;
    end
    if (arg_ack)
        if (arg < 10)
            res_stb <= 1;
end

initial
begin
    if ($value$plusargs("arg=%x", arg))
    begin
        test_input();
    end
    $finish;
end

endmodule
