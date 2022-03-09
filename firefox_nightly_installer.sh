#!/bin/bash
# Get lastes versiom
ny_last_version=$(wget -O - https://archive.mozilla.org/pub/firefox/nightly/latest-mozilla-central/ -q | grep firefox- | head -n 1 | sed 's/^.*\(>.*a\).*$/\1/' | sed s'/[.].*$//g' | sed 's/[^0-9]//g');
# Untar directly from stdout
wget -qO- https://archive.mozilla.org/pub/firefox/nightly/latest-mozilla-central/firefox-"$ny_last_version".0a1.en-US.linux-"$(uname -m)".tar.bz2 | tar xjf - -C /opt/;
# Create symlink
ln -s /opt/firefox/firefox /usr/local/bin/firefox-nightly
