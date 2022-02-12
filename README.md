# docker-qbittorrent

### How to run

	docker run -d --restart always \
	  -p 127.0.0.1:9091:9091 -p 51413:51413 -p 51413:51413/udp \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /data/qbittorrent/watch:/watch \
	  -v /data/qbittorrent/downloads:/downloads \
	  --name qbittorrent qbittorrent

#### or

	curl -L "https://raw.githubusercontent.com/TonySamaaaa/docker-qbittorrent/master/config/qBittorrent.conf" \
	  -o /data/docker/qbittorrent/qBittorrent.conf
	curl -L "https://raw.githubusercontent.com/TonySamaaaa/docker-qbittorrent/main/config/watched_folders.json" \
	  -o /data/docker/qbittorrent/watched_folders.json
	docker run -d --restart always \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /data/docker/qbittorrent:/qBittorrent/config \
	  -v /data/qbittorrent/watch:/watch \
	  -v /data/qbittorrent/downloads:/downloads \
	  --network host --name qbittorrent qbittorrent
