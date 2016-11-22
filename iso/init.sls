{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

install-packages:
  pkg.installed:
    - name: xubuntu-core^
    - name: conky
    - name: vim

create-interface-master:
  file.copy:
    - src: /etc/network/interfaces
    - dst: /etc/network/interfaces.virl

/home/virl/.conkyrc:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
        update_interval 5
        total_run_times 0
        net_avg_samples 1
        cpu_avg_samples 1
        imlib_cache_size 0
        double_buffer yes
        no_buffers yes
        use_xft yes
        xftfont Ubuntu:size=14
        override_utf8_locale yes
        text_buffer_size 2048
        own_window_class Conky
        own_window yes 
        own_window_type desktop
        own_window_transparent yes
        own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
        own_window_argb_visual yes
        alignment top_right
        gap_x 2 
        gap_y 60 
        minimum_size 190 180
        default_bar_size 60 8
        draw_shades no
        default_color efefef
        default_shade_color 1d1d1d
        color0 ffffff
        color1 ffffff
        color2 ffffff
        TEXT
        RAM ${memperc}% ${membar memperc}
        CPU ${cpu cpu0}% ${cpubar cpu0} 
        IP  ${addr eth0}

/home/virl/.config/autostart/conky.desktop:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Encoding=UTF-8
        Version=0.9.4
        Type=Application
        Name=Conky
        Comment=Conky
        Exec=conky
        OnlyShowIn=XFCE;
        StartupNotify=false
        Terminal=false
        Hidden=false

/home/virl/.config/autostart/light-locker.desktop:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Hidden=false

/home/virl/Desktop/exo-terminal-emulator.desktop:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Version=1.0
        Type=Application
        Exec=exo-open --launch TerminalEmulator
        Icon=utilities-terminal
        StartupNotify=true
        Terminal=false
        Categories=Utility;X-XFCE;X-Xfce-Toplevel;
        OnlyShowIn=XFCE;
        Name=Terminal Emulator
        Comment=Use the command line   

/home/distroshare/rootfs/home/virl/Desktop/ubiquity.desktop: 
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=Install 
        Comment=Install this system permanently to your hard disk
        Keywords=ubiquity;
        Exec=sh -c 'ubiquity gtk_ui'
        Icon=ubiquity
        Terminal=false
        Categories=GTK;System;Settings;
        NotShowIn=KDE;
        X-Ayatana-Appmenu-Show-Stubs=False

/usr/local/bin/virl-iso-cleanup:
  file.managed:
    - user: root
    - group: root
    - makedirs: True
    - mode: 755
    - source: salt://iso/files/virl-iso-cleanup
    - skip-verify: True

/etc/systemd/system/virl-iso-cleanup.service:
  file.managed:
    - user: root
    - group: root
    - makedirs: True
    - contents: |
        [Unit]
        Description="Install the VIRL golden interfaces file, cleanup after ISO install"
        Before=network.target
        [Service]
        Type=simple
        ExecStart=/usr/local/bin/virl-iso-cleanup
        [Install]
        WantedBy=multi-user.target

install-virl-iso-cleanup:
  cmd.run:
    - name: 'systemctl enable virl-iso-cleanup'

git-clone-distroshare:
  git.clone:
    - cwd: /home/virl/
    - url: https://github.com/Distroshare/distroshare-ubuntu-imager.git

/home/virl/distroshare/distroshare-ubuntu-imager.sh
  file.managed:
    - user: virl
    - group: virl
    - source: salt://iso/files/distroshare-ubuntu-imager.sh
    - mode: 777
    - skip-verify: True

/home/virl/distroshare/distroshare-ubuntu-imager.config
  file.managed:
    - user: virl
    - group: virl
    - source: salt://iso/files/distroshare-ubuntu-imager.config
    - mode: 777
    - skip-verify: True

create-iso:
  cmd.run:
    -cwd: /home/virl/distroshare-ubuntu-imager/
    -name: '/home/virl/distroshare-ubuntu-imager.sh'


