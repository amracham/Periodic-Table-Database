#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

escaped_input=$(printf "%s" "$1" | sed "s/'/''/g")
query="SELECT e.atomic_number, e.name, e.symbol, trim(trailing '.' FROM trim(trailing '0' FROM to_char(p.atomic_mass, 'FM9999990.9999'))) AS atomic_mass, t.type, trim(trailing '.' FROM trim(trailing '0' FROM to_char(p.melting_point_celsius, 'FM9999990.9999'))) AS melting_point_celsius, trim(trailing '.' FROM trim(trailing '0' FROM to_char(p.boiling_point_celsius, 'FM9999990.9999'))) AS boiling_point_celsius FROM elements e JOIN properties p ON p.atomic_number = e.atomic_number JOIN types t ON t.type_id = p.type_id WHERE CAST(e.atomic_number AS TEXT) = '$escaped_input' OR LOWER(e.symbol) = LOWER('$escaped_input') OR LOWER(e.name) = LOWER('$escaped_input');"
result=$(psql -X -U postgres -d periodic_table -t -A -c "$query")

if [[ -z "$result" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r atomic_number name symbol atomic_mass type melting_point boiling_point <<< "$result"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" "$atomic_number" "$name" "$symbol" "$type" "$atomic_mass" "$name" "$melting_point" "$boiling_point"
