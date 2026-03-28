#!/bin/bash

# 1.Location where log history store
LOG_FILE="/home/sandeep-yaduvanshi/Desktop/System-health-monitoring/logs/history.log"

# 2.Function for printing message with exact time and date
log_message() {
	echo "[$(date +'%Y-%m-%d %H:%M')] $1" >> "$LOG_FILE"
	echo "[$(date +'%Y-%m-%d %H:%M')] $1"
}

# 3. Very Important checking nginx server is active or not
systemctl is-active --quiet nginx
if [ $? -ne 0 ]; then
	log_message "CRITICAL: NGINX IS DEAD Restarting nginx"
	exit 1
fi

# 4.Checking disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {printf "%.0f", $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
	log_message "CRITICAL: DISK SPACE FULL"
	exit 1
fi

# 5.Checking cup usage
CPU_USAGE=$(top -n 1 | grep "Cpu(s)" | awk '{printf "%.0f", $2}')
if [ "$CPU_USAGE" -gt 85 ]; then
	log_message "CPU USE IS HIGH ${CPU_USAGE}%"
	exit 1
fi

# 6.Cheching ram usage
RAM_USAGE=$(free -h | awk 'NR==2 {printf "%.0f", $3*100/$2}')
if [ "$RAM_USAGE" -gt 85 ]; then
	log_message "CRITICAL: RAM IS FULL ${RAM_USAGE}%"
	exit 1
fi


# 7.history.log error hunting if found
if grep -i -q "error" "$LOG_FILE"; then
	log_message "ERROR FOUND IN LOG FILE"
	exit 1
fi

# 8.Final message if everthing fine
log_message "STATUS OKAY"
exit 0
