# WordPress Deployment Script

Developed for Ubuntu (16.04), this repo can be cloned, script set executable, then ran to spin up a fresh WordPress install on a fresh Ubuntu image.

###How to use:

Step 1. SSH to your server.
Step 2. The simplest way:
curl -L -o 'wp.sh' https://raw.githubusercontent.com/nrm55/wordpress-deploy-sh/master/wordpress-deploy.sh && bash wp.sh
you could clone (and/or fork for improvements):
git clone https://github.com/nrm55/wordpress-deploy-sh.git
Step 3. You will be promted for minimal information, namely the domain name (example.com).
Step 4. Follow instructions.
