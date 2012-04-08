CC = gcc
SOURCE = lib/utils/utils.c
OUTFILE = lib/utils/utils.so
CCFLAGS = -shared -fPIC -o $(OUTFILE) $(SOURCE)

all:
	$(CC) $(CCFLAGS)

