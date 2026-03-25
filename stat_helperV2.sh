#!/bin/bash
# stat_helper.sh
# Description: Terminal-based statistics helper.
# Prompts for mean, standard deviation, and X value(s).
# Calculates Z-scores and left/right tail probabilities (CDF)
# using Python for accurate math.
# Includes Bash arrays, function, loop, trap, and case.

set -u
trap "echo -e '\n[!] Script interrupted. Exiting...'; exit 1" SIGINT

# -----------------------
# Function: calc_stats
# Arguments: mean, std dev, X values
# Uses Python for Z-score and CDF calculation
# -----------------------
calc_stats() {
    local mean=$1
    local stdv=$2
    shift 2
    local x_values=("$@")

    # Join array with commas for Python list
    local x_string=$(IFS=, ; echo "${x_values[*]}")

    python3 - <<END
import math

mean = $mean
stdv = $stdv
x_values = [$x_string]

for x in x_values:
    z = (x - mean) / stdv
    left = 0.5 * (1 + math.erf(z / math.sqrt(2)))
    right = 1 - left

    print(f"\n--- Analysis for X = {x} ---")
    print(f"Z-score: {z:.4f}")
    print(f"Left (P(X ≤ x)) = {left:.6f}")
    print(f"Right (P(X > x)) = {right:.6f}")

    # Bash-style case interpretation
    if z < -2:
        result = "FAR BELOW the mean"
    elif -2 <= z < 0:
        result = "BELOW the mean"
    elif z == 0:
        result = "AT the mean"
    elif 0 < z <= 2:
        result = "ABOVE the mean"
    else:
        result = "FAR ABOVE the mean"
    print(f"Interpretation: {result}")
END
}

# -----------------------
# Main Loop
# -----------------------
while true; do
    echo "=== STAT HELPER ==="

    # Prompt for mean and standard deviation
    read -p "Mean: " mean
    read -p "Standard Deviation: " stdv

    # Prompt for X values (1 or more)
    read -p "Enter X value(s) separated by space: " -a x_array
    if (( ${#x_array[@]} == 0 )); then
        echo "[!] Please enter at least one X value."
        continue
    fi

    # Call the calculation function
    calc_stats "$mean" "$stdv" "${x_array[@]}"

    # Prompt to run again
    echo ""
    read -p "Run again? (y/n): " choice
    [[ "$choice" != "y" ]] && break
done

echo "Goodbye!"
