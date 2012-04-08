CC = gcc
SOURCE = utils.c
OUTFILE = utils.so
CCFLAGS = -shared -fPIC -o $(OUTFILE) $(SOURCE)

all:
	$(CC) $(CCFLAGS)

