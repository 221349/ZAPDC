
NAME=coder

INCDIR=inc
OBJDIR=obj
SRCDIR=src

CC=g++
CFLAGS= -Wall -pedantic

CINC= -I$(INCDIR)
SRCS=$(wildcard src/*.cpp)
DEPS=$(wildcard inc/*.h)
OBJS= $(subst $(SRCDIR),$(OBJDIR),$(SRCS:.cpp=.o ))
all: $(OBJDIR) $(OBJS)
		$(CC) $(CFLAGS) -o $(NAME) $(OBJS)

$(OBJDIR)/%.o : $(SRCDIR)/%.cpp $(DEPS)
	$(CC) $(CFLAGS) $(CINC) -c -o $@ $<

$(OBJDIR):
	mkdir -p $(OBJDIR)

run:
	./$(NAME)

.PHONY: clean

clean:
	rm $(OBJDIR)/*.o
