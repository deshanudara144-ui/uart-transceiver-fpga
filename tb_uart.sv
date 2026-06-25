`timescale 1ns/1ps

module tb_uart;

    // PARAMETERS
    parameter CLOCKS_PER_PULSE = 16;  // keep small for simulation

    // SIGNALS
    logic clk;
    logic rstn;
    logic [7:0] data_in;
    logic send;
    logic tx;
    logic rx;

    logic [7:0] received_data;
    logic data_valid;

    // CLOCK GENERATION (100 MHz → 10ns period)
    always #5 clk = ~clk;

    // DUT: Transmitter
    uart_tx #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) tx_inst (
        .clk(clk),
        .rstn(rstn),
        .data_in(data_in),
        .data_en(send),
        .tx(tx),
        .tx_busy()
    );

    // DUT: Receiver
    uart_rx #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) rx_inst (
        .clk(clk),
        .rstn(rstn),
        .rx(rx),
        .data_out(received_data),
        .data_valid(data_valid)
    );

    // LOOPBACK (TX → RX)
    assign rx = tx;

    // TEST SEQUENCE
    initial begin
        // Initialize
        clk = 0;
        rstn = 0;
        send = 0;
        data_in = 8'h00;

        // Reset
        #20;
        rstn = 1;

        // Wait a bit
        #20;

        // Send first byte
        data_in = 8'hA5;   // 10100101
        send = 1;
        #10;
        send = 0;

        // Wait for transmission to complete
        #(CLOCKS_PER_PULSE * 12 * 10);

        // Send another byte
        data_in = 8'h3C;   // 00111100
        send = 1;
        #10;
        send = 0;

        // Wait again
        #(CLOCKS_PER_PULSE * 12 * 10);

        // Finish simulation
        $stop;
    end

endmodule