#!/bin/bash


# https://github.com/nicksp/dotfiles/blob/master/setup.sh


###############################################################################
# Util functions
###############################################################################

print_info() {
  # Print output in purple
  printf " %s\\n" "${1}"
}

print_success() {
  # Print output in green
  printf "\\e[0;32m  [✔] %s\\e[0m\\n" "${1}"
}

print_error() {
  # Print output in red
  printf "\\e[0;31m  [✖] %s %s\\e[0m\\n" "${1}" "${2}"
}

print_result() {
  [ "${1}" -eq 0 ] \
    && print_success "${2}" \
    || print_error "${2}"

  [ "${3}" == "true" ] && [ "${1}" -ne 0 ] \
    && exit
}

execute() {
  ${1} &> /dev/null
  print_result $? "${2:-$1}"
}


###############################################################################
# Setup functions
###############################################################################

clone_repository() {
  local dotfiles_dir="${1}"

  if [ ! -d "${dotfiles_dir}" ]; then
      print_info "Clone repository"
      git clone https://github.com/Xennis/dotfiles.git "${dotfiles_dir}"
  fi
}

move_existing_file() {
  local dotfiles_backup_dir="${1}"
  local file="${2}"

  if [ ! -d "${dotfiles_backup_dir}" ]; then
    print_info "Create ${dotfiles_backup_dir} for backup"
    mkdir -p "${dotfiles_backup_dir}"
  fi

  # Check file (or dir) exists and is not a link
  if [[ -f "${file}" || -d "${file}" ]] && [ ! -L "${file}" ]; then
    print_info "Move ${file} to ${dotfiles_backup_dir}"
    mv "${file}" "${dotfiles_backup_dir}/"
  fi
}

move_existing_files() {
  local dotfiles_backup_dir="${1}"
  local files_to_symlink=("${@:2}")

  for i in "${files_to_symlink[@]}"; do
    if [[ "${i}" == .* ]]; then
      targetFile="~/${i}"
    else
      targetFile="~/.${i##*/}"
    fi
    move_existing_file "${dotfiles_backup_dir}" "${targetFile}"
  done
}

create_symbolic_link() {
  local sourceFile="${1}"
  local targetFile="${2}"

  if [ ! -e "${targetFile}" ]; then
    execute "ln -fs ${sourceFile} ${targetFile}" "${targetFile} → ${sourceFile}"
  elif [ "$(readlink "${targetFile}")" == "${sourceFile}" ]; then
    print_success "${targetFile} → ${sourceFile}"
  else
    print_error "${targetFile} → ${sourceFile}"
  fi
}

create_symbolic_links() {
  local files_to_symlink=("$@")

  for i in "${files_to_symlink[@]}"; do
    sourceFile="$(pwd)/${i}"
    if [[ "${i}" == .* ]]; then
      targetFile="${HOME}/${i}"
    else
      targetFile="${HOME}/.$(printf "%s" "${i}" | sed "s/.*\/\(.*\)/\1/g")"
    fi
    create_symbolic_link "${sourceFile}" "${targetFile}"
  done
}


###############################################################################
# The script
###############################################################################

DOTFILES_DIR="${HOME}/dotfiles"
DOTFILES_BACKUP_DIR="${DOTFILES_DIR}_old"

# Create directories for config files inside of subdirectories
mkdir -p "${HOME}/.config/Code/User"
mkdir -p "${HOME}/.config/spotify/Users/xen_nis-user"

declare -a FILES_TO_SYMLINK=(
  '.config/awesome'
  '.config/base16-shell'
  '.config/Code/User/keybindings.json'
  '.config/Code/User/settings.json'
  '.config/spotify/Users/xen_nis-user/prefs'
  '.config/terminator'
  '.config/termite'

  'git/gitconfig'

  'shell/oh-my-zsh'
  'shell/bashrc'
  'shell/shell_aliases'
  'shell/shell_exports'
  'shell/shell_functions'
  'shell/shellrc'
  'shell/zshrc'

  'vim/vimrc'
)

print_info "Change to ${DOTFILES_DIR}"
clone_repository "${DOTFILES_DIR}"
cd "${DOTFILES_DIR}" || exit

move_existing_files "${DOTFILES_BACKUP_DIR}" "${FILES_TO_SYMLINK[@]}"
create_symbolic_links "${FILES_TO_SYMLINK[@]}"
