#!/bin/bash

KERN_V=`yum -C list "kernel-2.6*web100.i686"  |sort|grep web100|tail -1|awk '{print $2}'` 
KERN="/boot/vmlinuz-$KERN_V" 
if [[ -f "$KERN" && "$KERN" != `grubby --default-kernel` ]] ; then
	grubby --set-default={KERN}
fi