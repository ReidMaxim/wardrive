#!/bin/bash
# wigle_signal_profiler.sh
# Description:
# Analyzes WiGLE CSV export data to profile nearby wireless networks.
# The script parses each network entry, categorizes it by security type
# (open vs secured) and by network type (ISP, private/home, unknown),
# then outputs a summarized report of findings.

# Constructs Used:
# - Function (analyze_file)
# - Loop (while read for CSV parsing)
# - Case Statement (network classification and security detection)
# - String Parsing (IFS for CSV parsing, pattern matching with wildcards)
# - Conditional Statements (file existence check)
# - Process Substitution (tail -n +2 to skip CSV header)

# Dependencies / Requirements:
# - Bash shell
# - Valid WiGLE CSV export file as input
# - Read permissions for the provided file

# --- FUNCTION ---
analyze_file() {
    local file=$1

    # Enable case-insensitive matching
    shopt -s nocasematch

    total=0
    open_count=0
    secure_count=0

    isp_count=0
    private_count=0
    unknown_count=0

    # Read file (skip header)
    while IFS=',' read -r mac ssid auth rest; do
        ((total++))

        # --- SECURITY TYPE ---
        case $auth in
            *WEP*|*WPA*|*WPA2*|*WPA3*)
                ((secure_count++))
                ;;
            *)
                ((open_count++))
                ;;
        esac

        # --- NETWORK TYPE ---
        case $ssid in
            # ISP networks
            *xfinity*|*spectrum*|*att*|*verizon*|*cox*|*optimum*)
                ((isp_count++))
                ;;

            # Home / personal networks
            *netgear*|*linksys*|*tp-link*|*tplink*|*dlink*|*router*|*wifi*|*home*|*5g*|*iphone*|*android*|*galaxy*|*pixel*)
                ((private_count++))
                ;;

            # Everything else
            *)
                ((unknown_count++))
                ;;
        esac

    done < <(tail -n +2 "$file")

    # --- OUTPUT ---
    echo "=== SIGNAL PROFILE REPORT ==="
    echo "Total Networks: $total"
    echo ""

    echo "Security Breakdown:"
    echo "- Open Networks: $open_count"
    echo "- Secured Networks: $secure_count"
    echo ""

    echo "Network Types:"
    echo "- ISP Networks: $isp_count"
    echo "- Private/Home Networks: $private_count"
    echo "- Unknown: $unknown_count"
}

# --- MAIN ---
read -p "Enter WiGLE CSV file: " file

if [[ ! -f "$file" ]]; then
    echo "[!] File not found."
    exit 1
fi

analyze_file "$file"
