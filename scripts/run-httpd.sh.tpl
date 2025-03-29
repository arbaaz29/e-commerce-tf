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
    # Customize the secret-id as per your naming convention in Secrets Manager
    DB_CREDENTIALS=$(aws secretsmanager get-secret-value \
        --secret-id "${basename}/database-credentials-${secretnumber}" \
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

# # Install Composer
# export COMPOSER_HOME="$HOME/.composer"
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  || handle_error "unable to download composer"
# php composer-setup.php || handle_error "composer not installed"
# php -r "unlink('composer-setup.php');"  || handle_error "cannot unlink the composer"

# # Move Composer to binaries for it to be available in the path
# if [ -f composer.phar ]; then
#     sudo mv composer.phar /usr/local/bin/composer
# else
#     handle_error "Composer installation failed"
# fi

# Verify if Composer has been installed properly
composer --version

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || handle_error "Failed to download AWS CLI"
unzip awscliv2.zip || handle_error "Failed to unzip AWS CLI"
sudo ./aws/install || handle_error "Failed to install AWS CLI"

# Start and enable Apache
sudo systemctl start apache2 || handle_error "Failed to start Apache"
sudo systemctl enable apache2 || handle_error "Failed to enable Apache"

# Modify configuration to launch PHP first
echo "
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
" | sudo tee /etc/apache2/mods-enabled/dir.conf > /dev/null || handle_error "Failed to replace config file"

# Restart Apache
sudo systemctl restart apache2 || handle_error "Failed to restart Apache"

# # Remove the default index.html
# sudo rm -rf /var/www/html/index.html || handle_error "Failed to delete index"

# # Download and move the application
# git clone https://github.com/edaviage/818N-E_Commerce_Application.git || handle_error "Unable to download GitHub repo"

# cd 818N-E_Commerce_Application || handle_error "Failed to change directory to 818N-E_Commerce_Application"

# sudo mv * /var/www/html || handle_error "Unable to move the repo"
# # Verify critical files exist
# if [ ! -f /var/www/html/index.php ]; then
#     handle_error "Critical files missing after move operation"
# fi

# Clone the Git repository for the database schema
git clone https://github.com/arbaaz29/e-commerce-db.git || handle_error "Failed to clone repository"
cd e-commerce-db || handle_error "Failed to change directory to e-commerce-db"

# Verify repository contents
[ -f ecommerce_1.sql ] || handle_error "SQL file ecommerce_1.sql not found in repository"

# Download RDS SSL certificate
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || handle_error "Failed to download RDS SSL certificate"

# Retrieve database credentials from Secrets Manager
get_db_credentials

# Load SQL data into the database
mysql -h "$MYSQLENDPOINT" -u "$SQLUSER" \
    --ssl-ca=global-bundle.pem \
    --ssl-mode=REQUIRED \
    -p"$ECOMDBPASSWD" \
    "$db" < ecommerce_1.sql || handle_error "Failed to import SQL data to database"

# Final success message
echo "Deployment completed successfully at $(date)"

# Move to the includes directory
# cd /var/www/html/includes/ && composer require aws/aws-sdk-php && wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || handle_error "Unable to move to directory"

# composer require aws/aws-sdk-php || handle_error "AWS SDK not installed"

# wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

# # Create connect.php for DB connection
# cat <<EOF | sudo tee ./connect.php > /dev/null || handle_error "Failed to replace connect file"
# <?php
# require 'vendor/autoload.php';

# use Aws\SecretsManager\SecretsManagerClient;
# use Aws\Exception\AwsException;

# function handle_error(\$message) {
#     echo "ERROR: \$message\n";
#     exit(1);
# }

# try {
#     // Initialize variables
#     \$basename = "your-basename"; // Replace with your actual basename
#     \$secretnumber = "your-secretnumber"; // Replace with your actual secret number
#     \$secretId = "\${basename}/database-credentials-\${secretnumber}";
    
#     // Create SecretsManager client
#     \$client = new SecretsManagerClient([
#         'region' => 'us-east-1', // Replace with your AWS region
#         'version' => 'latest'
#     ]);
    
#     // Get secret value
#     \$result = \$client->getSecretValue([
#         'SecretId' => \$secretId,
#     ]);
    
#     // Get the secret string
#     if (isset(\$result['SecretString'])) {
#         \$dbCredentials = \$result['SecretString'];
        
#         // Parse JSON credentials
#         \$credentials = json_decode(\$dbCredentials, true);
#         \$endpoint = \$credentials['endpoint'];
#         \$sqlusername = \$credentials['username'];
#         \$password = \$credentials['password'];
#         \$db = \$credentials['db'];
        
#         // Debugging: Print out retrieved values (remove in production)
#         echo "Endpoint: \$endpoint\n";
#         echo "Username: \$sqlusername\n";
#         echo "dbname: \$db\n";
        
#         // SSL Configuration
#         \$sslCaPath = 'global-bundle.pem';
        
#         // Initialize MySQL connection
#         \$mysqli = mysqli_init();
        
#         // Configure SSL
#         mysqli_ssl_set(\$mysqli, NULL, NULL, \$sslCaPath, NULL, NULL);
        
#         // Set option to verify server certificate
#         \$mysqli->options(MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);
        
#         // Establish connection with SSL
#         if (!\$mysqli->real_connect(\$endpoint, \$sqlusername, \$password, \$db, 3306, NULL, MYSQLI_CLIENT_SSL)) {
#             die('Connect Error (' . \$mysqli->connect_errno . ') ' . \$mysqli->connect_error);
#         }
        
#         echo "Connected successfully using SSL/TLS!";
        
#         // Now you can perform your database operations
#         // ...
        
#         // Close connection when done
#         \$mysqli->close();
#     }
    
# } catch (Exception \$e) {
#     echo "Error: " . \$e->getMessage();
# }
# ?>
# EOF

# # Final success message
# echo "PHP app deployed at $(date)"

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
