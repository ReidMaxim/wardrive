#!/bin/bash
# stat_helper.sh
# Description: Simple statistics helper that calculates Z-score and
# provides a basic probability interpretation.
# Constructs used: function, case statement, loop, set -u, basic error handling
# Dependencies: awk

set -u  # Treat unset variables as errors

# --- FUNCTION ---
calc_stats() {
    local mean=$1
    local stdv=$2
    local x=$3

    # --- ERROR HANDLING ---
    if [[ "$stdv" == "0" ]]; then
        echo "[!] Standard deviation cannot be 0. Aborting calculation."
        return
    fi

    # Calculate Z-score using awk for floating-point math
    z=$(awk "BEGIN {print ($x - $mean)/$stdv}")

    echo "Z-score: $z"

    # Classify probability (simple ranges) using case
    case $z in
        -*)
            echo "Interpretation: Below average (left side of curve)"
            ;;
        0*)
            echo "Interpretation: Around the mean (~50%)"
            ;;
        1*)
            echo "Interpretation: Above average (~84% to the left)"
            ;;
        2*)
            echo "Interpretation: Very high (~97% to the left)"
            ;;
        *)
            echo "Interpretation: Extreme value"
            ;;
    esac
}

# --- MAIN LOOP ---
while true; do
    echo "=== STAT HELPER ==="

    # Prompt user for mean, standard deviation, and X value
    read -p "Mean: " mean
    read -p "Standard Deviation: " stdv
    read -p "X value: " x

    # Call the function with user input
    calc_stats "$mean" "$stdv" "$x"

    echo ""

    # Ask user if they want to run another calculation
    read -p "Run again? (y/n): " choice
    [[ "$choice" != "y" ]] && break
done

echo "Goodbye!"