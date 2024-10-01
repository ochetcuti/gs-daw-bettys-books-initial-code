#!/usr/bin/expect

# Arguments: Private key path, repository URL, deployment directory, deployment name, branch name, server username, server ID
set private_key_path [lindex $argv 0]
set repo_url [lindex $argv 1]
set deployment_dir [lindex $argv 2]
set deployment_name [lindex $argv 3]
set branch_name [lindex $argv 4]
set server_username [lindex $argv 5]
set server_id [lindex $argv 6]

# Set the timeout to 30 seconds for the entire script
set timeout 30

# SSH into the jump host using the RSA private key
spawn ssh -i $private_key_path -o StrictHostKeyChecking=no $server_username@igor.gold.ac.uk
expect {
    "yes/no" { send "yes\r"; exp_continue }
    # If a passphrase is required for the private key, handle that
    "Enter passphrase for key" { send_user "Key passphrase required.\n"; exp_continue }
}

# Once connected to the jump server, connect to the target server using the server ID (no password needed)
expect "$ "
send "myserver ssh $server_id\r"

# Wait until we have access to the target server
expect "$ "

# Run the deployment commands on the target server using the provided deployment directory
send "cd $deployment_dir || mkdir -p $deployment_dir && cd $deployment_dir\r"
expect "$ "
send "git pull origin $branch_name || git clone $repo_url .\r"
send "npm install\r"

# TODO add a database deployment function to code

# Check if pm2 is installed and install if necessary
expect "$ "
send "command -v pm2 >/dev/null 2>&1 || npm install -g pm2\r"

# Restart or start the application using the deployment name
expect "$ "
send "if pm2 describe $deployment_name >/dev/null 2>&1; then pm2 restart $deployment_name; else pm2 start npm --name '$deployment_name' -- run start; fi\r"

# Introduce a delay to allow PM2 to fully start or fail
expect "$ "
send "sleep 30\r"
expect "$ "

# Check the status of the pm2 application
send "pm2 describe $deployment_name\r"

# Extend the timeout for the PM2 status check
set timeout 60

# Capture the output and check the status
expect {
    -re {status\s+\│\sonline} {
        puts "PM2 instance is running correctly: Status is online."
    }
    -re {status\s+\│\serrored} {
        puts "Node.js server failed to start."
        send_user "Node.js server failed to start.\n"
        exit 1
    }
    timeout {
        puts "PM2 status check timed out or failed."
        send_user "PM2 status check timed out or failed.\n"
        exit 1
    }
}

# Exit from the server
expect "$ "
send "exit\r"
expect eof
