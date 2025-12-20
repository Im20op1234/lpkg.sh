#!/bin/sh

# === Dependency checks ===
command -v zip >/dev/null 2>&1 || {
    echo "package 'zip' is not installed or is broken"
    exit 1
}

command -v unzip >/dev/null 2>&1 || {
    echo "package 'unzip' is not installed or is broken"
    exit 1
}

LPKG_DIR="$HOME/.lpkg"
PKG_DIR="$LPKG_DIR/packages"

mkdir -p "$PKG_DIR"

# === Install ===
install_dotpkg() {
    dotpkg_path="$1"
    pkg_name="$(basename "$dotpkg_path" .pkg)"
    pkg_path="$PKG_DIR/$pkg_name"

    [ -z "$dotpkg_path" ] && {
        echo "Usage: lpkg install <pkg-file>"
        exit 1
    }

    [ ! -f "$dotpkg_path" ] && {
        echo "Error: PKG file '$dotpkg_path' not found."
        exit 1
    }

    [ -d "$pkg_path" ] && {
        echo "Error: Package '$pkg_name' is already installed."
        return
    }

    mkdir "$pkg_path" || exit 1
    unzip -q "$dotpkg_path" -d "$pkg_path" || {
        echo "Error: Failed to unzip package."
        rm -rf "$pkg_path"
        exit 1
    }

    echo "Package '$pkg_name' installed."

    if [ -f "$pkg_path/start.sh" ]; then
        echo "found start.sh in $pkg_name"
    else
        echo "Uh oh. the package doesnt have a start.sh in it!"
        echo "----Files in $pkg_name----"
        ls "$pkg_path"
        echo "----End of $pkg_name----"
    fi
}

# === Remove ===
remove_pkg() {
    pkg_name="$1"
    pkg_path="$PKG_DIR/$pkg_name"

    [ -z "$pkg_name" ] && {
        echo "Usage: lpkg remove <package-name>"
        exit 1
    }

    [ ! -d "$pkg_path" ] && {
        echo "Error: Package '$pkg_name' is not installed."
        return
    }

    printf "Remove package %s? (y/n): " "$pkg_name"
    read ans

    [ "$ans" = "y" ] && {
        rm -rf "$pkg_path"
        echo "Package '$pkg_name' removed."
    } || echo "Cancelled."
}

# === List ===
list_pkgs() {
    list="$@"
    echo "Installed packages:"
    ls "$PKG_DIR/$list"
    echo "----End-of-packages----"
}

# === Run ===
run_pkg() {
    pkg_name="$1"
    script_name="${2:-start.sh}"
    shift 2

    pkg_path="$PKG_DIR/$pkg_name"
    script_path="$pkg_path/$script_name"

    [ -z "$pkg_name" ] && {
        echo "Usage: lpkg run <package> [script] [args...]"
        exit 1
    }

    [ ! -d "$pkg_path" ] && {
        echo "Error: Package '$pkg_name' is not installed."
        exit 1
    }

    [ ! -f "$script_path" ] && {
        echo "Error: Script '$script_name' not found in '$pkg_name'."
        exit 1
    }

    sh "$script_path" "$@"
}

# === Version ===
run_ver() {
    echo "lpkg Version: 1.6"
}

# === Help ===
help_msg() {
    echo "lpkg - Local-Only Shell Package Manager"
    echo ""
    echo "Usage:"
    echo " lpkg install <pkg-file> [...]"
    echo " lpkg remove <package>"
    echo " lpkg run <package> [script] [args...]"
    echo " lpkg list <package> [directory]"
    echo " lpkg version"
    echo " lpkg help"
}

# === Main ===
case "$1" in
    install)
        shift
        for pkg in "$@"; do
            install_dotpkg "$pkg"
        done
        ;;
    remove)
        shift
        for pkg in "$@"; do
            remove_pkg "$pkg"
        done
        ;;
    run)
        shift
        run_pkg "$@"
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