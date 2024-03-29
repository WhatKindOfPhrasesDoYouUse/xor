include makefile.conf

NAME = main
TARGET = $(NAME).elf

#VPATH=

OBJDIR = obj
OUTDIR = bin

LDSCRIPTS = -L. -L$(BASE)/ldscripts -T gcc.ld

DEFINE = -D__NO_SYSTEM_INIT

#ASFLAGS=
#CFLAGS  = -std=c99 -Og -g -Wall -ffreestanding
LDFLAGS=$(G_OPT) -nostdlib $(ARCH_FLAGS) $(USE_SEMIHOST) $(LDSCRIPTS) $(DEFINE) $(DI) $(GC) $(MAP) $(MEM_USAGE)

SOURCES = $(wildcard *.s *.S *.c)
HEADERS = $(wildcard *.h)
#SOURCES = main.s

OBJECTS = $(SOURCES)
OBJECTS := $(SOURCES:%.s=%.o)
OBJECTS := $(OBJECTS:%.S=%.o)
OBJECTS := $(OBJECTS:%.c=%.o)

all: build

build: $(NAME).elf $(NAME).hex $(NAME).lst size

envmake:
	@echo VARIABLES:
	@echo SHELL: $(SHELL)
	@echo STARTUP: $(STARTUP)
	@echo CFLAGS: $(CFLAGS)
	@echo CXXFLAGS: $(CXXFLAGS)
	@echo LDFLAGS: $(LDFLAGS)
	@echo OBJECTS: $(OBJECTS)
#	@echo .
#	@echo LINK.s: $(LINK.s)
#	@echo .
#	@echo LINK.o: $(LINK.o)
#	@echo .

$(TARGET): $(SOURCES) $(STARTUP)
	$(LINK.o) $^ $(LDLIBS) -o $@

#$(TARGET): $(OBJECTS) $(STARTUP)
#	$(LINK.o) $^ $(LDLIBS) -o $@

# This pattern rule extract binary from an ELF executable
# filename.bin is built from filename.elf
%.bin: %.elf
	$(OBJCOPY) $< -O binary $@

# Produce firmware file in Intel Hex format
%.hex: %.elf
	$(OBJCOPY) $< -O ihex $@

# Disassemble
%.lst: %.elf
	$(OBJDUMP) -d $< > $@

#.PHONY: build

size:
#	@echo Size: $(TARGET)
	@$(SIZE) $(TARGET)

.PHONY: clean
clean:
	$(RM) $(TARGET) *.o *.elf *.bin *.hex *.map *.lst

#.SUFFIXES:
#.SUFFIXES: .s .S .c .o .elf .bin .hex .ln

#.DEFAULT_TARGET: all
