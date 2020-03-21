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
    safeConfigParser.set("Converter", "threads", os.environ.get("CONVERTER_THREADS"))
    safeConfigParser.set("Converter", "output-format", os.environ.get("CONVERTER_OUTPUT_FORMAT"))
    safeConfigParser.set("Converter", "output-extension", os.environ.get("CONVERTER_OUTPUT_EXTENSION"))
    safeConfigParser.set("Converter", "sort-streams", os.environ.get("CONVERTER_SORT_STREAMS"))
    safeConfigParser.set("Converter", "process-same-extensions", os.environ.get("CONVERTER_PROCESS_SAME_EXTENSIONS"))
    safeConfigParser.set("Converter", "force-convert", os.environ.get("CONVERTER_FORCE_CONVERT"))
    safeConfigParser.set("Converter", "postopts", os.environ.get("CONVERTER_PREOPTS"))
    safeConfigParser.set("Converter", "postopts", os.environ.get("CONVERTER_POSTOPTS"))
    
    # SET Permissions
    safeConfigParser.set("Permissions", "chmod", os.environ.get("PERMISSIONS_CHMOD"))
    
    # Set Metadata Settings
    safeConfigParser.set("Metadata", "relocate-moov", os.environ.get("METADATA_RELOCATE_MOV"))
    safeConfigParser.set("Metadata", "tag", os.environ.get("METADATA_TAG"))
    safeConfigParser.set("Metadata", "tag-language", os.environ.get("METADATA_TAG_LANGUAGE"))
    safeConfigParser.set("Metadata", "download-artwork", os.environ.get("METADATA_DOWNLOAD_ARTWORK"))
    
    # Set Video Settings
    safeConfigParser.set("Video", "codec", os.environ.get("VIDEO_CODEC"))
    safeConfigParser.set("Video", "bitrate", os.environ.get("VIDEO_BITRATE"))
    safeConfigParser.set("Video", "crf", os.environ.get("VIDEO_CRF")
    safeConfigParser.set("Video", "crf-profiles", os.environ.get("VIDEO_CRF_PROFILES")
    safeConfigParser.set("Video", "max-width", os.environ.get("VIDEO_MAX_WIDTH")
    safeConfigParser.set("Video", "profile", os.environ.get("VIDEO_PROFILE")
    safeConfigParser.set("Video", "max-level", os.environ.get("VIDEO_MAX_LEVEL")
    safeConfigParser.set("Video", "pix-fmt", os.environ.get("VIDEO_PIX_FMT")
    
    # Set Audio Settings
    safeConfigParser.set("Audio", "codec", os.environ.get("AUDIO_CODEC")
    safeConfigParser.set("Audio", "languages", os.environ.get("AUDIO_LANGUAGES")
    safeConfigParser.set("Audio", "default-language", os.environ.get("AUDIO_DEFAULT_LANGUAGE")
    safeConfigParser.set("Audio", "first-stream-of-language", os.environ.get("AUDIO_FIRST_STREAM_OF_LANGUAGE")
    safeConfigParser.set("Audio", "channel-bitrate", os.environ.get("AUDIO_CHANNEL_BITRATE")
    safeConfigParser.set("Audio", "max-bitrate", os.environ.get("AUDIO_MAX_BITRATE")
    safeConfigParser.set("Audio", "max-channels", os.environ.get("AUDIO_MAX_CHANNELS")
    safeConfigParser.set("Audio", "prefer-more-channels", os.environ.get("AUDIO_PREFER_MORE_CHANNELS")
    safeConfigParser.set("Audio", "default-more-channels", os.environ.get("AUDIO_DEFAULT_MORE_CHANNELS")
    safeConfigParser.set("Audio", "copy-original", os.environ.get("AUDIO_COPY_ORIGINAL")
        
    # Set Universal Audio Settings
    safeConfigParser.set("Universal Audio", "codec", os.environ.get("UAUDIO_CODEC")
    safeConfigParser.set("Universal Audio", "channel-bitrate", os.environ.get("UAUDIO_CHANNEL_BITRATE")
    safeConfigParser.set("Universal Audio", "first-stream-only", os.environ.get("UAUDIO_FIRST_STREAM_ONLY")
    safeConfigParser.set("Universal Audio", "move-after", os.environ.get("UAUDIO_MOVE_AFTER")
    safeConfigParser.set("Universal Audio", "filter", os.environ.get("UAUDIO_FILTER")
                         
    # Set Subtitle Settings
    safeConfigParser.set("Subtitle", "codec", os.environ.get("SUBTITLE_CODEC")
    safeConfigParser.set("Subtitle", "codec-image-based", os.environ.get("SUBTITLE_CODEC_IMAGE_BASED")
    safeConfigParser.set("Subtitle", "languages", os.environ.get("SUBTITLE_LANGUAGES")
    safeConfigParser.set("Subtitle", "default-language", os.environ.get("SUBTITLE_DEFAULT_LANGUAGE")
    safeConfigParser.set("Subtitle", "first-stream-of-languag", os.environ.get("SUBTITLE_FIRST_STREAM_OF_LANGUAGE")
    safeConfigParser.set("Subtitle", "encoding", os.environ.get("SUBTITLE_ENCODING")
    safeConfigParser.set("Subtitle", "burn-subtitles", os.environ.get("SUBTITLE_BURN_SUBTITLES")
    safeConfigParser.set("Subtitle", "embed-subs", os.environ.get("SUBTITLE_EMBED_SUBS")
    
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
