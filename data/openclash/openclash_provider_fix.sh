    # ============================================================
    # Fix: ISP SNI-blocking + Provider UA consistency
    #
    # Phase 1: Extract domains from providers with proxy: DIRECT
    # Phase 2: Test each domain (mihomo not running yet, direct
    #          test is reliable); only flag truly blocked ones
    # Phase 3: Remove proxy:DIRECT only for blocked domains,
    #          inject sub_ua header for all http providers
    # ============================================================
    SUB_UA=$(uci -q get openclash.@config_subscribe[0].sub_ua 2>/dev/null)
    [ -z "$SUB_UA" ] && SUB_UA="clash.meta"
    echo "${LOGTIME} Tip: Provider fix starting (sub_ua: $SUB_UA)..." >> $LOG_FILE

    # Phase 1: Extract unique HTTPS domains with proxy: DIRECT
    PROVIDER_DOMAINS=$(ruby -ryaml -E UTF-8 -e "
       begin
          v = YAML.load_file('$CONFIG_FILE')
       rescue => e
          STDERR.puts e.message
          exit 1
       end
       exit 0 unless v.is_a?(Hash)
       seen = {}
       ['proxy-providers', 'rule-providers'].each do |section|
          next unless v.key?(section) and v[section].is_a?(Hash)
          v[section].each do |name, cfg|
             next unless cfg.is_a?(Hash) and cfg['type'] == 'http'
             next unless cfg['proxy'] == 'DIRECT'
             url = cfg['url'].to_s
             next unless url.start_with?('https://')
             m = url.match(%r{https?://([^/:]+)})
             next unless m
             d = m[1]
             unless seen[d]
                puts d
                seen[d] = true
             end
          end
       end
    " 2>/dev/null)
    PHASE1_RC=$?

    if [ "$PHASE1_RC" -ne 0 ]; then
        echo "${LOGTIME} Warning: Provider fix Phase 1 failed to parse config (exit $PHASE1_RC), skipping ISP test" >> $LOG_FILE
    fi

    # Phase 2: Test each domain for ISP blocking
    # curl exit 35 = TLS reset (SNI blocked), 28 = timeout (possibly blocked)
    BLOCK_TMP="/tmp/openclash_blocked_domains.$$"
    : > "$BLOCK_TMP"
    if [ -n "$PROVIDER_DOMAINS" ]; then
        DOMAIN_COUNT=$(echo "$PROVIDER_DOMAINS" | wc -l | tr -d ' ')
        echo "${LOGTIME} Tip: Found $DOMAIN_COUNT domain(s) with proxy: DIRECT, testing connectivity..." >> $LOG_FILE
        echo "$PROVIDER_DOMAINS" | while IFS= read -r domain; do
            [ -z "$domain" ] && continue
            curl -sS -o /dev/null --connect-timeout 3 -m 5 "https://${domain}/" 2>/dev/null
            ec=$?
            if [ "$ec" = "35" ] || [ "$ec" = "28" ]; then
                echo "$domain" >> "$BLOCK_TMP"
                echo "${LOGTIME} [ISP Block Test] ${domain} BLOCKED (curl exit $ec)" >> $LOG_FILE
            else
                echo "${LOGTIME} [ISP Block Test] ${domain} reachable (curl exit $ec), keeping proxy: DIRECT" >> $LOG_FILE
            fi
        done
    else
        echo "${LOGTIME} Tip: No providers with proxy: DIRECT found, skipping ISP block test" >> $LOG_FILE
    fi
    BLOCKED_LIST=$(tr '\n' ',' < "$BLOCK_TMP" 2>/dev/null | sed 's/,$//')
    rm -f "$BLOCK_TMP"

    # Phase 3: Modify YAML - remove proxy:DIRECT for blocked domains, inject UA
    ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
       begin
          Value = YAML.load_file('$CONFIG_FILE');
       rescue Exception => e
          puts '${LOGTIME} Error: Provider fix failed to load config,【' + e.message + '】';
          exit;
       end;

       unless Value.is_a?(Hash)
          puts '${LOGTIME} Warning: Provider fix skipped, config root is not a YAML mapping';
          exit;
       end

       begin
       sub_ua = '$SUB_UA'
       blocked = '$BLOCKED_LIST'.split(',').reject(&:empty?)
       removed = []
       ua_injected = 0
       Thread.new{
          ['proxy-providers', 'rule-providers'].each do |section|
             next unless Value.key?(section) and Value[section].is_a?(Hash)
             Value[section].each do |name, provider|
                next unless provider.is_a?(Hash) and provider['type'] == 'http'
                if provider['proxy'] == 'DIRECT' and not blocked.empty?
                   domain = (provider['url'].to_s.match(%r{https?://([^/:]+)}) || [])[1]
                   if domain and blocked.include?(domain)
                      provider.delete('proxy')
                      removed << name
                   end
                end
                unless provider.key?('header') and provider['header'].is_a?(Hash) and provider['header'].key?('User-Agent')
                   provider['header'] = {} unless provider['header'].is_a?(Hash)
                   provider['header']['User-Agent'] = [sub_ua]
                   ua_injected += 1
                end
             end
          end
       }.join;

       parts = []
       if removed.empty?
          parts << 'no blocked domains'
       else
          parts << 'removed DIRECT for: ' + removed.join(', ')
       end
       parts << 'UA set on ' + ua_injected.to_s + ' provider(s)'
       puts '${LOGTIME} Tip: Provider fix done (' + parts.join('; ') + ')';

       rescue Exception => e
          puts '${LOGTIME} Error: Provider fix failed,【' + e.message + '】';
       ensure
          File.open('$CONFIG_FILE','w') {|f| YAML.dump(Value, f)} if Value.is_a?(Hash);
       end" 2>/dev/null >> $LOG_FILE

