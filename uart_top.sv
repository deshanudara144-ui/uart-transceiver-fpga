module uart_top (
    input  logic clk,
    input  logic rstn,
    input  logic [7:0] data_in,
    input  logic send,
    input  logic rx,

    output logic tx,
    output logic [6:0] seg_high,
    output logic [6:0] seg_low
);

    logic [7:0] received_data;
    logic data_valid;

    // Instantiate TX
    uart_tx tx_inst (
        .clk(clk),
        .rstn(rstn),
        .data_in(data_in),
        .data_en(send),
        .tx(tx),
        .tx_busy()
    );

    // Instantiate RX
    uart_rx rx_inst (
        .clk(clk),
        .rstn(rstn),
        .rx(rx),
        .data_out(received_data),
        .data_valid(data_valid)
    );

    // 7-seg for lower nibble
    seven_seg seg0 (
        .bin(received_data[3:0]),
        .seg(seg_low)
    );

    // 7-seg for upper nibble
    seven_seg seg1 (
        .bin(received_data[7:4]),
        .seg(seg_high)
    );

endmodule