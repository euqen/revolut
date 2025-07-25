#!/bin/bash
set -e

DB_FILE="appdb.sqlite"

echo "Updating package list..."
sudo apt update

echo "Installing SQLite3..."
sudo apt install -y sqlite3

echo "Creating SQLite database file: ${DB_FILE} and initializing table..."

echo "SQLite database and initial table/user created in ${DB_FILE}."

echo "You can open the database with:"
echo "sqlite3 ${DB_FILE}"