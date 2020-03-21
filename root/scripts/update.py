#!/usr/bin/env python

import os
import sys
import logging
import configparser
import xml.etree.ElementTree as ET

xml = "/config/config.xml"
autoProcess = os.path.join(os.environ.get("SMA_PATH", "/usr/local/sma"), "config/autoProcess.ini")


def main():
    if not os.path.isfile(xml):
        logging.error("No Sonarr/Radarr config file found")
        sys.exit(1)

    if not os.path.isfile(autoProcess):
        logging.error("autoProcess.ini does not exist")
        sys.exit(1)

    tree = ET.parse(xml)
    root = tree.getroot()
    port = root.find("Port").text
    try:
        sslport = root.find("SslPort").text
    except:
        sslport = port
    webroot = root.find("UrlBase").text
    webroot = webroot if webroot else ""
    ssl = root.find("EnableSsl").text
    ssl = ssl.lower() in ["true", "yes", "t", "1", "y"] if ssl else False
    apikey = root.find("ApiKey").text
    section = "Sonarr"
    if not section:
        logging.error("No Sonarr/Radarr specifying ENV variable")
        sys.exit(1)

    safeConfigParser = configparser.ConfigParser()
    safeConfigParser.read(autoProcess)

    # Set FFMPEG/FFProbe Paths
    safeConfigParser.set("Converter", "ffmpeg", "ffmpeg")
    safeConfigParser.set("Converter", "ffprobe", "ffprobe")
    safeConfigParser.set("Converter", "sort-streams", os.environ.get("SORT_STREAMS"))
    safeConfigParser.set("Converter", "process-same-extensions", "False")
    safeConfigParser.set("Converter", "force-convert", "False")
    safeConfigParser.set("Converter", "postopts", "-level,41,-maxrate,10000k")
    
    # Set Metadata Settings
    safeConfigParser.set("Metadata", "relocate-moov", "True")
    safeConfigParser.set("Metadata", "tag", "True")
    safeConfigParser.set("Metadata", "tag-language", "eng")
    safeConfigParser.set("Metadata", "download-artwork", "thumb")
    
    # Set Video Settings
    safeConfigParser.set("Video", "codec", "h264vaapi, h264, x264, avc")
    safeConfigParser.set("Video", "bitrate", "0")
    safeConfigParser.set("Video", "crf", "-1")
    safeConfigParser.set("Video", "crf-profiles", "")
    safeConfigParser.set("Video", "profile", "")
    safeConfigParser.set("Video", "max-level", "4.1")
    safeConfigParser.set("Video", "pix-fmt", "")
    
    # Set Audio Settings
    safeConfigParser.set("Audio", "codec", "libfdk_aac, aac")
    safeConfigParser.set("Audio", "languages", "eng")
    safeConfigParser.set("Audio", "default-language", "eng")
    safeConfigParser.set("Audio", "channel-bitrate", "80")
    safeConfigParser.set("Audio", "max-channels", "0")
    safeConfigParser.set("Audio", "prefer-more-channels", "True")
    safeConfigParser.set("Audio", "copy-original", "True")
    safeConfigParser.set("Audio", "first-track-of-language", "True")
    safeConfigParser.set("Audio", "max-bitrate", "0")
    safeConfigParser.set("Audio", "default-more-channels", "True")
        
    # Set Universal Audio Settings
    safeConfigParser.set("Universal Audio", "codec", "libfdk_aac")
    safeConfigParser.set("Universal Audio", "channel-bitrate", "128")
    safeConfigParser.set("Universal Audio", "first-track-only", "False")
    safeConfigParser.set("Universal Audio", "move-last", "False")
    safeConfigParser.set("Universal Audio", "first-stream-only", "False")
    safeConfigParser.set("Universal Audio", "move-after", "False")
    
    # Set Subtitle Settings
    safeConfigParser.set("Subtitle", "codec", "mov_text")
    safeConfigParser.set("Subtitle", "codec-image-based", "")
    safeConfigParser.set("Subtitle", "languages", "eng")
    safeConfigParser.set("Subtitle", "default-language", "eng")
    safeConfigParser.set("Subtitle", "encoding", "")
    safeConfigParser.set("Subtitle", "burn-subtitles", "forced")
    safeConfigParser.set("Subtitle", "embed-subs", "True")
    safeConfigParser.set("Subtitle", "first-stream-of-languag", "True")
    
    # Set values from config.xml
    safeConfigParser.set(section, "apikey", apikey)
    safeConfigParser.set(section, "ssl", str(ssl))
    safeConfigParser.set(section, "port", sslport if ssl else port)
    safeConfigParser.set(section, "webroot", webroot)

    # Set IP from environment variable
    ip = os.environ.get("HOST")
    if ip:
        safeConfigParser.set(section, "host", ip)
    else:
        safeConfigParser.set(section, "host", "127.0.0.1")

    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()


if __name__ == '__main__':
    main()