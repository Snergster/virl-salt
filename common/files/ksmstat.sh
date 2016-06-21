#!/bin/bash

if [ "$1" != "" ]; then


echo "
----------------------------------------------------------------------------
http://www.kernel.org/doc/Documentation/vm/ksm.txt :
The effectiveness of KSM and MADV_MERGEABLE is shown in /sys/kernel/mm/ksm/:
pages_shared     - how many shared pages are being used
pages_sharing    - how many more sites are sharing them i.e. how much saved
pages_unshared   - how many pages unique but repeatedly checked for merging
pages_volatile   - how many pages changing too fast to be placed in a tree
full_scans       - how many times all mergeable areas have been scanned
A high ratio of pages_sharing to pages_shared indicates good sharing, but
a high ratio of pages_unshared to pages_sharing indicates wasted effort.
pages_volatile embraces several different kinds of activity, but a high
proportion there would also indicate poor use of madvise MADV_MERGEABLE.
----------------------------------------------------------------------------
"
fi;


pages_shared=`cat /sys/kernel/mm/ksm/pages_shared`;
pages_sharing=`cat /sys/kernel/mm/ksm/pages_sharing`;
pages_unshared=`cat /sys/kernel/mm/ksm/pages_unshared`;
pages_volatile=`cat /sys/kernel/mm/ksm/pages_volatile`;
page_size=`getconf PAGESIZE`;

ratio_sharing_to_shared=$(echo "scale=2;$pages_sharing / $pages_shared"|bc);
ratio_unshared_to_sharing=$(echo "scale=2;$pages_unshared / $pages_sharing"|bc);
saved=$(echo "scale=0;$pages_sharing * $page_size"|bc);

saved=$(expr $saved / 1048576);

printf "Shared\tSharing\tUnshared\tVolatile\tSharing:Shared\tUnshared:Sharing\tSaved\n";
printf "%'d\t%'d\t%'d\t\t%'d\t\t%'f:1\t%'f:1\t\t%'dM\n" $pages_shared $pages_sharing $pages_unshared $pages_volatile $ratio_sharing_to_shared $ratio_unshared_to_sharing $saved;
