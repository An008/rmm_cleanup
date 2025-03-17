#!/bin/zsh

read "app_name?Enter the name of the application to search for its uninstaller: "

echo "Searching for uninstallers related to '$app_name'..."

# Search for uninstallers in common directories
uninstallers=$(find /Applications ~/Library/Application\ Support ~/Library/Preferences ~/Library/Caches -iname "*$app_name*" -and -iname "*uninstall*" 2>/dev/null)

if [[ -z "$uninstallers" ]]; then
    echo "No uninstaller found for '$app_name'."
    echo "Searching for all files and folders containing '$app_name'..."

    # Search for all files and folders containing the app name
    matches=$(find /Applications ~/Library ~/Documents ~/Downloads -iname "*$app_name*" 2>/dev/null)

    if [[ -z "$matches" ]]; then
        echo "No files or folders found containing '$app_name'."
        exit 1
    fi

    echo "Files and folders found:"
    echo "$matches"

    # Prompt to delete each file or folder
    for match in $matches; do
        echo "Found: $match"
        read "response?Do you want to delete this item? (yes/no): "
        if [[ "$response" == "yes" ]]; then
            if [[ -d "$match" ]]; then
                rm -rf "$match" && echo "Deleted folder: $match" || echo "Failed to delete folder: $match"
            elif [[ -f "$match" ]]; then
                rm -f "$match" && echo "Deleted file: $match" || echo "Failed to delete file: $match"
            fi
        else
            echo "Skipped: $match"
        fi
    done
else
    echo "Uninstallers found:"
    echo "$uninstallers"

    # Prompt the user to select an uninstaller to execute
    for uninstaller in $uninstallers; do
        echo "Found: $uninstaller"
        read "response?Do you want to execute this uninstaller? (yes/no): "
        if [[ "$response" == "yes" ]]; then
            if [[ -x "$uninstaller" ]]; then
                echo "Executing uninstaller: $uninstaller"
                sudo "$uninstaller"
            else
                echo "The uninstaller is not executable. Trying to run it with sudo..."
                sudo bash "$uninstaller"
            fi
            exit 0
        else
            echo "Skipped: $uninstaller"
        fi
    done
fi

echo "No uninstallers were executed, and no files were deleted."
