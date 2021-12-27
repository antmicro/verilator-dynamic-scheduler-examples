`timescale  1 ps / 1 ps

module uart_tb;

    logic clk, rst;
    logic [15:0] prescale = 1;

    logic  s_axis_tvalid, s_axis_tready;
    logic [7:0] s_axis_tdata;
    logic [7:0] c;

    logic  m_axis_tvalid, m_axis_tready;
    logic [7:0] m_axis_tdata;

    logic rxd, txd;

    logic tx_busy, rx_busy, rx_overrun_error, rx_frame_error;

    initial begin
        forever begin
            #1 clk = 1'b0;
            #1 clk = 1'b1;
        end
    end

    event rst_complete;
    initial begin
        rst = 1;
        #10 $display("Rst end");
        rst = 0;
        -> rst_complete;
    end

    uart DUT(
        .clk(clk),
        .rst(rst),
        .prescale(prescale),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .rxd(rxd),
        .txd(txd),
        .tx_busy(tx_busy),
        .rx_busy(rx_busy),
        .rx_overrun_error(rx_overrun_error),
        .rx_frame_error(rx_frame_error)
    );
    event send_data_uart;
    event transfer_complete_uart;
    event send_data_axi;
    event transfer_complete_axi;

    logic UART_finished, AXI_finished;

    string _input_uart, _output_uart;
    string _input_axi, _output_axi;
    int _count;

    // UART receiver testbench
    initial begin
        _input_uart = "hello world";
        UART_finished = 1'b0;
        rxd = 1;
        m_axis_tready = 0;
        _count = prescale * 8;
        wait(rst_complete.triggered);
        fork
            // send UART data trigger
            begin
                for (int i = 0; i < _input_uart.len(); i++) begin
                    int _delay = $urandom() % 50;
                    for (int j = 0;j<_delay; j++) begin
                        @(posedge clk);
                    end
                    ->send_data_uart;
                    wait(transfer_complete_uart.triggered);
                    @(posedge clk);
                end
            end

            // UART transmitter
            begin
                for (int i = 0; i <_input_uart.len(); i++) begin
                    wait(send_data_uart.triggered);
                    _count = prescale * 8;
                    rxd = 0;
                for (int j=0;j<_count;j++) begin
                        @(posedge clk);
                end
                for (int k=0;k<8;k++)begin
                        rxd = _input_uart[i] >> k;
                     for (int j=0;j<_count;j++) begin
                        @(posedge clk);
                     end
                end
                    rxd = 1;
                for (int j=0;j<_count;j++) begin
                    @(posedge clk);
                end
                $display("UART_RX sent: %x", _input_uart[i], $time);
                -> transfer_complete_uart;
                end
            end

            // AXI stream sink
            begin
                for (int i = 0; i <_input_uart.len(); i++) begin
                    m_axis_tready = 1;
                    while (m_axis_tvalid != 1'b1) begin
                        @(posedge clk);
                    end
                    _output_uart = {_output_uart, m_axis_tdata};
                    $display("UART_RX received: %x", m_axis_tdata, $time);
                    @(posedge clk);
                end
            end
        join
        if (_input_uart == _output_uart)
            $display("Data received successfully");
        else
            $display("Data reception failed");
        UART_finished = 1'b1;
    end

    // UART transmitter testbench
    initial begin
        AXI_finished = 1'b0;
        _input_axi = "hello world";
        s_axis_tvalid = 0;
        _count = prescale * 8;
    wait(rst_complete.triggered);
        fork
            // send AXI data trigger
            begin
                for (int i = 0; i < _input_axi.len(); i++) begin
                    int _delay = $urandom() % 50;
                    for (int j = 0;j<_delay; j++)
                        @(posedge clk);
                    ->send_data_axi;
                    wait(transfer_complete_axi.triggered);
                    @(posedge clk);
                end
            end

            // UART receiver
            begin
                for (int i = 0; i <_input_axi.len(); i++) begin
                    c = 8'h00;
                    while (txd != 1'b0)
                        @(posedge clk);
                    for (int j=0;j<_count;j++)
                        @(posedge clk);
                    for (int k=0;k<8;k++) begin
                        c[k] = txd;
                        for (int j=0;j<_count;j++)
                            @(posedge clk);
                    end
                    $display("UART_TX received: %x", m_axis_tdata, $time);
                    _output_axi = {_output_axi, c};
                end
            end

            // AXI stream source
            begin
                for (int i = 0; i <_input_axi.len(); i++) begin
                    #0.1 s_axis_tvalid = 0;
                    wait(send_data_axi.triggered);
                    s_axis_tvalid = 1;
                    s_axis_tdata = _input_axi[i];
                    $display("UART_TX sent: %x", _input_axi[i], $time);
                    while (s_axis_tready != 1'b1)
                        @(posedge clk);
                    @(posedge clk);
                    -> transfer_complete_axi;
                end
                s_axis_tvalid = 0;
            end
        join
        if (_input_axi == _output_axi)
            $display("Data sent successfully");
        else
            $display("Data sending failed");
        AXI_finished = 1'b1;
    end

    initial begin
        while (!AXI_finished || !UART_finished)
            #1;
        $display("Finished!");
        $finish;
    end
endmodule
