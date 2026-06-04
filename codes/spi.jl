# LOOPBACK: MOSI (Pin 19) -> MISO (Pin 21)

# spidev ioctl constants
const SPI_IOC_WR_MODE          = 0x40016b01
const SPI_IOC_WR_BITS_PER_WORD = 0x40016b03
const SPI_IOC_WR_MAX_SPEED_HZ  = 0x40046b04
const SPI_IOC_MESSAGE_1        = 0x40206b00  # transfer 1 message

# spi_ioc_transfer struct
struct SpiTransfer
    tx_buf        ::UInt64   # pointer to tx buffer
    rx_buf        ::UInt64   # pointer to rx buffer
    len           ::UInt32   # number of bytes
    speed_hz      ::UInt32
    delay_usecs   ::UInt16
    bits_per_word ::UInt8
    cs_change     ::UInt8
    tx_nbits      ::UInt8
    rx_nbits      ::UInt8
    word_delay_usecs ::UInt8
    pad           ::UInt8
end

# OPEN /dev/spidev0.0
const O_RDWR = 0x0002
fd = ccall(:open, Cint, (Cstring, Cint), "/dev/spidev0.0", O_RDWR)
fd < 0 && error("Could not open /dev/spidev0.0 — is SPI enabled?")
println("SPI device opened, fd = $fd")

# CONFIGURE: mode 0, 8 bits, 500 kHz
mode  = Ref{UInt8}(0)
bits  = Ref{UInt8}(8)
speed = Ref{UInt32}(500_000)

ccall(:ioctl, Cint, (Cint, Culong, Ref{UInt8}),  fd, SPI_IOC_WR_MODE,          mode)
ccall(:ioctl, Cint, (Cint, Culong, Ref{UInt8}),  fd, SPI_IOC_WR_BITS_PER_WORD, bits)
ccall(:ioctl, Cint, (Cint, Culong, Ref{UInt32}), fd, SPI_IOC_WR_MAX_SPEED_HZ,  speed)

# LOOPBACK TRANSFER
tx = UInt8[0x01, 0x02, 0x03, 0xAB, 0xFF]
rx = zeros(UInt8, length(tx))

xfer = SpiTransfer(
    UInt64(pointer(tx)),   # tx_buf
    UInt64(pointer(rx)),   # rx_buf
    UInt32(length(tx)),    # len
    UInt32(500_000),       # speed_hz
    UInt16(0),             # delay_usecs
    UInt8(8),              # bits_per_word
    UInt8(0),              # cs_change
    UInt8(0), UInt8(0), UInt8(0), UInt8(0)  # padding
)

ret = ccall(:ioctl, Cint, (Cint, Culong, Ref{SpiTransfer}),
            fd, SPI_IOC_MESSAGE_1, Ref(xfer))

ret < 0 && error("SPI transfer failed (ioctl returned $ret)")

# RESULTS
println("Sent:     ", bytes2hex.(tx))
println("Received: ", bytes2hex.(rx))
println("Match:    ", tx == rx ? "✓ PASS" : "✗ FAIL — check MOSI→MISO jumper")

ccall(:close, Cint, (Cint,), fd)
