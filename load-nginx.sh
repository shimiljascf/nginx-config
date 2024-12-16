#!/bin/bash

# Variables
REPO_URL="https://github.com/shimiljascf/nginx-config.git"
CLONE_DIR="/tmp/nginx-config"
CONFIG_FILE="nginx.conf"
NGINX_CONF_DIR="/etc/nginx/sites-enabled"

# Clone or pull the latest configuration
if [ -d "$CLONE_DIR" ]; then
    echo "Updating repository from GitHub..."
    git -C $CLONE_DIR pull
else
    echo "Cloning repository from GitHub..."
    git clone $REPO_URL $CLONE_DIR
fi

# Check if the configuration file exists
if [ ! -f "$CLONE_DIR/$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE not found in repository."
    exit 1
fi

# Move the configuration file to Nginx configuration directory
echo "Updating Nginx configuration..."
cp $CLONE_DIR/$CONFIG_FILE $NGINX_CONF_DIR/$CONFIG_FILE

# Test Nginx configuration for syntax errors
echo "Testing Nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Reverting changes."
    exit 1
fi

# Reload Nginx to apply the changes
echo "Reloading Nginx..."
systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "Nginx reloaded successfully with the new configuration."
else
    echo "Failed to reload Nginx. Please check the logs for details."
    exit 1
fi
