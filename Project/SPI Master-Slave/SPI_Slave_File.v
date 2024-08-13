module SPI_Slave (clk, rst_n, MOSI, SS_n, tx_valid, tx_data, MISO, rx_valid, rx_data);
    
    //Parameter:
    parameter IDLE        = 3'b000;
    parameter CHK_CMD     = 3'b001;
    parameter WRITE       = 3'b010;
    parameter READ_DATA   = 3'b011;
    parameter READ_ADD    = 3'b100;

    //Inputs and Outputs:
    input  clk, rst_n, MOSI, SS_n, tx_valid;
    input  [7:0] tx_data;
    output reg MISO, rx_valid;
    output reg [9:0] rx_data;

    //Attributes for encoding
    //(* fsm_encoding = "gray" *)
    (* fsm_encoding = "one_hot" *)          //Highest Setup Slack time meaning can operate at the highes frequency
    //(* fsm_encoding = "sequential" *)

    //Internal Registers:
    reg [2:0] ns, cs;
    reg [3:0] counter_reg;
    reg [7:0] temp_reg;
    reg [9:0] temp_reg_10;
    reg Add_Exist_Flag;

    // State Memory
    always @(posedge clk) begin
        if (~rst_n) begin
            cs <= IDLE;
        end else begin
            cs <= ns;
        end
    end

    // Next State Logic
    always @(*) begin
        ns = cs;
        case(cs)
            IDLE: begin
                if (SS_n == 0) begin
                    ns = CHK_CMD;
                end
                else begin
                    ns = IDLE;
                end
            end
            CHK_CMD: begin
                if (MOSI == 0 && SS_n == 0) begin
                    ns = WRITE;
                end else if (SS_n == 1) begin
                    ns = IDLE;
                end else if (SS_n == 0 && MOSI == 1 && Add_Exist_Flag == 0) begin
                    ns = READ_ADD;
                end else if (SS_n == 0 && MOSI == 1 && Add_Exist_Flag == 1) begin
                    ns = READ_DATA;
                end
            end
            WRITE: begin
                if (SS_n == 1 || counter_reg == 10) begin
                    ns = IDLE;
                end else begin
                    ns = WRITE;
                end
            end
            READ_DATA: begin
                if (SS_n == 1 || counter_reg == 10) begin
                    ns = IDLE;
                end else begin
                    ns = READ_DATA;
                end
            end
            READ_ADD: begin
                if (SS_n == 1 || counter_reg == 10) begin
                    ns = IDLE;
                end else begin
                    ns = READ_ADD;
                end
            end
        endcase
    end

    // Output Logic
    always @(posedge clk) begin
        if (~rst_n) begin
            Add_Exist_Flag      <= 0;
            counter_reg         <= 0;
            rx_valid            <= 0;
            temp_reg_10         <= 0;
            temp_reg            <= 0;
            rx_data             <= 0;
            MISO                <= 0;
        end 
        else begin
            if (SS_n == 0) begin
                if (cs == WRITE || cs == READ_ADD) begin
                    temp_reg_10 <= {temp_reg_10[8:0], MOSI};
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == 10) begin
                        rx_valid       <= 1;
                        rx_data        <= temp_reg_10;
                        counter_reg    <= 0;
                        Add_Exist_Flag <= 1;
                    end else begin
                        rx_valid <= 0;
                    end
                end 
                else if (cs == READ_DATA) begin
                    if (tx_valid) begin
                        temp_reg    <= tx_data;
                        counter_reg <= 0;
                    end 
                    else begin
                        counter_reg <= counter_reg + 1;
                        temp_reg    <= {temp_reg[6:0], 1'b0};
                        MISO        <= temp_reg[7];

                        if (counter_reg == 10) begin
                            counter_reg <= 0;
                        end
                    end
                end else begin
                    rx_valid <= 0;
                end
            end else begin
                counter_reg     <= 0;
                rx_valid        <= 0;
                Add_Exist_Flag  <= 0;
            end
        end
    end
endmodule
