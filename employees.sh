#!/bin/bash
EMPLOYEES_FILE="$HOME/.employees.txt"
echo "$(date): ADDED - $*" >> "$HOME/.employees.log"

sort_employees() {
    if [ -s "$EMPLOYEES_FILE" ]; then
        local sorted
        sorted=$(sort "$EMPLOYEES_FILE")
        echo "$sorted" > "$EMPLOYEES_FILE"
    fi
}

add_employee() {
    if [ -z "$1" ]; then
        echo "Please provide employee name."
        exit 1
    fi
    touch "$EMPLOYEES_FILE"
    echo "$*" >> "$EMPLOYEES_FILE"
    sort_employees
    echo "Employee added."
}

list_employees() {
    if [ ! -s "$EMPLOYEES_FILE" ]; then
        echo "No employees found."
        exit 0
    fi
    nl -w2 -s'. ' "$EMPLOYEES_FILE"
}

remove_employee() {
    if [ -z "$1" ]; then
        echo "Please provide employee number."
        exit 1
    fi
    if [ ! -s "$EMPLOYEES_FILE" ]; then
        echo "No employees found."
        exit 1
    fi
    local total
    total=$(wc -l < "$EMPLOYEES_FILE")
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt "$total" ]; then
        echo "Invalid employee number: $1"
        exit 1
    fi
    sed -i "${1}d" "$EMPLOYEES_FILE"
    sort_employees
    echo "Employee dismissed."
}

edit_employee() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 edit <employee number> \"new employee name\""
        exit 1
    fi
    local line_number="$1"
    shift
    local new_entry="$*"
    if [ ! -s "$EMPLOYEES_FILE" ]; then
        echo "No employees found."
        exit 1
    fi
    local total
    total=$(wc -l < "$EMPLOYEES_FILE")
    if ! [[ "$line_number" =~ ^[0-9]+$ ]] || [ "$line_number" -lt 1 ] || [ "$line_number" -gt "$total" ]; then
        echo "Invalid employee number: $line_number"
        exit 1
    fi
    # Escape forward slashes and backslashes in the new entry for sed
    local escaped_entry
    escaped_entry=$(echo "$new_entry" | sed 's/[\/&]/\\&/g')
    sed -i "${line_number}s/.*/${escaped_entry}/" "$EMPLOYEES_FILE"
    sort_employees
    echo "Employee updated."
}

case "$1" in
    add)
        shift
        add_employee "$@"
        ;;
    list)
        list_employees
        ;;
    remove)
        shift
        remove_employee "$1"
        ;;
    edit)
        shift
        edit_employee "$@"
        ;;
    *)
        echo "Usage:"
        echo "  $0 add \"employee name\""
        echo "  $0 list"
        echo "  $0 remove <employee number>"
        echo "  $0 edit <employee number> \"new employee name\""
        ;;
esac