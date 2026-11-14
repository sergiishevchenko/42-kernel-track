# SPDX-License-Identifier: GPL-2.0
obj-m += main.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean

install: all
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules_install
	depmod -a

install-udev:
	install -m 644 99-keyboard.rules /etc/udev/rules.d/99-keyboard.rules
	udevadm control --reload-rules

.PHONY: all clean install install-udev
