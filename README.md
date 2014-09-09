**************
iptv-playlists
**************

This repo contains a set of IPTV playlists.

Get started:
------------
1. Open ```general``` folder
2. Grab some m3u list 
3. Feed it to a media player of your favour
```bash
$ vlc ./general/ru.m3u8
```

Lists maintaining:
------------------
The folder ```util``` helps to check if streams are alive or not.

```bash
./check-streams.sh                          # checks all m3u-files
./check-streams.sh -f ../general/ru.m3u8    # check single file
```

Contribute:
-----------
Feel free to raise a pull request if you have some streams to share.
