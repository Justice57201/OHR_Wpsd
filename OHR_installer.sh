#!/bin/bash
#
# WPSD GitHub Installer
# By WRQC343 - Outlaw Ham Radio
#

set -e

VERSION="1.2.0"
BASE_URL="https://raw.githubusercontent.com/Justice57201/OHR_Wpsd/main"

echo "========================++++=============="
echo " Outlaw Ham Radio WPSD Installer Starting"
echo "============================++++=========="

TMP_DIR="/tmp/wpsd_install"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

rm -f /usr/local/etc/DCS_Hosts.txt \
      /usr/local/etc/DExtra_Hosts.txt \
      /usr/local/etc/DPlus_Hosts.txt \
      /usr/local/etc/M17Hosts.txt \
      /usr/local/etc/YSFHosts.txt \
      /usr/local/etc/FCSHosts.txt \
      /usr/local/etc/XLXHosts.txt \
      /usr/local/etc/TGList_BM.txt \
      /usr/local/etc/TGList_YSF.txt

echo "[2/5] Downloading files from GitHub..."

curl -fsSL "$BASE_URL/HostFilesUpdate.sh" -o HostFilesUpdate.sh || { echo "Download failed: HostFilesUpdate.sh"; exit 1; }
curl -fsSL "$BASE_URL/hostfilesupdate.service" -o hostfilesupdate.service || { echo "Download failed: hostfilesupdate.service"; exit 1; }
curl -fsSL "$BASE_URL/appearance.php" -o appearance.php || { echo "Download failed: appearance.php"; exit 1; }
curl -fsSL "$BASE_URL/last_heard_table.php" -o last_heard_table.php || { echo "Download failed: last_heard_table.php"; exit 1; }
curl -fsSL "$BASE_URL/live_caller_backend.php" -o live_caller_backend.php || { echo "Download failed: live_caller_backend.php"; exit 1; }
curl -fsSL "$BASE_URL/caller_details_table.php" -o caller_details_table.php || { echo "Download failed: caller_details_table.php"; exit 1; }
curl -fsSL "$BASE_URL/local_tx_table.php" -o local_tx_table.php || { echo "Download failed: local_tx_table.php"; exit 1; }
curl -fsSL "$BASE_URL/index.php" -o index.php || { echo "Download failed: index.php"; exit 1; }
curl -fsSL "$BASE_URL/ohr.png" -o ohr.png || { echo "Download failed: ohr.png"; exit 1; }
curl -fsSL "$BASE_URL/favicon.ico" -o favicon.ico || { echo "Download failed: favicon.ico"; exit 1; }

echo "[3/5] Installing files..."

mv HostFilesUpdate.sh /usr/local/sbin/
chmod 755 /usr/local/sbin/HostFilesUpdate.sh

mv hostfilesupdate.service /etc/systemd/system/hostfilesupdate.service
chmod 644 /etc/systemd/system/hostfilesupdate.service

mv appearance.php /var/www/dashboard/admin/appearance.php
mv last_heard_table.php /var/www/dashboard/mmdvmhost/last_heard_table.php
mv live_caller_backend.php /var/www/dashboard/mmdvmhost/live_caller_backend.php
mv caller_details_table.php /var/www/dashboard/mmdvmhost/caller_details_table.php
mv local_tx_table.php /var/www/dashboard/mmdvmhost/local_tx_table.php
mv index.php /var/www/dashboard/index.php
mv ohr.png /var/www/dashboard/images/ohr.png
mv favicon.ico /var/www/dashboard/images/favicon.ico

chmod 644 /var/www/dashboard/admin/appearance.php
chmod 644 /var/www/dashboard/mmdvmhost/last_heard_table.php
chmod 644 /var/www/dashboard/mmdvmhost/live_caller_backend.php
chmod 644 /var/www/dashboard/mmdvmhost/caller_details_table.php
chmod 644 /var/www/dashboard/mmdvmhost/local_tx_table.php
chmod 644 /var/www/dashboard/index.php
chmod 644 /var/www/dashboard/images/ohr.png
chmod 644 /var/www/dashboard/images/favicon.ico

if [ -f /etc/systemd/system/wpsd-nightly-tasks.service ]; then
    mv /etc/systemd/system/wpsd-nightly-tasks.service \
       /etc/systemd/system/wpsd-nightly-tasks.service.old
fi

if [ -f /etc/systemd/system/wpsd-nightly-tasks.timer ]; then
    mv /etc/systemd/system/wpsd-nightly-tasks.timer \
       /etc/systemd/system/wpsd-nightly-tasks.timer.old
fi

echo "[4/5] Setting up systemd service..."

systemctl daemon-reload
systemctl enable hostfilesupdate.service
systemctl restart hostfilesupdate.service

rm -f /usr/local/etc/nextionUsers.csv
rm -f /usr/local/etc/nextionGroups.csv

echo "[5/5] Cleaning up..."
cd /
rm -rf "$TMP_DIR"

echo "[7/7] Running HostFilesUpdate.sh..."
if [ -f /usr/local/sbin/HostFilesUpdate.sh ]; then
    /usr/local/sbin/HostFilesUpdate.sh
else
    echo "ERROR: HostFilesUpdate.sh not found!"
    exit 1
fi

echo "======================================"
echo " Outlaw Ham Radio Install Complete!"
echo "======================================"
