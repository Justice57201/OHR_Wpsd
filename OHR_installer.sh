#!/bin/bash
#
# WPSD GitHub Installer (Enhanced Progress UI)
# By WRQC343 - Outlaw Ham Radio
#

set -e

BASE_URL="https://raw.githubusercontent.com/Justice57201/OHR_Wpsd/main"
TMP_DIR="/tmp/wpsd_install"

# ---------------------------
# COLORS
# ---------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[+]${NC} $1"; }
ok()  { echo -e "${GREEN}[OK]${NC} $1"; }
err() { echo -e "${RED}[X]${NC} $1"; }

# ---------------------------
# HEADER
# ---------------------------
clear
echo -e "${GREEN}"
echo "=============================================="
echo "   Outlaw Ham Radio - WPSD Installer"
echo "   Enhanced Progress Edition"
echo "=============================================="
echo -e "${NC}"

# ---------------------------
# PREP
# ---------------------------
log "Preparing environment..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1
ok "Temp directory ready"

# ---------------------------
# DOWNLOAD FUNCTION (REAL PROGRESS BAR)
# ---------------------------
download() {
    local url=$1
    local out=$2

    echo -e "${YELLOW}Downloading:${NC} $(basename "$out")"

    curl -fSL --progress-bar "$url" -o "$out" \
        || { err "Failed download: $(basename "$out")"; exit 1; }

    ok "$(basename "$out") downloaded"
}

# ---------------------------
# STEP 2 - DOWNLOAD FILES
# ---------------------------
echo -e "\n${BLUE}[ STEP 2/7 ] Downloading Files ${NC}\n"

download "$BASE_URL/HostFilesUpdate.sh" HostFilesUpdate.sh
download "$BASE_URL/hostfilesupdate.service" hostfilesupdate.service
download "$BASE_URL/appearance.php" appearance.php
download "$BASE_URL/last_heard_table.php" last_heard_table.php
download "$BASE_URL/live_caller_backend.php" live_caller_backend.php
download "$BASE_URL/caller_details_table.php" caller_details_table.php
download "$BASE_URL/local_tx_table.php" local_tx_table.php
download "$BASE_URL/index.php" index.php
download "$BASE_URL/ohr.png" ohr.png
download "$BASE_URL/favicon.ico" favicon.ico

# ---------------------------
# STEP 3 - INSTALL FILES
# ---------------------------
echo -e "\n${BLUE}[ STEP 3/7 ] Installing Files ${NC}\n"

mv HostFilesUpdate.sh /usr/local/sbin/
chmod 755 /usr/local/sbin/HostFilesUpdate.sh
ok "Installed HostFilesUpdate.sh"

mv hostfilesupdate.service /etc/systemd/system/hostfilesupdate.service
chmod 644 /etc/systemd/system/hostfilesupdate.service
ok "Installed systemd service"

mv appearance.php /var/www/dashboard/admin/appearance.php
mv last_heard_table.php /var/www/dashboard/mmdvmhost/last_heard_table.php
mv live_caller_backend.php /var/www/dashboard/mmdvmhost/live_caller_backend.php
mv caller_details_table.php /var/www/dashboard/mmdvmhost/caller_details_table.php
mv local_tx_table.php /var/www/dashboard/mmdvmhost/local_tx_table.php
mv index.php /var/www/dashboard/index.php
mv ohr.png /var/www/dashboard/images/ohr.png
mv favicon.ico /var/www/dashboard/images/favicon.ico

chmod 644 /var/www/dashboard/admin/appearance.php
chmod 644 /var/www/dashboard/mmdvmhost/*.php
chmod 644 /var/www/dashboard/index.php
chmod 644 /var/www/dashboard/images/*
ok "Web dashboard files installed"

# ---------------------------
# STEP 4 - RENAME OLD SERVICES
# ---------------------------
echo -e "\n${BLUE}[ STEP 4/7 ] Cleaning Old Services ${NC}\n"

if [ -f /etc/systemd/system/wpsd-nightly-tasks.service ]; then
    mv /etc/systemd/system/wpsd-nightly-tasks.service \
       /etc/systemd/system/wpsd-nightly-tasks.service.old
    ok "Renamed nightly service"
fi

if [ -f /etc/systemd/system/wpsd-nightly-tasks.timer ]; then
    mv /etc/systemd/system/wpsd-nightly-tasks.timer \
       /etc/systemd/system/wpsd-nightly-tasks.timer.old
    ok "Renamed nightly timer"
fi

# ---------------------------
# STEP 5 - SYSTEMD
# ---------------------------
echo -e "\n${BLUE}[ STEP 5/7 ] Systemd Setup ${NC}\n"

systemctl daemon-reload
systemctl enable hostfilesupdate.service
systemctl restart hostfilesupdate.service
ok "Systemd service enabled & restarted"

# ---------------------------
# CLEAN OLD FILES
# ---------------------------
rm -f /usr/local/etc/nextionUsers.csv
rm -f /usr/local/etc/nextionGroups.csv
ok "Cleaned old CSV files"

# ---------------------------
# STEP 6 - CLEANUP
# ---------------------------
echo -e "\n${BLUE}[ STEP 6/7 ] Cleanup ${NC}\n"

cd /
rm -rf "$TMP_DIR"
ok "Temporary files removed"

# ---------------------------
# STEP 7 - RUN UPDATE SCRIPT
# ---------------------------
echo -e "\n${BLUE}[ STEP 7/7 ] Running HostFilesUpdate ${NC}\n"

if [ -f /usr/local/sbin/HostFilesUpdate.sh ]; then
    /usr/local/sbin/HostFilesUpdate.sh
    ok "HostFilesUpdate completed"
else
    err "HostFilesUpdate.sh not found!"
    exit 1
fi

# ---------------------------
# FINISH
# ---------------------------
echo -e "\n${GREEN}"
echo "======================================"
echo "   INSTALL COMPLETE SUCCESS"
echo "======================================"
echo -e "${NC}"
echo " Outlaw Ham Radio Install Complete!"
echo "======================================"
