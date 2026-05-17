#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for WPSD                                 #
#               By Justice                              #
#                                                       #
#               Version 1.1.0                           #
#                                                       #
#   			     								    #
#                                                       #
#########################################################

# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
	exit 0
fi

APRSHOSTS=/usr/local/etc/APRSHosts.txt
DCSHOSTS=/usr/local/etc/DCS_Hosts.txt
DExtraHOSTS=/usr/local/etc/DExtra_Hosts.txt
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
DPlusHOSTS=/usr/local/etc/DPlus_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
M17HOSTS=/usr/local/etc/M17Hosts.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
FCSHOSTS=/usr/local/etc/FCSHosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
NXDNIDFILE=/usr/local/etc/NXDN.csv
NXDNHOSTS=/usr/local/etc/NXDNHosts.txt
TGLISTBM=/usr/local/etc/TGList_BM.txt
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTNXDN=/usr/local/etc/TGList_NXDN.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt
NEXTIONGROUPS=/usr/local/etc/nextionGroups.txt
NEXTIONUSERS=/usr/local/etc/nextionUsers.csv
USERCSV=/usr/local/etc/user.csv

# How many backups
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ];then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
	cp ${APRSHOSTS} ${APRSHOSTS}.$(date +%Y%m%d)
	cp ${DCSHOSTS} ${DCSHOSTS}.$(date +%Y%m%d)
	cp ${DExtraHOSTS} ${DExtraHOSTS}.$(date +%Y%m%d)
	cp ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
	cp ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
	cp ${DPlusHOSTS} ${DPlusHOSTS}.$(date +%Y%m%d)
	cp ${P25HOSTS} ${P25HOSTS}.$(date +%Y%m%d)
	cp ${M17HOSTS} ${M17HOSTS}.$(date +%Y%m%d)
	cp ${YSFHOSTS} ${YSFHOSTS}.$(date +%Y%m%d)
	cp ${FCSHOSTS} ${FCSHOSTS}.$(date +%Y%m%d)
	cp ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
	cp ${NXDNIDFILE} ${NXDNIDFILE}.$(date +%Y%m%d)
	cp ${NXDNHOSTS} ${NXDNHOSTS}.$(date +%Y%m%d)
	cp ${TGLISTBM} ${TGLISTBM}.$(date +%Y%m%d)
	cp ${TGLISTP25} ${TGLISTP25}.$(date +%Y%m%d)
	cp ${TGLISTNXDN} ${TGLISTNXDN}.$(date +%Y%m%d)
	cp ${TGLISTYSF} ${TGLISTYSF}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DCSHOSTS}
${DExtraHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${DPlusHOSTS}
${P25HOSTS}
${M17HOSTS}
${YSFHOSTS}
${FCSHOSTS}
${XLXHOSTS}
${NXDNIDFILE}
${NXDNHOSTS}
${TGLISTBM}
${TGLISTP25}
${TGLISTNXDN}
${TGLISTYSF}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
	for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
	do
		rm $f
	done
  fi
done

# Generate Host Files
curl --fail -o ${APRSHOSTS} -s https://www.gmrs-link.com/ohr/mmdvm/APRS_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${DCSHOSTS} -s http://www.pistar.uk/downloads/DCS_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${DMRHOSTS} -s https://www.gmrs-link.com/ohr/mmdvm/DMR_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"

if [ -f /etc/hostfiles.nodextra ]; then
  curl --fail -o ${DPlusHOSTS} -s http://www.pistar.uk/downloads/DPlus_WithXRF_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
  curl --fail -o ${DExtraHOSTS} -s http://www.pistar.uk/downloads/DExtra_NoXRF_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
else
  curl --fail -o ${DPlusHOSTS} -s http://www.pistar.uk/downloads/DPlus_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
  curl --fail -o ${DExtraHOSTS} -s http://www.pistar.uk/downloads/DExtra_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
fi

curl -sSL https://www.gmrs-link.com/ohr/mmdvm/DMRIds.dat.gz --user-agent "Pi-Star_${pistarCurVersion}" | gunzip -c > ${DMRIDFILE}
curl --fail -o ${P25HOSTS} -s https://www.gmrs-link.com/ohr/mmdvm/P25_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${M17HOSTS} -s http://www.pistar.uk/downloads/M17_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${YSFHOSTS} -s http://www.pistar.uk/downloads/YSF_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${FCSHOSTS} -s http://www.pistar.uk/downloads/FCS_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${XLXHOSTS} -s http://www.pistar.uk/downloads/XLXHosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${NXDNIDFILE} -s https://www.gmrs-link.com/ohr/mmdvm/NXDN.csv --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${NXDNHOSTS} -s https://www.gmrs-link.com/ohr/mmdvm/NXDN_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"

curl --fail -o ${TGLISTBM} -s http://www.pistar.uk/downloads/TGList_BM.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${TGLISTP25} -s https://www.gmrs-link.com/ohr/mmdvm/TGList_P25.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${TGLISTNXDN} -s https://www.gmrs-link.com/ohr/mmdvm/TGList_NXDN.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${TGLISTYSF} -s http://www.pistar.uk/downloads/TGList_YSF.txt --user-agent "Pi-Star_${pistarCurVersion}"

# Download Nextion Groups
if [ -f ${NEXTIONGROUPS} ]; then
  if [[ $(find "${NEXTIONGROUPS}" -mtime +7) ]]; then
    curl --fail -o ${NEXTIONGROUPS} -s https://www.gmrs-link.com/ohr/mmdvm/groups.txt --user-agent "Pi-Star_${pistarCurVersion}"
  fi
else
  curl --fail -o ${NEXTIONGROUPS} -s https://www.gmrs-link.com/ohr/mmdvm/groups.txt --user-agent "Pi-Star_${pistarCurVersion}"
fi

# Download Nextion Users
if [ -f "${NEXTIONUSERS}" ]; then
    if [ "$(find "${NEXTIONUSERS}" -mtime +7 -print)" ]; then
        curl -sSL "https://www.gmrs-link.com/ohr/mmdvm/nextionUsers.csv" \
            --user-agent "Pi-Star_${pistarCurVersion}" \
            -o "${NEXTIONUSERS}"
    fi
else
    curl -sSL "https://www.gmrs-link.com/ohr/mmdvm/nextionUsers.csv" \
        --user-agent "Pi-Star_${pistarCurVersion}" \
        -o "${NEXTIONUSERS}"
fi

if [ -f "${USERCSV}" ]; then
    if [ "$(find "${USERCSV}" -mtime +7 -print)" ]; then
        curl -sSL "https://www.gmrs-link.com/ohr/hblink/user.csv" \
            --user-agent "Pi-Star_${pistarCurVersion}" \
            -o "${USERCSV}"
    fi
else
    curl -sSL "https://www.gmrs-link.com/ohr/hblink/user.csv" \
        --user-agent "Pi-Star_${pistarCurVersion}" \
        -o "${USERCSV}"
fi

# Overrides
if [ -f "/root/DMR_Hosts.txt" ]; then
	cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
fi

if [ -f "/root/YSFHosts.txt" ]; then
	cat /root/YSFHosts.txt >> ${YSFHOSTS}
fi

if [ -f "/root/M17Hosts.txt" ]; then
	cat /root/M17Hosts.txt >> ${M17HOSTS}
fi

if [ -f "/root/NXDNHosts.txt" ]; then
	cat /root/NXDNHosts.txt > /usr/local/etc/NXDNHostsLocal.txt
fi

exit 0
