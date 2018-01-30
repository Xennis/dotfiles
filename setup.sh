#!/bin/bash


# https://github.com/nicksp/dotfiles/blob/master/setup.sh


###############################################################################
# Util functions
###############################################################################

print_info() {
  # Print output in purple
  printf " %s\\n" "$1"
}

print_success() {
  # Print output in green
  printf "\\e[0;32m  [✔] %s\\e[0m\\n" "$1"
}

print_error() {
  # Print output in red
  printf "\\e[0;31m  [✖] %s %s\\e[0m\\n" "$1" "$2"
}

print_result() {
  [ "$1" -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ "$1" -ne 0 ] \
    && exit
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}


###############################################################################
# Setup functions
###############################################################################

clone_repository() {
  local dotfiles_dir=$1

  if [ ! -d "${dotfiles_dir}" ]; then
      print_info "Clone repository"
      git clone https://github.com/Xennis/dotfiles.git "${dotfiles_dir}"
  fi
}

move_existing_dotfiles() {
  local dotfiles_backup_dir=$1
  #local files_to_symlink=$2

  if [ ! -d "${dotfiles_backup_dir}" ]; then
    print_info "Create $dotfiles_backup_dir for backup"
    mkdir -p "$dotfiles_backup_dir"
  fi

  for i in "${FILES_TO_SYMLINK[@]}"; do
    dot_file=~/.${i##*/}
    # Check file exists and is not a link
    if [ -f "${dot_file}" ] && [ ! -L "${dot_file}" ]; then
      print_info "Move ${dot_file} to ${dotfiles_backup_dir}"
      mv "${dot_file}" "${dotfiles_backup_dir}/"
    fi
  done
}

create_symbolic_links() {
  #local files_to_symlink=$1

  for i in "${FILES_TO_SYMLINK[@]}"; do
    sourceFile="$(pwd)/$i"
    targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$targetFile" ]; then
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else
      print_error "$targetFile → $sourceFile"
    fi
  done
}


###############################################################################
# The script
###############################################################################

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_BACKUP_DIR="${DOTFILES_DIR}_old"

declare -a FILES_TO_SYMLINK=(
  'git/gitconfig'

  'shell/bashrc'
  'shell/shell_aliases'
  'shell/shell_exports'
  'shell/shell_functions'
  'shell/shellrc'

  'vim/vimrc'
)

print_info "Change to ${DOTFILES_DIR}"
clone_repository "${DOTFILES_DIR}"
cd "${DOTFILES_DIR}" || exit

move_existing_dotfiles "$DOTFILES_BACKUP_DIR"
create_symbolic_links
