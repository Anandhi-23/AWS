#!/bin/bash
apt update
apt install -y apache2

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Webpage</title>
</head>
<body>
  <p>This application is from MySecondInstance!!!</p>
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2