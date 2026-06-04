# LOOPBACK: TX (Pin 8) -> RX (Pin 10)
# `sudo apt install libserialport-dev`
# Pi 4 Tip: it has Bluetooth also mapped to the main UART!

using LibSerialPort

PORT  = "/dev/ttyAMA0"
BAUD  = 9600

try
    LibSerialPort.open(PORT, BAUD) do sp
        sleep(0.5)
        sp_flush(sp, SP_BUF_BOTH)

        msg = "Hello\n"
        write(sp, msg)
        println("Sent: ", strip(msg))

        sleep(0.2)

        if bytesavailable(sp) > 0
            echo = readline(sp)
            println("Received: ", echo)
        else
            println("Nothing received!")
        end
    end
catch e
    println("ERROR: ", e)
end
