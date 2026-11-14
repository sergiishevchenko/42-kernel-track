// SPDX-License-Identifier: GPL-2.0
#include <linux/hid.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/usb.h>

static const struct usb_device_id main_id_table[] = {
	{ USB_INTERFACE_INFO(USB_INTERFACE_CLASS_HID,
			     USB_INTERFACE_SUBCLASS_BOOT,
			     USB_INTERFACE_PROTOCOL_KEYBOARD) },
	{ }
};
MODULE_DEVICE_TABLE(usb, main_id_table);

static int __init main_init(void)
{
	pr_info("Hello world!\n");
	return 0;
}

static void __exit main_exit(void)
{
	pr_info("Cleaning up module.\n");
}

module_init(main_init);
module_exit(main_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sshevche");
MODULE_DESCRIPTION("Hello world module loaded on USB keyboard hotplug");
