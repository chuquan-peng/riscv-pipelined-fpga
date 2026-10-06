// ============================================================================
// pynq_z1_top.v -- board-level wrapper: RV32I single-cycle core on PYNQ-Z1
//
// PL only (route A). The core in rtl/ is instantiated unchanged.
// This file adds only what the board needs:
//   1. Clock   : 125 MHz (pin H16) -> MMCM -> 50 MHz core clock
//   2. Reset   : btn[0] and MMCM lock -> 2-FF synchronizer -> core rst
//   3. Display : 4 LEDs show one nibble of PC (or of the instruction)
//   4. Heartbeat on the green channel of LD4: proves the core clock is alive
//
// Controls
//   btn[0]  hold = core in reset (PC forced to 0)
//   btn[1]  hold = LEDs show dbg_instr instead of dbg_pc
//   sw[1:0] nibble select: 00 = [3:0], 01 = [7:4], 10 = [11:8], 11 = [15:12]
// ============================================================================

module pynq_z1_top (
    input  wire       sysclk,   // 125 MHz from the Ethernet PHY
    input  wire [1:0] btn,      // high when pressed
    input  wire [1:0] sw,
    output wire [3:0] led,      // high = on
    output wire       led4_g    // high = on
);

    // ------------------------------------------------------------------
    // 1. Clock: 125 MHz -> 50 MHz
    //    f_vco = 125 MHz * CLKFBOUT_MULT_F / DIVCLK_DIVIDE = 125 * 8 / 1 = 1000 MHz
    //    f_out = f_vco / CLKOUT0_DIVIDE_F                  = 1000 / 20   =   50 MHz
    //    To change the core frequency, change CLKOUT0_DIVIDE_F only.
    // ------------------------------------------------------------------
    wire clk_fb;        // MMCM internal feedback, not used by any logic
    wire clk_mmcm;      // 50 MHz, straight out of the MMCM
    wire clk_core;      // 50 MHz, on the global clock network
    wire locked;        // high once the MMCM output is stable

    MMCME2_BASE #(
        .BANDWIDTH        ("OPTIMIZED"),
        .CLKIN1_PERIOD    (8.000),
        .DIVCLK_DIVIDE    (1),
        .CLKFBOUT_MULT_F  (8.000),
        .CLKOUT0_DIVIDE_F (20.000),
        .STARTUP_WAIT     ("FALSE")
    ) u_mmcm (
        .CLKIN1   (sysclk),
        .CLKFBIN  (clk_fb),
        .CLKFBOUT (clk_fb),
        .CLKOUT0  (clk_mmcm),
        .LOCKED   (locked),
        .PWRDWN   (1'b0),
        .RST      (1'b0)
    );

    BUFG u_bufg (
        .I (clk_mmcm),
        .O (clk_core)
    );

    // ------------------------------------------------------------------
    // 2. Reset
    //    btn[0] and locked are asynchronous to clk_core. The core samples
    //    rst on the clock edge (synchronous reset), so both go through two
    //    flip-flops first. Initial value 11: the core is held in reset from
    //    the moment the bitstream is loaded until the MMCM has locked.
    // ------------------------------------------------------------------
    (* ASYNC_REG = "TRUE" *) reg [1:0] rst_sync = 2'b11;

    always @(posedge clk_core) begin
        rst_sync <= {rst_sync[0], btn[0] | ~locked};
    end

    wire core_rst = rst_sync[1];

    // ------------------------------------------------------------------
    // Core (unchanged)
    // ------------------------------------------------------------------
    wire [31:0] dbg_pc;
    wire [31:0] dbg_instr;

    top u_core (
        .clk            (clk_core),
        .rst            (core_rst),
        .dbg_pc         (dbg_pc),
        .dbg_instr      (dbg_instr),
        .dbg_alu_result (),
        .dbg_wb_data    (),
        .dbg_reg_write  ()
    );

    // ------------------------------------------------------------------
    // 3. Display: pure combinational, no state
    // ------------------------------------------------------------------
    wire [31:0] view = btn[1] ? dbg_instr : dbg_pc;

    assign led = view[{sw, 2'b00} +: 4];

    // ------------------------------------------------------------------
    // 4. Heartbeat: about 0.75 Hz at 50 MHz, not affected by reset.
    //    The tri-color LED is bright, so it is only driven 1/16 of the
    //    time while it is "on".
    // ------------------------------------------------------------------
    reg [25:0] hb = 26'd0;

    always @(posedge clk_core) begin
        hb <= hb + 26'd1;
    end

    assign led4_g = hb[25] & (hb[11:8] == 4'd0);

endmodule
