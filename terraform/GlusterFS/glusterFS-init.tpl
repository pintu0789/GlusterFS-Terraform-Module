yum_repos:
    glusterfs:
        baseurl: http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/glusterfs-epel.repo
        enabled:true
        failovermethod: priority
        gpgcheck: true
        gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
        name: GlusterFS package repo.
bootcmd:
    - [ cloud-init-per, once, mkfs.xfs, -i, size=512, /dev/sdb ]
    - [ cloud-init-per, once, mkdir, -p, /data/brick1 ]
    - echo '/dev/sdb1 /data/brick1 xfs defaults 1 2' >> /etc/fstab
    - [ cloud-init-per, always, mount, -a]
    - [ cloud-init-per, always, mount]

runcmd:
    - [ yum, install, -y, "glusterfs{-fuse,-server}" ]
    - [ chkconfig, glusterd, on ]
    - [ ]