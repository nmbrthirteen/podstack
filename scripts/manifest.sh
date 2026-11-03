#!/bin/bash
# Shared helpers for setup.sh and sync-to-podcli.sh. Source this file; do not run it.
#
# Every directory PodStack installs commands into holds a .podstack-manifest with one
# "<sha256>  <file>" line per installed file. The hash is what PodStack last wrote, so a
# different hash on disk means the user edited the file.

MANIFEST_NAME=".podstack-manifest"
NEW_MANIFEST=""
INSTALL_STATUS=""

file_hash() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d' ' -f1
    else
        sha256sum "$1" | cut -d' ' -f1
    fi
}

# Knowledge base location, shared so both scripts agree.
detect_knowledge_dir() {
    if [ -d "$1/.podcli" ]; then
        echo ".podcli/knowledge"
    else
        echo "knowledge"
    fi
}

manifest_hash() {
    local file="$1/$MANIFEST_NAME"
    [ -f "$file" ] || return 0
    awk -v n="$2" '$2 == n { print $1; exit }' "$file"
}

manifest_begin() {
    NEW_MANIFEST="$(mktemp)"
}

manifest_record() {
    printf '%s  %s\n' "$2" "$1" >> "$NEW_MANIFEST"
}

# Writes the new manifest. Entries from the old manifest that this run did not touch
# are kept while their file still exists.
manifest_commit() {
    local dir="$1" old="$1/$MANIFEST_NAME" merged hash name
    merged="$(mktemp)"
    cat "$NEW_MANIFEST" > "$merged"
    if [ -f "$old" ]; then
        while read -r hash name; do
            [ -n "$name" ] || continue
            if [ -f "$dir/$name" ] && ! awk -v n="$name" '$2 == n { found = 1 } END { exit !found }' "$NEW_MANIFEST"; then
                printf '%s  %s\n' "$hash" "$name" >> "$merged"
            fi
        done < "$old"
    fi
    sort -k2 "$merged" > "$old"
    rm -f "$merged" "$NEW_MANIFEST"
}

# install_managed <source-file> <dest-file> <overwrite: 0|1>
# Sets INSTALL_STATUS to installed, unchanged, updated, backed-up, or skipped.
# With overwrite=1 a file whose content differs from the last install is saved
# to <dest>.bak before it is replaced.
install_managed() {
    local src="$1" dest="$2" overwrite="$3"
    local dir name new cur recorded
    dir="$(dirname "$dest")"
    name="$(basename "$dest")"
    new="$(file_hash "$src")"
    recorded="$(manifest_hash "$dir" "$name")"

    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
        INSTALL_STATUS="installed"
        manifest_record "$name" "$new"
        return 0
    fi

    cur="$(file_hash "$dest")"
    if [ "$cur" = "$new" ]; then
        INSTALL_STATUS="unchanged"
        manifest_record "$name" "$new"
        return 0
    fi

    if [ "$overwrite" != "1" ]; then
        INSTALL_STATUS="skipped"
        if [ -n "$recorded" ]; then
            manifest_record "$name" "$recorded"
        fi
        return 0
    fi

    if [ "$cur" = "$recorded" ]; then
        INSTALL_STATUS="updated"
    else
        cp "$dest" "$dest.bak"
        INSTALL_STATUS="backed-up"
    fi
    cp "$src" "$dest"
    manifest_record "$name" "$new"
}

# remove_stale <dir>
# Deletes files the old manifest lists that this run did not record, but only
# when the user has not edited them. Prints one status line per file.
# Call before manifest_commit.
remove_stale() {
    local dir="$1" old="$1/$MANIFEST_NAME" hash name
    [ -f "$old" ] || return 0
    while read -r hash name; do
        [ -n "$name" ] || continue
        if awk -v n="$name" '$2 == n { found = 1 } END { exit !found }' "$NEW_MANIFEST"; then
            continue
        fi
        [ -f "$dir/$name" ] || continue
        if [ "$(file_hash "$dir/$name")" = "$hash" ]; then
            rm "$dir/$name"
            echo "removed $name"
        else
            echo "kept $name (edited, no longer shipped by PodStack)"
        fi
    done < "$old"
}
