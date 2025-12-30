TARGET = exit

Include = $(shell pkg-config --cflags --libs gtk+-3.0 gtk-layer-shell-0)

default: all

all: $(TARGET)

$(TARGET) :	
	gcc -o $(TARGET) $(Include) $(TARGET).c

run: 
	./exit


clean:
	-r @(TARGET)

.PHONY: $(TARGET) clean
