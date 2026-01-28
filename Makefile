# Пример https://habr.com/ru/post/111691/
# и UOS мэйк файл
# Мануал Make https://www.opennet.ru/docs/RUS/make_compile/make-8.html

TARGET	= $(CURDIR)

# Maximum optimization
#OPTIMIZE = -Os -fomit-frame-pointer
OPTIMIZE  = -O

CPPFLAGS  = $(OPTIMIZE)

# We use memcpy etc. with slightly different args,
# so we need to use no-builtin option to prevent conflict.
ifeq ($(ARCH),arm)
	BINDIR = d:/Software/gcc/arm-none-eabi-10/bin
  PREFIX  = arm-none-linux-gnueabihf-
  CFLAGS  = -mcpu=cortex-a9 -mfpu=neon -static -g
else
	BINDIR = d:/Software/gcc/mingw-10.0.0/bin
	PREFIX =
endif

CC      = $(BINDIR)/$(PREFIX)g++
CPPFLAGS += -Wno-unused -Wno-unused-result -std=c++2a -pthread -Wall -Wextra -Werror -Wpedantic
ASFLAGS =
LIBS    = #"D:/Software/gcc/mingw530_32/i686-w64-mingw32/include/c++" -lg++
LDFLAGS = -Wl,-rpath=./ $(addprefix -l,$(LIBS))
AR      = $(BINDIR)/$(PREFIX)ar
SIZE    = $(BINDIR)/$(PREFIX)size
OBJDUMP = $(BINDIR)/$(PREFIX)objdump
OBJCOPY = $(BINDIR)/$(PREFIX)objcopy

APPNAME	= p

#Проверить
root_include_dir := $(CURDIR)
root_source_dir  := $(CURDIR)
# source_subdirs   := $(root_source_dir)
# objects_dir      := $(addprefix $(root_source_dir)/, $(source_subdirs))
objects_dir      := $(root_source_dir)/obj
$(info objects_dir: $(objects_dir))

# objects := $(patsubst ../../%, %, $(wildcard $(addsuffix /*.c*, $(root_source_dir))))
# $(info objects: $(objects))

# В objects делаются записи имён файлов с исходным кодом (*.cpp, *.c), расширение
# которых через несколько шагов меняется на *.o
# $(wildcard ШАБЛОН)
# Аргумент ШАБЛОН является шаблоном имени файла, обычно содержащим шаблонные символы . Результатом
# функции wildcard является разделенный пробелами список имен существующих файлов, удовлетворяющих шаблону
objects := $(wildcard $(addsuffix /*.c*, $(root_source_dir)))
$(info objects: $(objects))

# Упрощённый синтаксис patsubst: $(VAR:SUFFIX=REPLACEMENT)
# В переменной с именами исходников расширения .cpp заменяется на .o.
objects := $(objects:.cpp=.o)
$(info objects: $(objects))

# В переменной с именами исходников расширения .c заменяется на .o.
objects :=$(objects:.c=.o)
$(info objects: $(objects))

# Проверить содержание любой переменной:
# $(info root_source_dir: $(root_include_dir))

# PHONY-фиктивный, чтобы утилита make  не искала файлы с именем all и clean
.PHONY: all clean

# Первое объявленное правило – его цель становится целью всего проекта.
# Зависимостью является константа, содержащая имя программы
# Так сделано для использования $@(all)
all: $(APPNAME)

# Описание ключевой цели. Зависимоcти: наличие созданого подкаталога project/obj,
# повторяющего структуру каталога project и множество объектных файлов в нём.
# Описано действие по компоновке объектных файлов в целевой.
# $@ is the name of the target being generated, $< the first prerequisite (usually a source file).
# example:
# all: library.cpp main.cpp
# $@ evaluates to all
# $< evaluates to library.cpp
# $^ evaluates to library.cpp main.cpp
# see https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables
$(APPNAME): obj_dir $(objects)
#	clear
#	$(CC) -o $@ $(objects)
#	$(CC) -o $@ main.cpp
	$(CC) -o $@ $(objects) $(LDFLAGS) $(LIBS)

obj_dir:
	mkdir -p $(objects_dir)

VPATH := $(CURDIR)

%.o : %.cpp
	$(CC) -o $@ -c $< $(CPPFLAGS) -pipe $(addprefix -I, $(root_include_dirs))

#%.o : %.c
#	$(CC) -o $@ -c $< $(CPPFLAGS) $(addprefix -I, $(root_include_dirs))

clean:
	rm -rf $(APPNAME) *.o -d $(objects_dir)

# install:
# 			install ./hello /usr/local/bin
# uninstall:
# 			rm -rf /usr/local/bin/hello
