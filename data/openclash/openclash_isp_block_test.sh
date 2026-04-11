#!/bin/sh
# openclash_isp_block_test.sh
#
# Scan all OpenClash config files and test whether proxy-provider /
# rule-provider URLs are reachable via direct connection.
# A TLS handshake failure (curl error 35) strongly indicates
# ISP-level SNI blocking.
#
# Usage:
#   sh /usr/share/openclash/openclash_isp_block_test.sh
#   sh /usr/share/openclash/openclash_isp_block_test.sh /etc/openclash/config/specific.yaml

CONFIG_DIR="/etc/openclash/config"
TIMEOUT=10

RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[0;33m')
CYAN=$(printf '\033[0;36m')
NC=$(printf '\033[0m')

print_header() {
    echo ""
    echo "============================================"
    echo "  OpenClash Provider URL ISP Block Tester"
    echo "============================================"
    echo ""
}

test_url() {
    local url="$1"
    local name="$2"
    local section="$3"
    local config="$4"

    local domain
    domain=$(echo "$url" | sed -E 's|https?://([^/:]+).*|\1|')

    printf "  %-20s %-30s " "[$name]" "$domain"

    local result
    result=$(curl -sS -o /dev/null -w "%{http_code}|%{ssl_verify_result}|%{time_connect}" \
        --connect-timeout "$TIMEOUT" -m "$TIMEOUT" "$url" 2>&1)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        local http_code
        http_code=$(echo "$result" | cut -d'|' -f1)
        printf "${GREEN}OK${NC} (HTTP %s)\n" "$http_code"
        return 0
    elif [ $exit_code -eq 35 ]; then
        printf "${RED}BLOCKED${NC} (TLS reset - likely SNI blocked)\n"
        return 1
    elif [ $exit_code -eq 28 ]; then
        printf "${RED}TIMEOUT${NC} (connection timed out)\n"
        return 2
    elif [ $exit_code -eq 6 ]; then
        printf "${YELLOW}DNS FAIL${NC} (cannot resolve $domain)\n"
        return 3
    elif [ $exit_code -eq 7 ]; then
        printf "${RED}REFUSED${NC} (connection refused)\n"
        return 4
    else
        local errmsg
        errmsg=$(echo "$result" | tail -1)
        printf "${YELLOW}ERROR${NC} (curl exit %d: %s)\n" "$exit_code" "$errmsg"
        return 5
    fi
}

scan_config() {
    local config_file="$1"
    local basename
    basename=$(basename "$config_file")

    printf "%sConfig: %s%s\n" "$CYAN" "$basename" "$NC"
    echo "--------------------------------------------"

    if ! command -v ruby >/dev/null 2>&1; then
        echo "  Error: ruby not found, cannot parse YAML"
        return 1
    fi

    local urls
    urls=$(ruby -ryaml -E UTF-8 -e "
        begin
            v = YAML.load_file('$config_file');
        rescue => e
            STDERR.puts 'Parse error: ' + e.message
            exit 1
        end
        ['proxy-providers', 'rule-providers'].each do |section|
            next unless v.is_a?(Hash) and v.key?(section) and v[section].is_a?(Hash)
            v[section].each do |name, cfg|
                next unless cfg.is_a?(Hash) and cfg['type'] == 'http' and cfg['url'].is_a?(String)
                url = cfg['url'].strip
                next if url.empty?
                proxy = cfg['proxy'] || '(rule-routing)'
                puts \"#{section}\t#{name}\t#{url}\t#{proxy}\"
            end
        end
    " 2>/dev/null)

    if [ -z "$urls" ]; then
        echo "  (no http providers found)"
        echo ""
        return 0
    fi

    local total=0 blocked=0 ok=0 other=0
    local seen_domains=""

    echo "$urls" | while IFS="$(printf '\t')" read -r section name url proxy; do
        local domain
        domain=$(echo "$url" | sed -E 's|https?://([^/:]+).*|\1|')

        if echo "$seen_domains" | grep -qF "$domain"; then
            printf "  %-20s %-30s ${CYAN}SKIP${NC} (same domain already tested)\n" "[$name]" "$domain"
            continue
        fi
        seen_domains="$seen_domains $domain"

        total=$((total + 1))
        if [ "$proxy" != "(rule-routing)" ]; then
            printf "  %-20s proxy: ${YELLOW}%s${NC}\n" "" "$proxy"
        fi
        test_url "$url" "$name" "$section" "$config_file"
    done

    echo ""
}

# Main
print_header

if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        scan_config "$1"
    else
        echo "Error: file not found: $1"
        exit 1
    fi
else
    found=0
    for f in "$CONFIG_DIR"/*.yaml "$CONFIG_DIR"/*.yml; do
        [ -f "$f" ] || continue
        found=1
        scan_config "$f"
    done
    if [ "$found" -eq 0 ]; then
        echo "No config files found in $CONFIG_DIR"
        exit 1
    fi
fi

printf "============================================\n"
printf "Result legend:\n"
printf "  %sOK%s       - URL reachable, no blocking\n" "$GREEN" "$NC"
printf "  %sBLOCKED%s  - TLS reset by ISP (SNI blocked)\n" "$RED" "$NC"
printf "  %sTIMEOUT%s  - Connection timed out\n" "$RED" "$NC"
printf "  %sDNS FAIL%s - Domain cannot be resolved\n" "$YELLOW" "$NC"
printf "  %sREFUSED%s  - Connection refused by server\n" "$RED" "$NC"
printf "\n"
printf "If a provider shows BLOCKED, solutions:\n"
printf "  1. Remove 'proxy: DIRECT' from provider config\n"
printf "     (let mihomo route through proxy after cache load)\n"
printf "  2. Use SubConverter without proxy-providers mode\n"
printf "  3. Relay provider URL through SubConverter backend\n"
printf "============================================\n"
