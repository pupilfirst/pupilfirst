#!/bin/sh
if [ ! -d "/opt/qt53" ]; then
  yes y | sudo add-apt-repository ppa:beineri/opt-qt532
  sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/beineri-opt-qt532-precise.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  sudo apt-get install qt53webkit libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev qt53declarative qt53location qt53sensors
fi

echo "source /opt/qt53/bin/qt53-env.sh" >> ~/.circlerc
