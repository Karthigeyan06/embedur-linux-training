

ERROR_LOG="errors.log"


show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search
  -f <file>        Search directly in a file
  -h               Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 -h
EOF
}


log_error() {
    echo "Error: $1" | tee -a "$ERROR_LOG" >&2
}

search_directory() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            search_directory "$item" "$keyword"
        elif [[ -f "$item" ]]; then
            grep -H "$keyword" "$item"
        fi
    done
}


validate_inputs() {

    
    if [[ -z "$KEYWORD" || ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
        log_error "Invalid or empty keyword."
        exit 1
    fi

    
    if [[ -n "$FILE" && ! -f "$FILE" ]]; then
        log_error "File does not exist: $FILE"
        exit 1
    fi

    
    if [[ -n "$DIR" && ! -d "$DIR" ]]; then
        log_error "Directory does not exist: $DIR"
        exit 1
    fi
}


while getopts ":d:k:f:h" opt; do
    case $opt in
        d) DIR="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        h) show_help; exit 0 ;;
        \?) log_error "Invalid option: -$OPTARG"; exit 1 ;;
        :) log_error "Option -$OPTARG requires an argument."; exit 1 ;;
    esac
done

validate_inputs

echo "Script Name: $0"
echo "Process ID: $$"
echo "Arguments Count: $#"
echo "All Arguments: $@"

if [[ -n "$DIR" && -n "$KEYWORD" ]]; then
    search_directory "$DIR" "$KEYWORD"

elif [[ -n "$FILE" && -n "$KEYWORD" ]]; then
    
    grep "$KEYWORD" <<< "$(cat "$FILE")"

else
    log_error "Invalid usage. Use -h for help."
    exit 1
fi
