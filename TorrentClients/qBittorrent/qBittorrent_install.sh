function qBittorrent_download {
    version=4.1.9;
    wget https://raw.githubusercontent.com/codecopy/Seedbox/main/TorrentClients/qBittorrent/qBittorrent/qBittorrent%204.1.9%20-%20libtorrent-1_1_14/qbittorrent-nox && chmod +x $HOME/qbittorrent-nox;
}

function qBittorrent_install {
    normal_2
    ## Shut down qBittorrent if it has been already installed
    pgrep -i -f qbittorrent && pkill -s $(pgrep -i -f qbittorrent)
    test -e /usr/bin/qbittorrent-nox && rm /usr/bin/qbittorrent-nox
    mv $HOME/qbittorrent-nox /usr/bin/qbittorrent-nox
    ## Creating systemd services
    test -e /etc/systemd/system/qbittorrent-nox@.service && rm /etc/systemd/system/qbittorrent-nox@.service
    touch /etc/systemd/system/qbittorrent-nox@.service
    cat << EOF >/etc/systemd/system/qbittorrent-nox@.service
[Unit]
Description=qBittorrent
After=network.target

[Service]
Type=forking
User=$username
LimitNOFILE=infinity
ExecStart=/usr/bin/qbittorrent-nox -d
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/qbittorrent-nox
Restart=on-failure
TimeoutStopSec=20
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    mkdir -p /home/$username/qbittorrent/Downloads && chown $username /home/$username/qbittorrent/Downloads
    mkdir -p /home/$username/.config/qBittorrent && chown $username /home/$username/.config/qBittorrent
    systemctl enable qbittorrent-nox@$username
    systemctl start qbittorrent-nox@$username
}

function qBittorrent_config {
    systemctl stop qbittorrent-nox@$username
    if [[ "${version}" =~ "4.1." ]]; then
        md5password=$(echo -n $password | md5sum | awk '{print $1}')
        cat << EOF >/home/$username/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=45000
Downloads\DiskWriteCacheSize=$Cache2
Downloads\SavePath=/home/$username/qbittorrent/Downloads/
General\Locale=zh
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=8080
WebUI\Username=$username
EOF
    elif [[ "${version}" =~ "4.2."|"4.3."|"4.4." ]]; then
        wget  https://raw.githubusercontent.com/codecopy/Seedbox/main/TorrentClients/qBittorrent/qb_password_gen && chmod +x $HOME/qb_password_gen
        PBKDF2password=$($HOME/qb_password_gen $password)
        cat << EOF >/home/$username/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true

[Network]+
Cookies=@Invalid()

[Preferences]
Connection\PortRangeMin=45000
Downloads\DiskWriteCacheSize=$Cache2
Downloads\SavePath=/home/$username/qbittorrent/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=8080
WebUI\Username=$username
EOF
    rm qb_password_gen
    fi
    systemctl start qbittorrent-nox@$username
}