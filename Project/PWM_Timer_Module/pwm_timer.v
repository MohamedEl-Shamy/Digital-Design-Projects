module pwm_timer #(parameter BASE = 0) (
  //WISHBONE SLAVE interface:
  input             i_clk,
  input             i_rst,        // Syncrounce active high reset signal
  input             i_wb_cyc,
  input             i_wb_stb,
  input             i_wb_we,
  input      [15:0] i_wb_adr,
  input      [15:0] i_wb_data,
  output reg        o_wb_ack,
  output reg [15:0] o_wb_data,
  
  //Non-WISHBONE signals:
  input             i_extclk,
  input [15:0]      i_DC,


  input             i_DC_valid,
  output reg [3:0]  o_mc_pwm
);

reg [7:0]  Ctrl;
reg [15:0] Divisor;
reg [15:0] Period [0:3];
reg [15:0] DC [0:3];

reg [3:0]  MC_DC_EXT;

// ============================ WISHBONE SLAVE ================================== //
integer i;
always @(posedge i_clk) begin
    if(i_rst) begin
        Ctrl         <= 0;
        Divisor      <= 0;

        for (i=0; i<4; i=i+1) begin
            Period[i] <= 0;
            DC[i] <= 0;
            MC_DC_EXT[i] <= 0;
        end

        o_wb_ack  <= 0;
        o_wb_data <= 0;
    end 
    else begin
        if(i_wb_stb & i_wb_cyc & !o_wb_ack) begin
            o_wb_ack <= 1;                              // ack assertion
            if(i_wb_we) begin                           // write operation
                case (i_wb_adr)
                    BASE+0: Ctrl       <= i_wb_data[7:0];
                    BASE+2: Divisor    <= i_wb_data; 
 
                    BASE+4: Period[0]  <= i_wb_data;
                    BASE+6: DC[0]      <= i_wb_data;
                 
                    BASE+8: Period[1]  <= i_wb_data;
                    BASE+10: DC[1]     <= i_wb_data;
 
                    BASE+12: Period[2] <= i_wb_data;
                    BASE+14: DC[2]     <= i_wb_data;
 
                    BASE+16: Period[3] <= i_wb_data;
                    BASE+18: DC[3]     <= i_wb_data;
                    BASE+20: MC_DC_EXT <= i_wb_data[3:0];

                endcase
            end
            else begin
                case (i_wb_adr)                         // read operation
                    BASE+0:  o_wb_data <= {8'b0, Ctrl};
                    BASE+2:  o_wb_data <= Divisor;   
                    BASE+4:  o_wb_data <= Period[0];
                    BASE+6:  o_wb_data <= DC[0];

                    BASE+8:  o_wb_data <= Period[1];
                    BASE+10: o_wb_data <= DC[1]; 

                    BASE+12: o_wb_data <= Period[2];
                    BASE+14: o_wb_data <= DC[2]; 

                    BASE+16: o_wb_data <= Period[3];
                    BASE+18: o_wb_data <= DC[3];  

                    BASE+20: o_wb_data <= {12'b0, MC_DC_EXT};
  
                endcase
            end
        end 
        else begin
            o_wb_ack <= 0;
        end
    end
end



// ============================ Down clocking ================================== //
reg [15:0]      clk_div_counter;
reg             div_clk_reg;
reg             odd_phase;
wire            div_enable = (Divisor > 1);
wire            is_odd = Divisor[0];
wire            div_clk;

assign div_clk = div_enable ? div_clk_reg : i_clk;

always @(posedge i_clk) begin
    if (i_rst) begin
        clk_div_counter <= 0;
        div_clk_reg <= 0;
        odd_phase <= 0;
    end
    else if (div_enable) begin
        if ((!is_odd && (clk_div_counter == (Divisor/2 - 1))) || (is_odd && ((odd_phase && clk_div_counter == (Divisor/2)) || (!odd_phase && clk_div_counter == (Divisor/2 - 1))))) 
          begin
            div_clk_reg <= ~div_clk_reg;
            clk_div_counter <= 0;
            if (is_odd) 
              odd_phase <= ~odd_phase;
          end
        else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end 
    else 
      begin
          clk_div_counter <= 0;
          div_clk_reg <= 0;
          odd_phase <= 0;
      end
end
// ====================================================================================== //

// ============================ Main counter ============================================ //

//Some internal signals
reg [15:0] counter [0:3];
wire timer_mode        = ~Ctrl[1] ;   //When ctrl[1]=0, timer mode
wire counter_enable    = Ctrl[2] ;   //When set, timer starts. When cleared, timer stops
wire continuous_mode   = Ctrl[3]  ;
wire interrupt_clear   = ~Ctrl[5] ;   //Clear when written 0
wire ctrl_bit_7_reset  = Ctrl[7]  ;    //When set, main counter resets, o_pwm and crtl bit 5 are also reset


// Main Counter module:
always @(posedge div_clk) begin
    if(i_rst || ctrl_bit_7_reset) begin
        counter[0] <= 0;
        counter[1] <= 0;
        counter[2] <= 0;
        counter[3] <= 0;

    end
    else if(counter_enable) begin
        if(~timer_mode) begin
            // PWM mode - always wraps
            counter[0] <= (counter[0] >= Period[0]) ? 0 : counter[0] + 1;
            counter[1] <= (counter[1] >= Period[1]) ? 0 : counter[1] + 1;
            counter[2] <= (counter[2] >= Period[2]) ? 0 : counter[2] + 1;
            counter[3] <= (counter[3] >= Period[3]) ? 0 : counter[3] + 1;
        end
        else begin
            // Timer mode
            if(counter[0] >= Period[0]) begin
                counter[0] <= continuous_mode ? 0 : counter[0]; // Auto-reset only if continuous
            end
            else begin
                counter[0] <= counter[0] + 1;
            end
        end
    end
end
// =========================================================================================== //


// =================================== Synchronizer ========================================= //
    // bin2gray
    wire [15:0] counter_in[0:3], counter_Syn[0:3], counter_gray[0:3];
    reg [15:0]  counter_gray_Syn[3:0], R1[3:0];


    genvar i_syn, g_i;
    generate
        for (i_syn = 0 ; i_syn < 4; i_syn = i_syn+1) begin
            assign counter_gray[i_syn] = counter[i_syn] ^ (counter[i_syn] >> 1);

            //syn. to extrnal_clk domain
            always @(posedge i_extclk) begin
                if (i_rst) begin
                    R1[i_syn]               <= 0;
                    counter_gray_Syn[i_syn] <= 0;
                end
                else if (Ctrl[0]) begin
                    R1[i_syn]               <= counter_gray[i_syn]; 
                    counter_gray_Syn[i_syn] <= R1[i_syn]; 
                end
            end

            for(g_i=0; g_i < 16; g_i = g_i+1) begin
                assign counter_Syn[i_syn][g_i] = ^(counter_gray_Syn[i_syn] >> g_i);
            end


        //gray2bin
            assign counter_in[i_syn] = (Ctrl[0]) ? counter_Syn[i_syn] : counter[i_syn];
        end 
    endgenerate

    
        
    
    
// ============================================================================ //

// ================================== PWM ===================================== //
    wire clk_selected = (Ctrl[0]) ? i_extclk : i_clk;
    wire pwm_mode     = Ctrl[1];
    wire counter_en   = Ctrl[2];
    wire pwm_en       = Ctrl[4];
    wire use_iDC      = Ctrl[6];
    wire reset_main   = Ctrl[7];
    
    // Internal Wires for PWM:
    reg [15:0] dc_val[3:0];
    wire pwm_raw[3:0];  // Unregistered PWM output

    genvar g_p;
    generate
        for (g_p = 0; g_p < 4; g_p = g_p +1 ) begin
            

        // Duty cycle selection (with clipping)
            always @(*) begin
            if (use_iDC && i_DC_valid && MC_DC_EXT[g_p])
                dc_val[g_p] = (i_DC > Period[g_p]) ? Period[g_p] : i_DC;
            else
                dc_val[g_p] = (DC[g_p] > Period[g_p]) ? Period[g_p] : DC[g_p];
            end
        
    
        // Glitch-free PWM generation
        assign pwm_raw[g_p] = (dc_val[g_p] == Period[g_p]) ?     // DC clipped to Period?
                            (counter_in[g_p] != 16'hFFFF) :           // Almost always HIGH
                            (counter_in[g_p] < dc_val[g_p]);          // Normal PWM
        

        // Registered output
        always @(posedge clk_selected) begin
            if (i_rst || reset_main) begin
                o_mc_pwm[g_p] <= 0;
            end
            else if (pwm_mode) begin
                o_mc_pwm[g_p] <= pwm_en ? pwm_raw[g_p] : 1'b0;
            end
        end

    end
endgenerate
// ============================================================================ //




// ================================= Timer ==================================== //

// In Timer module
always @(posedge clk_selected) begin
    if(i_rst || ctrl_bit_7_reset) begin
        o_mc_pwm[0] <= 0;
        Ctrl[5] <= 0; // Clear interrupt
    end
    else if(timer_mode) begin // Timer mode
        if(counter_in[0] >= Period[0]) begin
            o_mc_pwm[0] <= 1; // Generate pulse
            Ctrl[5] <= 1; // Set interrupt
            
        if(~continuous_mode) begin
                Ctrl[2] <= 0; // Auto-disable counter
            end
        end
        else begin
            o_mc_pwm[0] <= 0;
        end
    end
end
// ============================================================================ //

endmodule