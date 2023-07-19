#!/usr/bin/env bash

# Objective:
# Migrate postgres data from one database to another using pg_dump and psql

# Author:
#   Name: Fred Shema

# Usage:
#   1. Run the script
#   2. Enter in the required values
#   3. Wait for the script to complete

# Color constants
COLOR_OFF='\033[0m'
ERROR_COLOR='\033[48;5;124m'
WARNING_COLOR='\033[48;5;94m'
INFO_COLOR='\033[48;5;25m'
SUCCESS_COLOR='\033[48;5;46m'

# Import .env file if it exists
if [ -f ".env" ]; then
    source .env

    # Extract environment variables from .env file
    if [ -n "$SOURCE_DB_NAME" ]; then
        source_db_name=$(grep -oP '(?<=SOURCE_DB_NAME=).+' .env)
    fi

    if [ -n "$SOURCE_DB_HOST" ]; then
        source_db_host=$(grep -oP '(?<=SOURCE_DB_HOST=).+' .env)
    fi

    if [ -n "$SOURCE_DB_PORT" ]; then
        source_db_port=$(grep -oP '(?<=SOURCE_DB_PORT=).+' .env)
    fi

    if [ -n "$SOURCE_DB_USER" ]; then
        source_db_user=$(grep -oP '(?<=SOURCE_DB_USER=).+' .env)
    fi

    if [ -n "$SOURCE_DB_PASSWORD" ]; then
        source_db_password=$(grep -oP '(?<=SOURCE_DB_PASSWORD=).+' .env)
    fi

    if [ -n "$TARGET_DB_NAME" ]; then
        target_db_name=$(grep -oP '(?<=TARGET_DB_NAME=).+' .env)
    fi

    if [ -n "$TARGET_DB_HOST" ]; then
        target_db_host=$(grep -oP '(?<=TARGET_DB_HOST=).+' .env)
    fi

    if [ -n "$TARGET_DB_PORT" ]; then
        target_db_port=$(grep -oP '(?<=TARGET_DB_PORT=).+' .env)
    fi

    if [ -n "$TARGET_DB_USER" ]; then
        target_db_user=$(grep -oP '(?<=TARGET_DB_USER=).+' .env)
    fi

    if [ -n "$TARGET_DB_PASSWORD" ]; then
        target_db_password=$(grep -oP '(?<=TARGET_DB_PASSWORD=).+' .env)
    fi
else
    echo -e "${WARNING_COLOR}Continuing without .env file! Enter in the required values below.${COLOR_OFF}"
fi

# Request for the source database name
if [ -z "$source_db_name" ]; then
    read -p 'Enter the source database name: ' source_db_name
fi

# Request for the source database host default is localhost
if [ -z "$source_db_host" ]; then
    read -p 'Enter the source database host (localhost): ' source_db_host
    if [ -z "$source_db_host" ]; then
        source_db_host="localhost"
    fi
fi

# Request for the source database port default is 5432
if [ -z "$source_db_port" ]; then
    read -p 'Enter the source database port (5432): ' source_db_port
    if [ -z "$source_db_port" ]; then
        source_db_port="5432"
    fi
fi

# Request for the source database username
if [ -z "$source_db_user" ]; then
    read -p 'Enter the source database username: ' source_db_user
fi

# Request for the source database password
if [ -z "$source_db_password" ]; then
    read -sp 'Enter the source database password: ' source_db_password
fi

# Request for the target database name
if [ -z "$target_db_name" ]; then
    read -p 'Enter the target database name: ' target_db_name
fi

# Request for the target database host default is localhost
if [ -z "$target_db_host" ]; then
    read -p 'Enter the target database host (localhost): ' target_db_host
    if [ -z "$target_db_host" ]; then
        target_db_host="localhost"
    fi
fi

# Request for the target database port default is 5432
if [ -z "$target_db_port" ]; then
    read -p 'Enter the target database port (5432): ' target_db_port
    if [ -z "$target_db_port" ]; then
        target_db_port="5432"
    fi
fi

# Request for the target database username
if [ -z "$target_db_user" ]; then
    read -p 'Enter the target database username: ' target_db_user
fi

# Request for the target database password
if [ -z "$target_db_password" ]; then
    read -sp 'Enter the target database password: ' target_db_password
fi

excluded_tables=()

excluded_tables_string=""

# Form the excluded tables string
for table in "${excluded_tables[@]}"; do
    excluded_tables_string+="--exclude-table-data=${table} "
done

# Validate data provided by the user
if [ -z "$source_db_name" ] || [ -z "$source_db_host" ] || [ -z "$source_db_port" ] || [ -z "$source_db_user" ] || [ -z "$source_db_password" ] || [ -z "$target_db_name" ] || [ -z "$target_db_host" ] || [ -z "$target_db_port" ] || [ -z "$target_db_user" ] || [ -z "$target_db_password" ]; then
    echo -e "${ERROR_COLOR}One or more of the required values are empty. Please try again.${COLOR_OFF}"
    exit 1
fi

# Remove any existing dump file associated with the source database
if [ -f "${source_db_name}_dump.sql" ]; then
    echo -e "${INFO_COLOR}Removing ${source_db_name}_dump.sql...${COLOR_OFF}"
    rm ${source_db_name}_dump.sql
fi

# Build the source database connection string
source_db_connection_string="postgresql://${source_db_user}:${source_db_password}@${source_db_host}:${source_db_port}/${source_db_name}"

# Build the target database connection string
target_db_connection_string="postgresql://${target_db_user}:${target_db_password}@${target_db_host}:${target_db_port}/${target_db_name}"

echo -e "${INFO_COLOR}Migrating data from ${source_db_name} to ${target_db_name}...${COLOR_OFF}"

# Dump the source database to a file
pg_dump -c --no-owner --no-acl --format=plain --encoding=UTF-8 --schema=public --no-privileges --no-tablespaces --no-unlogged-table-data --no-security-labels --verbose --dbname="${source_db_connection_string}" --verbose ${excluded_tables_string} --file="${source_db_name}_dump.sql"

if [ -f "${source_db_name}_dump.sql" ]; then
    echo -e "${INFO_COLOR}Restoring ${source_db_name}_dump.sql to ${target_db_name}...${COLOR_OFF}"

    # Restore the target database from the dump file
    psql --dbname="${target_db_connection_string}" --file="${source_db_name}_dump.sql"

    echo -e "${INFO_COLOR}Removing ${source_db_name}_dump.sql...${COLOR_OFF}"
    # Remove the dump file
    rm ${source_db_name}_dump.sql

    echo -e "${SUCCESS_COLOR}Migration complete!${COLOR_OFF}"
else
    echo -e "${ERROR_COLOR}${source_db_name}_dump.sql does not exist. Migration failed!${COLOR_OFF}"
fi

exit 1
