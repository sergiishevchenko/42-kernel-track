// SPDX-License-Identifier: GPL-2.0
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/string.h>
#include <linux/uaccess.h>

#define LOGIN "sshevche"
#define LOGIN_LEN (sizeof(LOGIN) - 1)

static ssize_t fortytwo_read(struct file *file, char __user *buf,
			     size_t count, loff_t *ppos)
{
	return simple_read_from_buffer(buf, count, ppos, LOGIN, LOGIN_LEN);
}

static ssize_t fortytwo_write(struct file *file, const char __user *buf,
			      size_t count, loff_t *ppos)
{
	char kbuf[LOGIN_LEN];

	if (count != LOGIN_LEN)
		return -EINVAL;
	if (copy_from_user(kbuf, buf, LOGIN_LEN))
		return -EFAULT;
	if (memcmp(kbuf, LOGIN, LOGIN_LEN))
		return -EINVAL;
	return count;
}

static const struct file_operations fortytwo_fops = {
	.owner = THIS_MODULE,
	.read = fortytwo_read,
	.write = fortytwo_write,
};

static struct miscdevice fortytwo_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "fortytwo",
	.fops = &fortytwo_fops,
	.mode = 0666,
};

static int __init fortytwo_init(void)
{
	return misc_register(&fortytwo_dev);
}

static void __exit fortytwo_exit(void)
{
	misc_deregister(&fortytwo_dev);
}

module_init(fortytwo_init);
module_exit(fortytwo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sshevche");
MODULE_DESCRIPTION("Misc device fortytwo");
