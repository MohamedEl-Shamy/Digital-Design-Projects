`timescale 1ns/1ps
module pwm_timer_tb();
parameter CLK_PERIOD = 20;     //50 Mhz

parameter EXT_CLK_PERIOD = 15; //66.67 Mhz



parameter BASE = 0;

parameter CTRL_REG      = 16'd0,
          DIVISOR_REG   = 16'd2,
          PERIOD_REG_0  = 16'd4,
          DC_REG_0      = 16'd6,
          PERIOD_REG_1  = 16'd8,
          DC_REG_1      = 16'd10,
          PERIOD_REG_2  = 16'd12,
          DC_REG_2      = 16'd14,
          PERIOD_REG_3  = 16'd16,
          DC_REG_3      = 16'd18,
          MC_DC_EXT_REG = 16'd20; 


//WISHBONE SLAVE interface:
reg         i_clk_tb;
reg         i_rst_tb;        // Syncrounce active high reset signal
reg         i_wb_cyc_tb;
reg         i_wb_stb_tb;
reg         i_wb_we_tb;
reg  [15:0] i_wb_adr_tb;
reg  [15:0] i_wb_data_tb;
wire        o_wb_ack_tb;
wire [15:0] o_wb_data_tb;

// Output port (non-WISHBONE signals):
reg        i_extclk_tb;
reg [15:0] i_DC_tb;
reg        i_DC_valid_tb;
wire [3:0] o_mc_pwm_tb;

pwm_timer #(.BASE(BASE)) DUT (
    //WISHBONE SLAVE interface:
    .i_clk(i_clk_tb),
    .i_rst(i_rst_tb),
    .i_wb_cyc(i_wb_cyc_tb),
    .i_wb_stb(i_wb_stb_tb),
    .i_wb_we(i_wb_we_tb),
    .i_wb_adr(i_wb_adr_tb),
    .i_wb_data(i_wb_data_tb),
    .o_wb_ack(o_wb_ack_tb),
    .o_wb_data(o_wb_data_tb),

    // Output port (non-WISHBONE signals):
    .i_extclk(i_extclk_tb),
    .i_DC(i_DC_tb),
    .i_DC_valid(i_DC_valid_tb),
    .o_mc_pwm(o_mc_pwm_tb)

);

initial begin
    i_clk_tb = 1'b0;
    forever begin
       #(CLK_PERIOD/2) i_clk_tb = ~ i_clk_tb; 
    end
end

initial begin
    i_extclk_tb = 1'b0;
    forever begin
       #(EXT_CLK_PERIOD/2) i_extclk_tb = ~ i_extclk_tb; 
    end
end


initial begin
    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;
    i_DC_valid_tb = 1'b1;
    
    // ==================== Test case 1: PWM verification ====================
    
    // Period
    wishbone_write(PERIOD_REG_0, 100);
    // Duty for 50% of period
    wishbone_write(DC_REG_0, (100 * (0.5)));

    
    wishbone_write(CTRL_REG, 16'b0001_0110);
    repeat(300) @(posedge i_clk_tb);

    // Duty for 25% of period
    wishbone_write(DC_REG_0, (100 * (0.25)));
    repeat(300) @(posedge i_clk_tb);

    // Testing the Duty cycle to be greater than period
    wishbone_write(PERIOD_REG_0, 50);
    wishbone_write(DC_REG_0, (50 * (1.25)));


    // Testing 4ch outputs
    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;

    // Duty for 25% of period, channel 0
    wishbone_write(PERIOD_REG_0, 100);
    wishbone_write(DC_REG_0, (100 * (0.25)));
    repeat(300) @(posedge i_clk_tb);

    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;

    // Duty for 50% of period, channel 1
    wishbone_write(PERIOD_REG_1, 100);
    wishbone_write(DC_REG_1, (100 * (0.5)));
    repeat(300) @(posedge i_clk_tb);

    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;

    // Duty for 75% of period, channel 2
    wishbone_write(PERIOD_REG_2, 100);
    wishbone_write(DC_REG_2, (100 * (0.75)));
    repeat(300) @(posedge i_clk_tb);

    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;

    // Duty for 50% of period, channel 3
    wishbone_write(PERIOD_REG_3, 100);
    wishbone_write(DC_REG_3, (100 * (1.25)));
    repeat(10000) @(posedge i_clk_tb);

    i_rst_tb = 1'b1;
    @(negedge i_clk_tb)
    i_rst_tb = 1'b0;

    // =======================================================================

    // ======== Test case 2: Timer and Main Counter verification =============
    // Reset period and counter regs
    wishbone_write(CTRL_REG, 16'b1000_0000);

    // Start one-shot timer
    wishbone_write(CTRL_REG, 16'b0000_0100);
    repeat(110) @(posedge i_clk_tb);
    
    // Manual reset after inturpet, one-shot mode in timer
    wishbone_write(CTRL_REG, 16'b0000_0100);
    repeat(110) @(posedge i_clk_tb);


    // Reset period and counter regs
    wishbone_write(CTRL_REG, 16'b1000_0000);

    // Start one-shot timer again
    wishbone_write(CTRL_REG, 16'b0000_0100);
    repeat(110) @(posedge i_clk_tb);
    
    // =======================================================================
    // ==================== Test case 3: Down clocking =====================
    // Period
    wishbone_write(DIVISOR_REG, 2);
    wishbone_write(PERIOD_REG_0, 50);
    // Duty for 50% of period
    wishbone_write(DC_REG_0, (50 * (0.5)));
    wishbone_write(CTRL_REG, 16'b0001_0110);
    repeat(300) @(posedge i_clk_tb);
    
    wishbone_write(DIVISOR_REG, 10);


    // =======================================================================

    // ==================== Test case 4: Wishbone interface: Reading =====================
    wishbone_read(CTRL_REG);
    wishbone_read(DIVISOR_REG);
    wishbone_read(DC_REG_0);
    wishbone_read(PERIOD_REG_0);
    // =======================================================================

    // ======== Test case 5: Timer with extrnal clk =============

    // Reset period and counter regs
    wishbone_write(CTRL_REG, 16'b1000_0000);

    // Start one-shot timer again
    wishbone_write(CTRL_REG, 16'b0000_0101);
    repeat(110) @(posedge i_clk_tb);
    
    // =======================================================================
    repeat(300) @(posedge i_clk_tb);

    $stop;


end

    task wishbone_write;
        input [15:0] adr;
        input [15:0] data;
        begin
            @(posedge i_clk_tb);
            i_wb_we_tb   = 1'b1;
            i_wb_cyc_tb  = 1'b1;
            i_wb_stb_tb  = 1'b1;
            
            i_wb_adr_tb  = adr;
            i_wb_data_tb = data;
            
            wait(o_wb_ack_tb);
            @(posedge i_clk_tb);
            i_wb_we_tb  = 0;
            i_wb_cyc_tb = 0;
            i_wb_stb_tb = 0;
        end
    endtask

    task wishbone_read;
        input [15:0] adr;
        reg   [15:0] data;
        begin
            @(posedge i_clk_tb);
            i_wb_we_tb   = 1'b0;
            i_wb_cyc_tb  = 1'b1;
            i_wb_stb_tb  = 1'b1;

            i_wb_adr_tb = adr;
         
            wait(o_wb_ack_tb);
            @(posedge i_clk_tb);
            data = o_wb_data_tb;
            i_wb_cyc_tb = 0;
            i_wb_stb_tb = 0;
         
            $display("Wishbone Read: Addr = %0d, REG_Data = %0d", adr, data);
        end
    endtask

endmodule