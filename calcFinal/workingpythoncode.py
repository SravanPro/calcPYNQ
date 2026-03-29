# works fine

from pynq import Overlay, MMIO
from pynq.lib import AxiIIC
import time

# ── 1. LOAD HARDWARE ──────────────────────────────────────────────────────────
overlay = Overlay("design_1.bit")
my_calc = overlay.dataBridgeIP_0
LCD_ADDR = 0x27

# ── 2. LCD DRIVER ─────────────────────────────────────────────────────────────
iic = AxiIIC(overlay.ip_dict['axi_iic_0'])

def lcd_write(data, mode=0):
    high = mode | (data & 0xF0) | 0x08
    iic.send(LCD_ADDR, [high | 0x04], 1)
    iic.send(LCD_ADDR, [high & ~0x04], 1)
    low = mode | ((data << 4) & 0xF0) | 0x08
    iic.send(LCD_ADDR, [low | 0x04], 1)
    iic.send(LCD_ADDR, [low & ~0x04], 1)

def init_lcd():
    for cmd in [0x33, 0x32, 0x28, 0x0C, 0x06, 0x01]:
        lcd_write(cmd, 0)
        time.sleep(0.005)

def write_lcd_line(row, text):
    cmd = 0x80 if row == 0 else 0xC0
    lcd_write(cmd, 0)
    for char in text.ljust(16)[:16]:
        if char == '\xF7':          # raw pi byte
            lcd_write(0xF7, 1)
        else:
            lcd_write(ord(char), 1)

# ── 3. CHAR MAP (your keyboard.sv opcodes) ────────────────────────────────────
CHAR_MAP = {
    0x00: '0', 0x01: '1', 0x02: '2', 0x03: '3', 0x04: '4',
    0x05: '5', 0x06: '6', 0x07: '7', 0x08: '8', 0x09: '9',
    0x2A: '+', 0x2B: '-', 0x2C: '*', 0x2D: '/',
    0x1E: '(', 0x1F: ')',
    0xDD: '.', 0xDC: ',',
    0xC0: 'e',
    0xC1: '\xF7',   # π — sent as raw HD44780 byte 0xF7
    0xF0: 'E',      # exp
    0xF1: 'N',      # ln
    0xF2: '^',      # pow
    0xF3: 'L',      # log
    0xF4: 'S',      # sin
    0xF5: 'C',      # cos
    0xF6: 'T',      # tan
    0xF7: 'c',      # csc
    0xF8: 's',      # sec
    0xF9: 't',      # cot
    0xFA: 'A',      # asin
    0xFB: 'B',      # acos
    0xFC: 'D',      # atan
}

# ── 4. READ FPGA REGISTERS ────────────────────────────────────────────────────
def read_fpga():
    """Returns (equation_string_visible_16_chars, answer_string_16_chars)"""

    # Read all 10 AXI registers (10 x 32-bit = 320 bits)
    regs = [my_calc.read(i * 4) for i in range(10)]

    # ── axiOut bit layout (from your parent.sv) ──
    # [319:316] = 3'b000, jump        (reg9 top 4 bits)
    # [315:308] = 2'b00, sizeOut      (reg9 bits 27:20 ... need to recalc)
    # [307:300] = 2'b00, ptrOut
    # [299:256] = answer (44 bits)    spans reg8 (32 bits) + bottom 12 of reg9
    # [255:0]   = flat_mem (256 bits) regs 0-7

    # reg9 is axiOut[319:288] — the top 32 bits
    reg9 = regs[9]
    reg8 = regs[8]

    # Extract fields from reg9:
    # axiOut[319:316] = {3'b000, jump}   → top 4 bits of reg9
    # axiOut[315:308] = {2'b00, sizeOut} → bits [27:20] of reg9
    # axiOut[307:300] = {2'b00, ptrOut}  → bits [19:12] of reg9
    # axiOut[299:288] = answer[43:32]    → bits [11:0]  of reg9
    sizeOut = (reg9 >> 20) & 0x3F    # 6-bit sizeOut
    ptrOut  = (reg9 >> 12) & 0x3F   # 6-bit ptrOut
    ans_hi  = (reg9 >>  0) & 0xFFF  # top 12 bits of 44-bit answer

    # reg8 = answer[31:0] (bottom 32 bits of answer)
    ans_lo  = reg8 & 0xFFFFFFFF

    raw_answer = (ans_hi << 32) | ans_lo   # full 44-bit answer

    # ── Decode flat_mem (regs 0-7, each reg = 4 bytes, LSB first) ─────────
    mem_bytes = []
    for i in range(8):
        r = regs[i]
        mem_bytes.append( r        & 0xFF)
        mem_bytes.append((r >>  8) & 0xFF)
        mem_bytes.append((r >> 16) & 0xFF)
        mem_bytes.append((r >> 24) & 0xFF)

    # Only decode up to sizeOut valid characters
    equation = ""
    for i in range(min(sizeOut, 32)):
        equation += CHAR_MAP.get(mem_bytes[i], '?')

    # ── Sliding window: keep cursor visible on 16-char display ───────────
    LCD_W = 16
    start = max(0, ptrOut - (LCD_W - 1))
    top_line = equation[start : start + LCD_W]

    # ── Parse 44-bit answer → base-10 float ──────────────────────────────
    # Layout: {2'b00, sign[41], mantissa[40:7], exp[6:0]}
    sign     = (raw_answer >> 41) & 0x1
    mantissa = (raw_answer >>  7) & 0x3FFFFFFFF   # 34 bits
    exp_raw  = (raw_answer >>  0) & 0x7F           # 7 bits, signed 2's complement
    exponent = exp_raw - 128 if (exp_raw & 0x40) else exp_raw

    if mantissa == 0:
        value = 0.0
    else:
        value = ((-1) ** sign) * mantissa * (10 ** exponent)

    bottom_line = f"{value:.8e}"

    return top_line, bottom_line

# ── 5. MAIN LOOP ──────────────────────────────────────────────────────────────
init_lcd()
print("Running. Use your FPGA buttons. Stop kernel to quit.")

last_top    = None
last_bottom = None

while True:
    try:
        top, bottom = read_fpga()
    except Exception as ex:
        print(f"Read error: {ex}")
        time.sleep(0.5)
        continue

    if top != last_top or bottom != last_bottom:
        write_lcd_line(0, top)
        write_lcd_line(1, bottom)
        last_top    = top
        last_bottom = bottom

    time.sleep(0.05)