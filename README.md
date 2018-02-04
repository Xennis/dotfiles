# Xennis's Dotfiles

## Installation

```sh
git clone --recursive https://github.com/Xennis/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

Manual step for linking awesome and termite configuration
```sh
ln -fs $(pwd)/config/awesome $HOME/.config/awesome
ln -fs $(pwd)/config/termite $HOME/.config/termite
```

#### Dependencies

* awesome: termite
* git: vim, meld
* zsh: powerline-fonts

## Resources

* Setup script based on [Nick Plekhanov's dotfiles](https://github.com/nicksp/dotfiles/)
* Termite color scheme is from [Solarized color scheme for Termite](https://github.com/alpha-omega/termite-colors-solarized)
