// SPDX-License-Identifier: GPL-2.0
#include <linux/dcache.h>
#include <linux/err.h>
#include <linux/fs_struct.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/limits.h>
#include <linux/module.h>
#include <linux/path.h>
#include <linux/proc_fs.h>
#include <linux/rcupdate.h>
#include <linux/sched.h>
#include <linux/seq_file.h>
#include <linux/slab.h>

#include "fs/mount.h"

static struct proc_dir_entry *mymounts_entry;

/**
 * mymounts_next - pre-order successor in the mount tree
 * @p: current mount
 * @root: mount the walk started from
 *
 * Return: next mount, or NULL when the walk is over or @p was detached
 * concurrently (its self-linked list heads would otherwise loop forever).
 */
static struct mount *mymounts_next(struct mount *p, struct mount *root)
{
	struct list_head *next = p->mnt_mounts.next;

	if (next != &p->mnt_mounts)
		return list_entry(next, struct mount, mnt_child);
	while (p != root) {
		next = p->mnt_child.next;
		if (next == &p->mnt_child || !mnt_has_parent(p))
			return NULL;
		if (next != &p->mnt_parent->mnt_mounts)
			return list_entry(next, struct mount, mnt_child);
		p = p->mnt_parent;
	}
	return NULL;
}

static void mymounts_print(struct seq_file *m, struct mount *mnt,
			   struct mount *root, char *buf)
{
	struct path path = {
		.mnt = &mnt->mnt,
		.dentry = mnt->mnt.mnt_root,
	};
	char *mountpoint;

	mountpoint = d_path(&path, buf, PATH_MAX);
	if (IS_ERR(mountpoint))
		return;
	if (mnt == root)
		seq_printf(m, "root %s\n", mountpoint);
	else
		seq_printf(m, "%pd %s\n", mnt->mnt_mountpoint, mountpoint);
}

static int mymounts_show(struct seq_file *m, void *v)
{
	struct path fs_root;
	struct mount *root;
	struct mount *mnt;
	char *buf;

	buf = kmalloc(PATH_MAX, GFP_KERNEL);
	if (!buf)
		return -ENOMEM;

	get_fs_root(current->fs, &fs_root);
	root = real_mount(fs_root.mnt);

	rcu_read_lock();
	for (mnt = root; mnt; mnt = mymounts_next(mnt, root))
		mymounts_print(m, mnt, root, buf);
	rcu_read_unlock();

	path_put(&fs_root);
	kfree(buf);
	return 0;
}

static int __init mymounts_init(void)
{
	mymounts_entry = proc_create_single("mymounts", 0444, NULL,
					    mymounts_show);
	if (!mymounts_entry)
		return -ENOMEM;
	return 0;
}

static void __exit mymounts_exit(void)
{
	proc_remove(mymounts_entry);
}

module_init(mymounts_init);
module_exit(mymounts_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sshevche");
MODULE_DESCRIPTION("List mount points in /proc/mymounts");
