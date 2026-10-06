`timescale 1ns/1ps
// 指令存储器：只读，组合读出，字寻址（忽略 addr[1:0]）
// 256 字 = 1KB。地址位宽写死为 addr[9:2]，改深度时同步改这里
module imem #(
    parameter  DEPTH     = 256,
    parameter  INIT_FILE = "prog.hex"
)(
    input  [31:0] addr,      // 字地址，忽略 addr[1:0]
    output [31:0] instr
);

      reg [31:0] mem [0:DEPTH-1];

    // 初值只有一个来源：INIT_FILE。文件必须正好 DEPTH 个字（现在是 256）。
    initial begin
        $readmemh(INIT_FILE, mem);
    end

    assign instr = mem[addr[9:2]];
endmodule