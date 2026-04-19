# About War1gus

<img src="./war1gus.png" width="100" align="right" />

War1gus is a re-implementation of **Warcraft: Orcs & Humans** that that can be played on modern platforms with the [Stratagus engine](https://github.com/Wargus/stratagus). The game uses graphics and sounds from the original Warcraft, but improves the gameplay mechanisms with many modern conveniences that the Stratagus engine allows, such as modern mouse controls, named groups, larger group selection, more player factions in multiplayer games, a map editor, and multiple towns. 

You can find more details at [stratagus.com](https://stratagus.com/war1gus.html) 

### Nightly builds

These are builds from our CI runs. Since they are built every time a commit is made, they may be unstable. 

- [Windows Installer](https://github.com/Wargus/war1gus/releases/tag/master-builds)
- [Ubuntu/Debian Packages](https://launchpad.net/~stratagus/+archive/ubuntu/ppa) 
- [macOS App Bundles](https://github.com/Wargus/war1gus/actions/workflows/macos.yml?query=branch%3Amaster)

### Extracting data for macOS

In order to play War1gus you first need to extract the game data from your Warcraft installer. The built-in extractor tool is currently not working correctly on macOS, but
[this third-party script](https://github.com/shinra-electric/Stratagus-Data-Extractor-Script) can be used while fixes are being worked on. <br>. For convience I have included the script here in dev_scripts. For clarification, setup_warcraft_orcs__humans_1.2_(28330).exe is the offline Gog installer for the Windows version, which you can extract from even on Mac. 

Run the script in the same folder as your game data and the War1gus app. **It only needs to be run once**. 

It will not be needed in the future when the built-in extractor is fixed. 

### Development: Fast script updates

During development, make changes in this repository and then use the sync script to copy them into the local Stratagus data directory for testing:

```bash
./dev_scripts/copy_to_data.sh
```

This syncs `scripts/`, `campaigns/`, `contrib/`, `shaders/`, and `maps/` directories. It will not overwrite game data files, only the mod content.

> Important: do **not** edit files directly under `~/Library/Application Support/Stratagus/data.War1gus/`. Those are runtime copies. Edit the repo files first, then run the script to update the installed data.

### Build status

Windows: <a href="https://ci.appveyor.com/project/timfel/war1gus"><img width="100" src="https://ci.appveyor.com/api/projects/status/github/Wargus/war1gus?branch=master&svg=true"></a>

Linux: [![Build Status](https://travis-ci.org/Wargus/war1gus.svg?branch=master)](https://travis-ci.org/Wargus/war1gus)

macOS: ![Build Status](https://github.com/Wargus/war1gus/actions/workflows/macos.yml/badge.svg)


### Join the community
[![Join the chat at https://gitter.im/Wargus](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Wargus?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Discord](https://img.shields.io/discord/780082494447288340?style=flat-square&logo=discord&label=discord)](https://discord.gg/dQGxaw3QfB)


### Gallery
<img width="800" src="https://user-images.githubusercontent.com/93911529/157967177-0eab04af-a704-415d-8f6f-294d0e5aaed0.png">
