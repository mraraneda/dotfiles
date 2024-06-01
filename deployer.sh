#!/bin/bash

## These are just helper variables
SCRIPT=$(echo "$0" | awk -F "/" '{print $NF}')
# UUIDSHORT=$(uuidgen | cut -d\- -f1)
CURRENT_DIR=$(pwd)
# BASEDIR=$(dirname "$0")
SILENT_MODE=""

# Default output script logging to current directory / scriptname.log
LOGFILE="$CURRENT_DIR/deployer.log"

# LOGGING STUFF
# function log() {
#     printf '%s\t[%s]\t%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$SCRIPT" "$*" >> "$LOGFILE"
# }

function stdout() {
     printf '%s\t[%s]\t%s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$SCRIPT" "$*"
}

function info() {
    if test -z $SILENT_MODE; then
        stdout "[INFO ] $*"
    fi

    # # Save to log file
    # log "[INFO ] $*"
}

function error() {
    if test -z $SILENT_MODE; then
        stdout "[ERROR] $*"
    fi

    # # Save to log file
    # log "[ERROR] $*"
}

# Reading user input / flags
function userInput() {
    # People like to use --help I just add this as a catch all type of thing
    if [[ $* =~ --help ]]; then
        usage
        exit 255
    fi

    # h  => flag
    # f: => flag + input: For example -f ~/rickjms/awesome/file.txt
    # n  => flag
    while getopts "h:nxs" flag
    do
        case $flag in
            h)
                usage
                exit 255
            ;;
            # f)
            #     USER_FILE="$OPTARG" # Note you need to use $OPTARG for this to work.
            #     FILE_PASSED="true"  # I use this as a helper to easily check if file is passed in.
            # ;;
            n)
                SIMULATION_MODE="true"
            ;;
            x)
                SIMULATION_MODE="false"
            ;;
            s)
                SILENT_MODE="true" # Turns off logging to the terminal
            ;;
            \?)
                usage
                exit 255
            ;;
        esac
    done

}

# This is self explanatory display help menu
function usage() {
    printf '%s\n' "Usage:"
    printf '\t%s\t\t%s\n' "-h" "Display help menu"
    printf '\t%s\t\t%s\n' "-n" "Enabled simulation mode. Do not perform any operations"
    printf '\t%s\t\t%s\n' "-x" "Execute mode. Opposite of simulation mode"
    printf '\t%s\t\t%s\n' "-q" "Silent Mode do not post output"
}

##### Functional Zone #####

## Variables ##

TARGET_DIR="$HOME"

BUNDLES=(
    ## Add here aditional "dotfiles"
    "apps"
    "zsh"
)


function deploy() {

    info "Run deployment..."

    for b in "${BUNDLES[@]}"
    do
        if cd "${b}" 2>&1 /dev/null
        then
            info "Entry to ${b} folder"
        else
            error "Change to folder ${b} failed"
            break
        fi

        case $SIMULATION_MODE in
            true)
                info "Simulation mode enabled"
                # shellcheck disable=SC2035
                stow --dotfiles -v -n -t "$TARGET_DIR" *
            ;;
            false)
                info "Execution mode enabled"
                # shellcheck disable=SC2035
                stow --dotfiles -v -t "$TARGET_DIR" *
            ;;
            * )
            error "Simulation mode not declared. It's necessary parameter [-n | -x]"
            usage
            cd "$CURRENT_DIR" 2>&1 /dev/null || return
            break
            ;;
        esac

        cd "$CURRENT_DIR" 2>&1 /dev/null || return

    done
}

##### MAIN FUNCTION #####
userInput "$@"
deploy
