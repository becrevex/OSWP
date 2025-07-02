#!/bin/bash

FILE="OSWP_TECHNIQUES.md"

show_titles() {
    grep -E '^##+ ' "$FILE" | sed 's/^##\+\s*//'
}

show_titles_and_descriptions() {
    awk '
    /^##+ / {
        if (block) print block "\n";
        title = $0;
        block = title;
        next;
    }
    NF {
        block = block "\n" $0;
    }
    END {
        if (block) print block;
    }' "$FILE"
}

search_title() {
    keyword="$1"
    verbose="$2"
    if [ -z "$keyword" ]; then
        echo "Please provide a keyword to search."
        exit 1
    fi

    awk -v keyword="$keyword" -v verbose="$verbose" '
    BEGIN { IGNORECASE=1 }
/^##+ / {
    if (block && title ~ keyword) {
        print block "\n";
    }
    title = $0;
    block = title;
    collecting = 1;
    next;
}
/^```/ {
    if (collecting) {
        block = block "\n" $0;
        in_code = !in_code;
    }
    next;
}
NF && collecting {
    if (in_code || verbose == "true") {
        block = block "\n" $0;
    }
}
END {
    if (block && title ~ keyword) print block;
}' "$FILE"
}

usage() {
    echo "Usage: $0 [option] [keyword]"
    echo "Options:"
    echo "  --titles                       Show all technique titles"
    echo "  --titles-and-desc             Show all titles with their descriptions"
    echo "  --search <keyword> [--verbose] Search technique titles and show matches"
    exit 1
}

case "$1" in
    --titles)
        show_titles
        ;;
    --titles-and-desc)
        show_titles_and_descriptions
        ;;
    --search)
        keyword="$2"
        verbose_flag="$3"
        if [ "$verbose_flag" = "--verbose" ]; then
            search_title "$keyword" "true"
        else
            search_title "$keyword" "false"
        fi
        ;;
    *)
        usage
        ;;
esac
