set -x 

maas login admin http://localhost:5240/MAAS `sudo maas apikey --username REDACTED`

create_machine() {
  local architecture=$1
  local mac_address=$2
  local hostname=$3
  local power_type=$4
  shift 4
  local power_params=("$@")
  local power_params_str=$(IFS=" " ; echo "${power_params[*]}")

  maas admin machines create commission=false architecture="$architecture" mac_addresses="$mac_address" hostname="$hostname" power_type="$power_type" $power_params_str

}

updated_json=$(cat /tmp/dump.json)

echo "$updated_json" | jq -c '.[]' | while read -r item; do
  architecture=$(echo "$item" | jq -r '.architecture')
  mac_address=$(echo "$item" | jq -r '.mac_address')
  hostname=$(echo "$item" | jq -r '.hostname')
  power_type=$(echo "$item" | jq -r '.power_type')
  power_parameters=$(echo "$item" | jq -r '
    .power_parameters | to_entries[] | 
    if (.value | type == "array") then
      "power_parameters_\(.key)=" + (.value[0] | tostring)
    else
      "power_parameters_\(.key)=\(.value)"
    end
  ')
  power_params_array=($power_parameters)

  if [ "$power_type" = "ipmi" ]; then
    workaround_flag_present=false
    for param in "${power_params_array[@]}"; do
      if [[ "$param" =~ "power_parameters_workaround_flags" ]]; then
        workaround_flag_present=true
        break
      fi
    done

    if [ "$workaround_flag_present" = false ]; then
      power_params_array+=("power_parameters_workaround_flags=")
    fi
  fi

  create_machine "$architecture" "$mac_address" "$hostname" "$power_type" "${power_params_array[@]}"
done
