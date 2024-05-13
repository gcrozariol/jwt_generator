#!/bin/bash

# Function to perform directory auto-completion
_directory_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()
    # If the current word starts with a "-", return no suggestions
    if [[ "$cur" == -* ]]; then
        return 0
    fi
    # Get directory suggestions
    COMPREPLY=( $(compgen -d -- "$cur") )
    return 0
}

# Prompt user for directory to add variables
read -e -p "Enter the directory where you want to store the .env file (leave blank for current directory): " directory

# If directory is not provided, use the directory where the script is located
if [ -z "$directory" ]; then
    directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

# Generate private key
openssl genpkey -algorithm RSA -out "$directory/private.key" -pkeyopt rsa_keygen_bits:2048

# Generate public key
openssl rsa -pubout -in "$directory/private.key" -out "$directory/public.key" -outform PEM

# Convert private key to base64
JWT_PRIVATE_KEY=$(openssl base64 -in "$directory/private.key" -A)

# Convert public key to base64
JWT_PUBLIC_KEY=$(openssl base64 -in "$directory/public.key" -A)

# Add keys to .env file
echo "JWT_PRIVATE_KEY=\"$JWT_PRIVATE_KEY\"" >> "$directory/.env"
echo "JWT_PUBLIC_KEY=\"$JWT_PUBLIC_KEY\"" >> "$directory/.env"

# Remove key files
rm "$directory/private.key" "$directory/public.key"

echo "Keys generated and stored in $directory/.env file."
