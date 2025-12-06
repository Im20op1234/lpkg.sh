#!/bin/sh

if ! command -v zip >/dev/null 2>&1
then
    echo "package 'zip' is not installed or is broken"
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1
then
    echo "package 'unzip' is not installed or is broken"
    exit 1
fi

LPKG_DIR="$HOME/.lpkg" # lpkg.sh directory.
PKG_DIR="$LPKG_DIR/packages" # Directory of installed packages.

mkdir -p "$PKG_DIR"

install_dotpkg() {
    dotpkg_path="$1" # Grabs the zip package from $1.
    pkg_name="$(basename "$dotpkg_path" .pkg)" # Removes .pkg from $1.
    pkg_path="$PKG_DIR/$pkg_name" # Package installation directory.

    if [ -z "$dotpkg_path" ] || [ -z "$pkg_name" ]; then # In case if does : ./lpkg.sh install : only.
        echo "Usage: lpkg install <pkg-file>"
        exit 1
    fi

    if [ ! -f "$dotpkg_path" ]; then # In case if cannot find zip file.
        echo -e "\e[33mError: PKG file \e[0m'$dotpkg_path'\e[33m not found.\e[0m"
        exit 1
    fi

    if [ -d "$pkg_path" ]; then # In case of the package is already installed.
        echo -e "\e[33mError: Package \e[0m'$pkg_name'\e[33m is already installed.\e[0m"
        return
    fi

    mkdir "$pkg_path" # Makes package folder.
    unzip -q "$dotpkg_path" -d "$pkg_path" # Unzips the zip to the folder.

    if [ $? -ne 0 ]; then # In case of failure of the zip cannot be installed.
        echo -e "\e[31mError: Failed to unzip package.\e[0m"
        rm -rf "$pkg_path"
        exit 1
    fi

    echo -e "\e[32mPackage \e[0m'$pkg_name'\e[32m was successfully installed.\e[0m" # echos of package installed correctly.
    if [ ! -f "$pkg_path/start.sh" ]; then
      echo "Uh oh. the package doesnt have a start.sh in it!"
      echo "Heres whats inside."
      echo -e "----\e[34mFiles in $pkg_name\e[0m----" # Shows inside of the package after installation.
      echo ""
      ls "$pkg_path"
      echo ""
      echo -e "----\e[34mEnd of $pkg_name\e[0m----"
    else
      echo "found start.sh in $pkg_name"
    fi
}

remove_pkg() {
    pkg_name="$1"
    pkg_path="$PKG_DIR/$pkg_name"
    rmpkgq="" # Check if read gets y or n.

    if [ -z "$pkg_name" ]; then # In case if does : ./lpkg.sh remove : only.
        echo "Usage: lpkg remove <package-name>"
        exit 1
    fi
    if [ -d "$pkg_path" ]; then # Check if directory exists.
     echo "Remove package :$pkg_name:"
     printf "Continue? (y/n) : " # Ask for y or n (Alpine-compatible)
     read rmpkgq # Read answer
     if [ "${rmpkgq}" = "y" ]; then # If read gets y then remove package.
         if [ -d "$pkg_path" ]; then # Check if directory exists.
             rm -rf "$pkg_path" # Stay careful with this.
             echo -e "\e[32mPackage \e[0m'$pkg_name'\e[32m removed.\e[0m" # Echos uninstall of package.
         else
             echo -e "\e[31mError: Package was not removed\e[0m" # Unused.
         fi
     else
         echo "$pkg_name was not removed" # If read gets n.
     fi
    else
     echo -e "\e[31mError: Package \e[0m'$pkg_name'\e[31m is not installed.\e[0m" # echos error if package is not installed.
    fi
}

list_pkgs() {
    echo "Installed packages:"
    ls "$PKG_DIR" # Lists installed packages
    echo "----End-of-packages----"
}

run_pkg() {
    pkg_name="$1" # Gets package name from $1.
    script_name="${2:-start.sh}" # Defaults to start.sh if not provided.
    pkg_path="$PKG_DIR/$pkg_name" # Package path.
    script_path="$pkg_path/$script_name"

    if [ -z "$pkg_name" ]; then # In case if does : ./lpkg.sh run : only.
        echo "Usage: lpkg run <package> [script]"
        exit 1
    fi

    if [ ! -d "$pkg_path" ]; then # If package doesnt exist.
        echo -e "\e[31mError: Package \e[0m'$pkg_name'\e[31m is not installed.\e[0m"
        exit 1
    fi

    if [ ! -f "$script_path" ]; then # If script doesnt exist
        echo -e "\e[31mError: Script \e[0m'$script_name'\e[31m not found in package '\e[0m$pkg_name\e[31m'.\e[0m"
        exit 1
    fi

    sh "$script_path" # Runs the script in a subshell
}

run_ver() {
    echo "lpkg Version: 1.6"
}

help_msg() {
    echo "lpkg - Local-Only Shell Package Manager"
    echo ""
    echo "Usage:"
    echo " lpkg install <zip-file> [zip-file2 ...]   : Install one or more packages"
    echo " lpkg remove <package-name> [pkg2 ...]     : Remove one or more packages"
    echo " lpkg run <package> [script]               : Run a script from a package"
    echo " lpkg list                                 : List installed packages"
    echo " lpkg version                              : Show version"
    echo " lpkg help                                 : Show this help message"
}

# === Main command handler ===
case "$1" in
    install)
        shift
        for zip_file in "$@"; do
            install_dotpkg "$zip_file"
        done
        ;;
    remove)
        shift
        for pkg in "$@"; do
            remove_pkg "$pkg"
        done
        ;;
    run)
        run_pkg "$2" "$3"
        ;;
    list)
        list_pkgs
        ;;
    version)
        run_ver
        ;;
    help|*)
        help_msg
        ;;
esac
