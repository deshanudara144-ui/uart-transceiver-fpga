module uart_rx #(
    parameter CLOCKS_PER_PULSE = 5208
)(
    input  logic clk,
    input  logic rstn,
    input  logic rx,
    output logic [7:0] data_out,
    output logic data_valid
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [7:0] data;
    logic [2:0] bit_index;
    logic [$clog2(CLOCKS_PER_PULSE)-1:0] clk_count;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data_valid <= 0;
        end else begin
            case (state)

                IDLE: begin
                    data_valid <= 0;
                    if (rx == 0) begin // start bit detected
                        state <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == (CLOCKS_PER_PULSE/2)) begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= DATA;
                    end else clk_count <= clk_count + 1;
                end

                DATA: begin
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        clk_count <= 0;
                        data[bit_index] <= rx;

                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;

                    end else clk_count <= clk_count + 1;
                end

                STOP: begin
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        data_out <= data;
                        data_valid <= 1;
                        state <= IDLE;
                        clk_count <= 0;
                    end else clk_count <= clk_count + 1;
                end

            endcase
        end
    end

endmodule