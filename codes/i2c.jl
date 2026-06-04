using PiGPIO

const LCD_ADDR    = 0x27   # change to 0x3F if needed
const BACKLIGHT   = 0x08
const ENABLE      = 0x04
const CMD         = 0x00
const CHR         = 0x01

pi = Pi()
h  = i2c_open(pi, 1, LCD_ADDR, 0)  # bus 1, address

# --- Low-level helpers ---

function lcd_byte(pi, h, byte, mode)
    hi = (byte & 0xF0) | mode | BACKLIGHT
    lo = ((byte << 4) & 0xF0) | mode | BACKLIGHT

    for nibble in (hi, lo)
        i2c_write_byte(pi, h, nibble | ENABLE)
        sleep(0.0005)
        i2c_write_byte(pi, h, nibble & ~ENABLE)
        sleep(0.0001)
    end
end

function lcd_init(pi, h)
    sleep(0.02)
    for cmd in (0x33, 0x32, 0x06, 0x0C, 0x28, 0x01)
        lcd_byte(pi, h, cmd, CMD)
        sleep(0.003)
    end
end

function lcd_clear(pi, h)
    lcd_byte(pi, h, 0x01, CMD)
    sleep(0.003)
end

function lcd_set_cursor(pi, h, col, row)
    row_offsets = [0x00, 0x40]
    lcd_byte(pi, h, 0x80 | (col + row_offsets[row+1]), CMD)
end

function lcd_print(pi, h, text)
    for c in text
        lcd_byte(pi, h, UInt8(c), CHR)
    end
end

# --- Main ---
lcd_init(pi, h)
lcd_clear(pi, h)

lcd_set_cursor(pi, h, 0, 0)
lcd_print(pi, h, "Hello from Julia")

lcd_set_cursor(pi, h, 0, 1)
lcd_print(pi, h, "  Raspberry Pi  ")

sleep(5)
lcd_clear(pi, h)
i2c_close(pi, h)
