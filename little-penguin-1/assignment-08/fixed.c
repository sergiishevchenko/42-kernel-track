// SPDX-License-Identifier: GPL-2.0
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Louis Solofrizzo <louis@ne02ptzero.me>");
MODULE_DESCRIPTION("Useless module");

static char str[PAGE_SIZE];
static size_t str_len;
static DEFINE_MUTEX(str_lock);

static ssize_t myfd_read(struct file *fp, char __user *user,
			 size_t size, loff_t *offs)
{
	char *tmp;
	size_t len;
	size_t i;
	ssize_t ret;

	tmp = kmalloc(PAGE_SIZE, GFP_KERNEL);
	if (!tmp)
		return -ENOMEM;

	mutex_lock(&str_lock);
	len = str_len;
	for (i = 0; i < len; i++)
		tmp[i] = str[len - 1 - i];
	mutex_unlock(&str_lock);

	ret = simple_read_from_buffer(user, size, offs, tmp, len);
	kfree(tmp);
	return ret;
}

static ssize_t myfd_write(struct file *fp, const char __user *user,
			  size_t size, loff_t *offs)
{
	ssize_t ret;

	if (*offs < 0 || *offs + size > PAGE_SIZE)
		return -ENOSPC;

	mutex_lock(&str_lock);
	ret = simple_write_to_buffer(str, PAGE_SIZE, offs, user, size);
	if (ret > 0)
		str_len = *offs;
	mutex_unlock(&str_lock);
	return ret;
}

static const struct file_operations myfd_fops = {
	.owner = THIS_MODULE,
	.read = myfd_read,
	.write = myfd_write,
};

static struct miscdevice myfd_device = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "reverse",
	.fops = &myfd_fops,
};

static int __init myfd_init(void)
{
	return misc_register(&myfd_device);
}

static void __exit myfd_cleanup(void)
{
	misc_deregister(&myfd_device);
}

module_init(myfd_init);
module_exit(myfd_cleanup);
