# Toolchain binaries
AS      = ia16-elf-as
CC      = ia16-elf-gcc
LD      = ia16-elf-ld
OBJCOPY = ia16-elf-objcopy
OBJDUMP = ia16-elf-objdump
SIZE    = ia16-elf-size

# Target files
TARGET  = sysrom.bin
ELF     = sysrom.elf
MAP     = sysrom.map
LST     = sysrom.lst
LDS     = memmap.ld

# Source and object files
ASM_SRCS = crt0.s
C_SRCS   = main.c
OBJS     = $(ASM_SRCS:.s=.o) $(C_SRCS:.c=.o)
LSTS     = $(ASM_SRCS:.s=.lst) $(C_SRCS:.c=.lst)

# Compiler and assembler flags
ASFLAGS  =
CFLAGS   = -march=i8088 -masm=intel -Os -ffreestanding -fno-builtin -Wall -Wextra -Werror -g1
LDFLAGS  = -T $(LDS) -Map=$(MAP) --nostdlib

# Find libgcc for 32-bit math helpers (__mulsi3, __divsi3, etc.)
#LIBGCC   = $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)

.PHONY: all clean disasm

all: $(TARGET) $(LST)

# Convert ELF to exact 64 KB (65536-byte) 0xFF-padded flat ROM binary
$(TARGET): $(ELF)
	$(OBJCOPY) -O binary --gap-fill=0xFF --pad-to=0x100000 $< $@
	$(SIZE) -A $(ELF)

# Produce full linked disassembly listing with interleaved C/ASM source and resolved addresses
$(LST): $(ELF)
	$(OBJDUMP) -d -S -M intel,i8086 $< > $@

# Link object files into intermediate ELF using linker script
$(ELF): $(OBJS) $(LDS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBGCC)

# Compile C sources and generate per-file mixed C/assembly listings
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble GAS sources and generate per-file assembly listings
%.o: %.s
	$(AS) $(ASFLAGS) -ahlms=$(@:.o=.lst) $< -o $@

# Print disassembly to stdout
disasm: $(ELF)
	$(OBJDUMP) -d -S -M intel,i8086 $(ELF)

clean:
	rm -f $(OBJS) $(LSTS) $(ELF) $(TARGET) $(MAP) $(LST)

