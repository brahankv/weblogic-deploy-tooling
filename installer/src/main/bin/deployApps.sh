#!/bin/sh
# *****************************************************************************
# deployApps.sh
#
# Copyright (c) 2017, 2023, Oracle Corporation and/or its affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
#     NAME
#       deployApps.sh - WLS Deploy tool to provision apps and resources.
#
#     DESCRIPTION
#       This script configures the base domain, adds resources, and
#       deploys applications.
#
# This script uses the following variables:
#
# JAVA_HOME             - The location of the JDK to use.  The caller must set
#                         this variable to a valid Java 7 (or later) JDK.
#
# WLSDEPLOY_HOME        - The location of the WLS Deploy installation.
#                         If the caller sets this, the callers location will be
#                         honored provided it is an existing directory.
#                         Otherwise, the location will be calculated from the
#                         location of this script.
#
# WLSDEPLOY_PROPERTIES  - Extra system properties to pass to WLST.  The caller
#                         can use this environment variable to add additional
#                         system properties to the WLST environment.
#

usage() {
  echo ""
  echo "Usage: $1 [-help] [-use_encryption]"
  echo "          [-oracle_home <oracle_home>]"
  echo "          [-domain_home <domain_home>]"
  echo "          -model_file <model_file>"
  echo "          [-archive_file <archive_file>]"
  echo "          [-variable_file <variable_file>]"
  echo "          [-domain_type <domain_type>]"
  echo "          [-passphrase_env <passphrase_env>]"
  echo "          [-passphrase_file <passphrase_file>]"
  echo "          [-wlst_path <wlst_path>]"
  echo "          [-cancel_changes_if_restart_required]"
  echo "          [-discard_current_edit]"
  echo "          [-wait_for_edit_lock]"
  echo "          [-output_dir <output_dir>]"
  echo "          [-admin_url <admin_url>"
  echo "           -admin_user <admin_user>"
  echo "           -admin_pass_env <admin_pass_env> | -admin_pass_file <admin_pass_file>"
  echo "           [-remote]"
  echo "          ]"
  echo ""
  echo "    where:"
  echo "        oracle_home     - the existing Oracle Home directory for the domain."
  echo "                          This argument is required unless the ORACLE_HOME"
  echo "                          environment variable is set."
  echo ""
  echo "        domain_home     - the domain home directory.  This argument is"
  echo "                          required if -remote option is not specified"
  echo ""
  echo "        model_file      - the location of the model file to use.  This can also"
  echo "                          be specified as a comma-separated list of model"
  echo "                          locations, where each successive model layers on top"
  echo "                          of the previous ones.  This argument is required."
  echo ""
  echo "        archive_file    - the path to the archive file to use.  This can also"
  echo "                          be specified as a comma-separated list of archive"
  echo "                          files.  The overlapping contents in each archive take"
  echo "                          precedence over previous archives in the list."
  echo ""
  echo "        variable_file   - the location of the property file containing the"
  echo "                          values for variables used in the model. This can also"
  echo "                          be specified as a comma-separated list of property"
  echo "                          files, where each successive set of properties layers"
  echo "                          on top of the previous ones."
  echo ""
  echo "        domain_type     - the type of domain (e.g., WLS, JRF)."
  echo "                          Used to locate wlst.cmd if -wlst_path not specified."
  echo ""
  echo "        passphrase_env  - An alternative to entering the encryption passphrase"
  echo "                          at a prompt. The value is an ENVIRONMENT VARIABLE"
  echo "                          name that WDT will use to retrieve the passphrase."
  echo ""
  echo "        passphrase_file - An alternative to entering the encryption passphrase"
  echo "                          at a prompt. The value is the name of a file with a"
  echo "                          string value which WDT will read to retrieve the"
  echo "                          passphrase."
  echo ""
  echo "        wlst_path       - the Oracle Home subdirectory of the wlst.cmd"
  echo "                          script to use (e.g., <ORACLE_HOME>/soa)."
  echo ""
  echo "        output_dir      - if specified, files containing restart information"
  echo "                          are written to this directory, including"
  echo "                          restart.file, non_dynamic_changes.file, and"
  echo "                          results.json."
  echo ""
  echo "        admin_url       - the admin server URL (used for online deploy)."
  echo ""
  echo "        admin_user      - the admin username (used for online deploy)."
  echo ""
  echo "        admin_pass_env  - An alternative to entering the admin password at a"
  echo "                          prompt. The value is an ENVIRONMENT VARIABLE name"
  echo "                          that WDT will use to retrieve the password."
  echo ""
  echo "        admin_pass_file - An alternative to entering the admin password at a"
  echo "                          prompt. The value is the name of a file with a"
  echo "                          string value which WDT will read to retrieve the"
  echo "                          password."
  echo ""
  echo "    The -use_encryption switch tells the program that one or more of the"
  echo "    passwords in the model or variables files are encrypted.  The program will"
  echo "    prompt for the decryption passphrase to use to decrypt the passwords."
  echo "    Please note that Java 8 or higher is required when using this feature."
  echo ""
  echo "    The -cancel_changes_if_restart_required switch tells the program to cancel"
  echo "    the changes if the update requires domain restart."
  echo ""
  echo "    The -discard_current_edit switch tells the program to discard all existing"
  echo "    changes before starting the update."
  echo ""
  echo "    The -wait_for_edit_lock switch tells the program to skip checking for WLST"
  echo "    edit sessions and wait for the WLST edit lock."
  echo ""
}

WLSDEPLOY_PROGRAM_NAME="deployApps"; export WLSDEPLOY_PROGRAM_NAME

scriptName=`basename "$0"`
scriptPath=`dirname "$0"`

. "$scriptPath/shared.sh"

umask 27

checkArgs "$@"

minJdkVersion=7
if [ "$USE_ENCRYPTION" = "true" ]; then
  minJdkVersion=8
fi

# required Java version is dependent on use of encryption
javaSetup $minJdkVersion

runWlst deploy.py "$@"
