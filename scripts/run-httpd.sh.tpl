#!/bin/bash

# Set up logging
LOG_FILE="/var/log/ecommerce-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Error handling function
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Retrieve database credentials from Secrets Manager
get_db_credentials() {
  echo "$secretname"
    # Customize the secret-id as per your naming convention in Secrets Manager
    DB_CREDENTIALS=$(aws secretsmanager get-secret-value \
        --secret-id "${secretname}" \
        --query SecretString \
        --output text) || handle_error "Failed to retrieve database credentials"

    # Parse JSON credentials
    MYSQLENDPOINT=$(echo $DB_CREDENTIALS | jq -r '.endpoint')
    SQLUSER=$(echo $DB_CREDENTIALS | jq -r '.username')
    ECOMDBPASSWD=$(echo $DB_CREDENTIALS | jq -r '.password')
    db=$(echo $DB_CREDENTIALS | jq -r '.db')

    # Debugging: Print out retrieved values (remove in production)
    echo "Endpoint: $MYSQLENDPOINT"
    echo "Username: $SQLUSER"
    echo "dbname: $db"
}

# Update and install necessary packages
sudo apt update -y || handle_error "Failed to update package lists"
sudo apt upgrade -y || handle_error "Failed to upgrade"
sudo apt-get install -y apache2 git mysql-client unzip jq php libapache2-mod-php php-mysql || handle_error "Failed to install required packages"

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || handle_error "Failed to download AWS CLI"
unzip awscliv2.zip || handle_error "Failed to unzip AWS CLI"
sudo ./aws/install || handle_error "Failed to install AWS CLI"

# Start and enable Apache
sudo systemctl start apache2 || handle_error "Failed to start Apache"
sudo systemctl enable apache2 || handle_error "Failed to enable Apache"

# Modify configuration to launch PHP first
cat<<EOF | sudo tee /etc/apache2/mods-enabled/dir.conf > /dev/null 
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF

# Restart Apache
sudo systemctl restart apache2 || handle_error "Failed to restart Apache"

# Remove the default index.html
sudo rm -rf /var/www/html/index.html || handle_error "Failed to delete index"

# Download and move the application
git clone https://github.com/arbaaz29/e-commerce-app.git || handle_error "Unable to download GitHub repo"

cd e-commerce-app || handle_error "Failed to change directory to e-commerce-app"

sudo mv * /var/www/html || handle_error "Unable to move the repo"

# Verify critical files exist
if [ ! -f /var/www/html/index.php ]; then
    handle_error "Critical files missing after move operation"
fi

# Clone the Git repository for the database schema
git clone https://github.com/arbaaz29/e-commerce-db.git || handle_error "Failed to clone repository"

cd e-commerce-db || handle_error "Failed to change directory to e-commerce-db"

# Verify repository contents
[ -f ecommerce_1.sql ] || handle_error "SQL file ecommerce_1.sql not found in repository"

# Download RDS SSL certificate
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || handle_error "Failed to download RDS SSL certificate"

# Retrieve database credentials from Secrets Manager
get_db_credentials

# Check if the database is already configured
DB_CHECK=$(mysql -h "$MYSQLENDPOINT" -u "$SQLUSER" \
    --ssl-ca=global-bundle.pem \
    --ssl-mode=REQUIRED \
    -p"$ECOMDBPASSWD" \
    -D "$db" -e "SHOW TABLES LIKE 'admin_table';" 2>/dev/null)

if [[ -n "$DB_CHECK" ]]; then
    echo "Database is already configured. Skipping SQL import."
else
    echo "Database is empty. Importing SQL data..."
    mysql -h "$MYSQLENDPOINT" -u "$SQLUSER" \
        --ssl-ca=global-bundle.pem \
        --ssl-mode=REQUIRED \
        -p"$ECOMDBPASSWD" \
        "$db" < ecommerce_1.sql || handle_error "Failed to import SQL data to database"
    echo "Database import completed successfully."
fi

#Move to the includes directory
cd /var/www/html/includes/

wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || handle_error "Unable to download certificate"
get_db_credentials
if [ ! -f global-bundle.pem ]; then
    handle_error "Critical pem file missing"
fi
certPath = ./global-bundle.pem
# Create connect.php for DB connection
cat <<EOF | sudo tee ./connect.php > /dev/null || handle_error "Failed to replace connect file"
<?php
\$con = new mysqli('$MYSQLENDPOINT','$SQLUSER','$ECOMDBPASSWD','$db');
if(!\$con){
    die(mysqli_error(\$con));
}
?>
EOF

# Final success message
echo "PHP app configured and deployed at $(date)"

# Install CloudWatch Agent and collectd
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo apt-get update && sudo apt-get install collectd -y

# Create CloudWatch Agent config file with CPU, Memory, Disk, and Network metrics
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/ecommerce-setup.log",
            "log_group_name": "/ecommerce/setup",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          },
          {
            "file_path": "/var/log/apache2/access.log",
            "log_group_name": "/ecommerce/apache-access",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/apache2/error.log",
            "log_group_name": "/ecommerce/apache-error",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "disk_used_percent"
        ],
        "resources": [
          "*"
        ],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "net": {
        "measurement": [
          "bytes_sent",
          "bytes_recv"
        ],
        "resources": [
          "*"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent with the new configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
    -s || handle_error "Failed to start CloudWatch Agent"

echo "CloudWatch Agent installed and configured successfully with CPU and system metrics."
