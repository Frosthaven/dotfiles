#!/bin/bash

# Install homebrew if it isn't already installed
if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure ~/.cargo/bin is in the PATH via zshrc
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
fi

