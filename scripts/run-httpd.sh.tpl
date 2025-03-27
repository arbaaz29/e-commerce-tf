#!/bin/bash

# Set up logging
LOG_FILE="/var/log/ecommerce-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Error handling function
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Update and install necessary packages
sudo apt update -y || handle_error "Failed to update package lists"
sudo apt-get install -y apache2 git mysql-client unzip jq || handle_error "Failed to install required packages"

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || handle_error "Failed to download AWS CLI"
unzip awscliv2.zip || handle_error "Failed to unzip AWS CLI"
sudo ./aws/install || handle_error "Failed to install AWS CLI"

# Start and enable Apache
sudo systemctl start apache2 || handle_error "Failed to start Apache"
sudo systemctl enable apache2 || handle_error "Failed to enable Apache"

# Create a simple HTML page
echo "<html>
<head>
  <title> Ubuntu rocks! </title>
</head>
<body>
  <p> I'm running this website on an Ubuntu Server! </p>
</body>
</html>" | sudo tee /var/www/html/index.html > /dev/null || handle_error "Failed to create index.html"

# Restart Apache
sudo systemctl restart apache2 || handle_error "Failed to restart Apache"

# Clone the Git repository
git clone https://github.com/arbaaz29/e-commerce-db.git || handle_error "Failed to clone repository"
cd e-commerce-db || handle_error "Failed to change directory to e-commerce-db"

# Verify repository contents
[ -f ecommerce_1.sql ] || handle_error "SQL file ecommerce_1.sql not found in repository"

# Download RDS SSL certificate
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem || handle_error "Failed to download RDS SSL certificate"

# Retrieve database credentials from Secrets Manager
DB_CREDENTIALS=$(aws secretsmanager get-secret-value \
  --secret-id "${basename}/database-credentials-1" \
  --query SecretString \
  --output text)

# Parse JSON credentials
MYSQLENDPOINT=$(echo $DB_CREDENTIALS | jq -r '.endpoint')
SQLUSER=$(echo $DB_CREDENTIALS | jq -r '.username')
ECOMDBPASSWD=$(echo $DB_CREDENTIALS | jq -r '.password')
db=$(echo $DB_CREDENTIALS | jq -r '.db')

# Debugging: Print out retrieved values (remove in production)
echo "Endpoint: $MYSQLENDPOINT"
echo "Username: $SQLUSER"

# Load SQL data into the database with additional error checking
mysql -h "$MYSQLENDPOINT" -u "$SQLUSER" \
    --ssl-ca=global-bundle.pem \
    --ssl-mode=REQUIRED \
    -p"$ECOMDBPASSWD" \
    "$db" < ecommerce_1.sql || handle_error "Failed to import SQL data to database"

# Final success message
echo "Deployment completed successfully at $(date)"