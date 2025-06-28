#!/usr/bin/env bash
# Configuration for structured logging
# Used by: ../lib/logging.sh
# SPDX-FileCopyrightText: The Voleon Group
# SPDX-License-Identifier: None
# Daniel Wilson <dwilson@domain.com>
# Data Classification: INTERNAL

#######################################
# Logging format
# Options: kv, json, hec
#######################################
export LOG_FORMAT="kv"

#######################################
# Splunk HEC Configuration
# Required if LOG_FORMAT=hec
#######################################

# Uncomment and fill in these values to enable HEC logging:

# export SPLUNK_HEC_TOKEN="your-secure-token-here"
# export SPLUNK_HEC_URL="splunk.example.com"
# export SPLUNK_HEC_PORT="8088"

#######################################
# Optional: Enable additional outputs
#######################################

# export ENABLE_SYSLOG=true     # Send to system log via `logger` (future feature)
# export LOG_FILE_PATH="/var/log/your_script.log"  # Optional local file output (future feature)

# Future consideration: export ENVIRONMENT="production"
