#!/bin/bash

# this script install Nipe.nl

cd /opt
git clone https://github.com/GouveaHeitor/nipe.git
cd nipe
chmod +x setup.sh && ./setup.sh

PATH="$PATH:/opt/nipe"
echo "alias nipe='perl nipe.pl'" >> /home/$(whoami)/.bashrc
