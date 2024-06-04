# dumper.sh
maas login admin http://localhost:5240/MAAS `sudo maas apikey --username REDACTED`
machines=$(maas admin machines read | jq -r '[.[] | {power_type: .power_type, system_id: .system_id, architecture: .architecture, mac_address: .boot_interface.mac_address, hostname: .hostname}]')

get_power_parameters() {
          local system_id=$1
          maas admin machine power-parameters "$system_id"
}

machines_with_pp=$(echo "$machines" | jq -c '.[]' | while read -r item; do
        system_id=$(echo "$item" | jq -r '.system_id')
        power_parameters=$(get_power_parameters "$system_id")
        echo "$item" | jq --argjson pp "$power_parameters" '. + {power_parameters: $pp}'
        done | jq -s '.')

echo "$machines_with_pp" > /tmp/dump.json
