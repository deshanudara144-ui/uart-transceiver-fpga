module uart_tx #(
    parameter CLOCKS_PER_PULSE = 5208   // adjust based on clock & baud
)(
    input  logic clk,
    input  logic rstn,
    input  logic [7:0] data_in,
    input  logic data_en,
    output logic tx,
    output logic tx_busy
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [7:0] data;
    logic [2:0] bit_index;
    logic [$clog2(CLOCKS_PER_PULSE)-1:0] clk_count;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            tx <= 1'b1;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    if (data_en) begin
                        data <= data_in;
                        state <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= DATA;
                    end else clk_count <= clk_count + 1;
                end

                DATA: begin
                    tx <= data[bit_index];
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        clk_count <= 0;
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else clk_count <= clk_count + 1;
                end

                STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        state <= IDLE;
                        clk_count <= 0;
                    end else clk_count <= clk_count + 1;
                end

            endcase
        end
    end

    assign tx_busy = (state != IDLE);

endmodule