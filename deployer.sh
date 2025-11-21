#!/bin/bash

## These are just helper variables
SCRIPT=$(echo "$0" | awk -F "/" '{print $NF}')
# UUIDSHORT=$(uuidgen | cut -d\- -f1)
CURRENT_DIR=$(pwd)
# BASEDIR=$(dirname "$0")
SILENT_MODE=""
INSTALL_REQ="false"

# Default output script logging to current directory / scriptname.log
# LOGFILE="$CURRENT_DIR/deployer.log"

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
    while getopts "h:inxq" flag
    do
        case $flag in
            h)
                usage
                exit 255
            ;;
            i)
                INSTALL_REQ="true"
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
            q)
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
    printf '\t%s\t\t%s\n' "-i" "Install dependencies"
    printf '\t%s\t\t%s\n' "-n" "Enabled simulation mode. Do not perform any operations"
    printf '\t%s\t\t%s\n' "-x" "Execute mode. Opposite of simulation mode"
    printf '\t%s\t\t%s\n' "-q" "Silent Mode do not post output"
}

##### Functional Zone #####

## Variables ##

TARGET_DIR="$HOME"

DOTFILES_BUNDLE=(
    ## Add here aditional "dotfiles" bundles
    "base/apps"
    "base/shell"
)

#-------------------------------------------------------------------------------

function deploy() {
    info "Run deployment..."

    for b in "${DOTFILES_BUNDLE[@]}"
    do
        if cd "${b}" 2>&1 /dev/null
        then
            info "Entry to \"${b}\" folder"
        else
            error "Change to folder \"${b}\" failed"
            break
        fi

        # Validate parameters
        case $SIMULATION_MODE in
            true | false)
                stower "$SIMULATION_MODE"
            ;;
            * )
            error "Mode not declared. It's necessary parameter [-n | -x]"
            usage
            cd "$CURRENT_DIR" 2>&1 /dev/null || return
            break
            ;;
        esac

        cd "$CURRENT_DIR" 2>&1 /dev/null || return

    done
}

#-------------------------------------------------------------------------------

function stower() {
    local SIMULATION_MODE=$1


    ## Loop through only the directories contained in the parent directory
    for PACKAGE in $(find . -maxdepth 1 -type d -name "*" \
                                | awk -F "/" '{ if ($NF != ".") print $NF }')
    do
        if [ "$SIMULATION_MODE" == true ]
        then
            info "SIMULATION mode for package \"$PACKAGE\""
            /opt/homebrew/bin/stow --dotfiles -v -n -t "$TARGET_DIR" "$PACKAGE" 2>&1
        else
            info "EXECUTION mode for package \"$PACKAGE\""
            /opt/homebrew/bin/stow --dotfiles -v -t "$TARGET_DIR" "$PACKAGE" 2>&1
        fi
    done
}

#-------------------------------------------------------------------------------

function install_dependences() {

    BREW_COMMAND_PATH="$(command -v brew 2>&1 > /dev/null)"

	if [ -n "$BREW_COMMAND_PATH" ]; then
		stdout "Brew not installed, installing..."

		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

    ARCHITECTURE="$(uname -m)"

	if [ "$ARCHITECTURE" == "arm64" ]; then
		export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
	else
		export PATH="$PATH:/usr/local/bin"
	fi

	mkdir -p "$HOME/bin"

    stdout "Installing needed gnu packages..."
    for APP in "${APPS_INSTALL_LIST[@]}"
    do
        # shellcheck disable=SC2086
        stdout "Test app presence: $(echo $APP | cut -d' ' -f2)"

        # shellcheck disable=SC2069
        # shellcheck disable=SC2086
        if  ! brew list "$(echo $APP | cut -d' ' -f2)" 2>&1 > /dev/null
        then
            stdout "Installing brew $APP"
            eval ""
        fi
    done

}

#-------------------------------------------------------------------------------

##### MAIN FUNCTION #####
userInput "$@"
[ "$INSTALL_REQ" == "true" ] && install_dependences
deploy




#-------------------------------------------------------------------------------

# APP_INSTALL_LIST=(
#     "brew install bash"
#     "brew install zsh"
#     "brew install coreutils"
#     "brew install make"
#     "brew install gnu-sed"
#     "brew install findutils"
#     "brew install bat"
#     "brew install hyperfine"
#     "brew install mas"
#     "brew install --cask alacritty"
#     "brew install helix"
#     "brew install tmux"
#     "brew install --cask zed"
#     ## Nerd Fonts
#     "brew install --cask font-blex-mono-nerd-font"
#     "brew install --cask font-caskaydia-cove-nerd-font"
#     "brew install --cask font-fira-code-nerd-font"
#     "brew install --cask font-zed-mono-nerd-font"
#     "brew install --cask font-hasklug-nerd-font"
#     "brew install --cask font-iosevka-term-nerd-font"
#     "brew install --cask font-jetbrains-mono-nerd-font"
#     "brew install --cask font-mplus-nerd-font"
# )
