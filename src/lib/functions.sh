#!/usr/local/bin/bash

# ---------------------------------------- #
# Programer: PEDRO RIVERO
# Date: Nov 3 2019
# ---------------------------------------- #

## ---- FUNCTIONS ---- ##

# Uses global options
init_backup_mode () {
  tabs 4
  reset_options
  echo -en "\n"
}

# Uses global options and log
end_backup_mode () {
  if [ -z $NO_LOG ]
  then
    echo -e "\n$(tput setab 0)$(tput setaf 7) Logs saved to: $(tput sgr 0) $LOG_FILE \n"
  else
    echo -en "\n"
  fi
}

# Uses global options
backup_if_new () {
  # PARSING
  local source=$1
  local backup=$2
  # FUNCTIONALITY
  if is_new_subdirectory $source $backup
  then
    new_subdirectory_log $backup
    test ! $DRY_RUN && mkdir $backup
  elif is_new_file $source $backup
  then
    file_log $source $backup
    test ! $DRY_RUN && cp $source $backup
  fi
}

# Uses global options (inherited)
do_backup () {
  # PARSING
  local SOURCE_DIR=$1
  local BACKUP_DIR=$2

  # FUNCTIONALITY
  backup_log $SOURCE_DIR $BACKUP_DIR
  local source_tree=($(get_sorted_tree ${SOURCE_DIR}))
  local backup=""

  for source in "${source_tree[@]:1}"
  do
    backup="${BACKUP_DIR}/$(get_relative_path $source $SOURCE_DIR)"
    backup_if_new $source $backup
  done
}

# Uses global options and log
create_log_file () {
  if [ -z $NO_LOG ]
  then
    mkdir ./logs 2> /dev/null
    touch $LOG_FILE 2> /dev/null
  fi
}

# Uses global options
override_if_requested () {
  # PARSING
  local target=$1
  # FUNCTIONALITY
  if [ -z $DRY_RUN ]
  then
    ask_confirmation "override subdirectory \"$target\""
    rm -rf $target
  fi
}

# Uses global options
override_requested_subdirecrories () {
  # PARSING
  local SOURCE_DIR=$1
  local BACKUP_DIR=$2
  # FUNCTIONALITY
  local target=''
  for subdirectory in "${OVERRIDE[@]}"
  do
    target=$(get_backup_path $subdirectory $SOURCE_DIR $BACKUP_DIR)
    if [ -d $target ]
    then
      override_log $target
      override_if_requested $target
    else
      warning_log "OVERRIDE FAILED: \"$target\" is not a subdirectory."
    fi
  done
}

# Uses global options
wipe_backup_if_requested () {
  # PARSING
  local target=$1
  # FUNCTIONALITY
  if [ ! -z $WIPE ] && [ -z $DRY_RUN ]
  then
    wipe_log
    ask_confirmation "wipe backup \"$target\""
    rm -rf $target/*
  fi
}