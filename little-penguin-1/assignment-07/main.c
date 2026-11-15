// SPDX-License-Identifier: GPL-2.0
#include <linux/debugfs.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/jiffies.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/string.h>
#include <linux/uaccess.h>

#define LOGIN "sshevche"
#define LOGIN_LEN (sizeof(LOGIN) - 1)

static struct dentry *fortytwo_dir;
static char foo_buf[PAGE_SIZE];
static size_t foo_len;
static DEFINE_MUTEX(foo_lock);

static ssize_t id_read(struct file *file, char __user *buf,
		       size_t count, loff_t *ppos)
{
	return simple_read_from_buffer(buf, count, ppos, LOGIN, LOGIN_LEN);
}

static ssize_t id_write(struct file *file, const char __user *buf,
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

static ssize_t jiffies_read(struct file *file, char __user *buf,
			    size_t count, loff_t *ppos)
{
	char jbuf[32];
	int jlen;

	jlen = scnprintf(jbuf, sizeof(jbuf), "%lu\n", jiffies);
	return simple_read_from_buffer(buf, count, ppos, jbuf, jlen);
}

static ssize_t foo_read(struct file *file, char __user *buf,
			size_t count, loff_t *ppos)
{
	ssize_t ret;

	mutex_lock(&foo_lock);
	ret = simple_read_from_buffer(buf, count, ppos, foo_buf, foo_len);
	mutex_unlock(&foo_lock);
	return ret;
}

static ssize_t foo_write(struct file *file, const char __user *buf,
			 size_t count, loff_t *ppos)
{
	ssize_t ret;

	if (*ppos < 0 || *ppos + count > PAGE_SIZE)
		return -ENOSPC;
	mutex_lock(&foo_lock);
	ret = simple_write_to_buffer(foo_buf, PAGE_SIZE, ppos, buf, count);
	if (ret > 0)
		foo_len = *ppos;
	mutex_unlock(&foo_lock);
	return ret;
}

static const struct file_operations id_fops = {
	.owner = THIS_MODULE,
	.read = id_read,
	.write = id_write,
};

static const struct file_operations jiffies_fops = {
	.owner = THIS_MODULE,
	.read = jiffies_read,
};

static const struct file_operations foo_fops = {
	.owner = THIS_MODULE,
	.read = foo_read,
	.write = foo_write,
};

static int __init fortytwo_debugfs_init(void)
{
	fortytwo_dir = debugfs_create_dir("fortytwo", NULL);
	if (IS_ERR(fortytwo_dir))
		return PTR_ERR(fortytwo_dir);

	debugfs_create_file("id", 0666, fortytwo_dir, NULL, &id_fops);
	debugfs_create_file("jiffies", 0444, fortytwo_dir, NULL, &jiffies_fops);
	debugfs_create_file("foo", 0644, fortytwo_dir, NULL, &foo_fops);
	return 0;
}

static void __exit fortytwo_debugfs_exit(void)
{
	debugfs_remove_recursive(fortytwo_dir);
}

module_init(fortytwo_debugfs_init);
module_exit(fortytwo_debugfs_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sshevche");
MODULE_DESCRIPTION("Debugfs fortytwo directory");
