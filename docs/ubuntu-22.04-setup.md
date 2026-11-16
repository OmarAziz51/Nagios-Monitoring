# Deployment Guide — Ubuntu Server 22.04

## 1. Monitoring server prerequisites

Install required packages (package names can vary by repository/release):

```bash
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php build-essential autoconf gcc make unzip wget
```

Install Nagios Core and the Nagios Plugins according to the official installation procedure for the version you choose. This project assumes:

- Nagios Core: `/usr/local/nagios`
- Plugins: `/usr/local/nagios/libexec`
- NRPE client plugin: `/usr/local/nagios/libexec/check_nrpe`

Confirm:

```bash
ls -l /usr/local/nagios/libexec/check_nrpe
```

## 2. Configure Nagios to load project files

Create a directory for server definitions:

```bash
sudo mkdir -p /usr/local/nagios/etc/servers
```

Add or confirm this line in `/usr/local/nagios/etc/nagios.cfg`:

```ini
cfg_dir=/usr/local/nagios/etc/servers
```

Copy `config/commands.cfg` and `config/hosts-services.cfg` into the appropriate included configuration directory. For example:

```bash
sudo cp config/commands.cfg /usr/local/nagios/etc/objects/vprofile_commands.cfg
sudo cp config/hosts-services.cfg /usr/local/nagios/etc/servers/vprofile_hosts.cfg
```

Make sure `commands.cfg` is loaded by Nagios. If using the default objects directory, confirm `nagios.cfg` includes it.

## 3. Install NRPE on every monitored VM

On each Ubuntu monitored VM:

```bash
sudo apt update
sudo apt install -y nagios-nrpe-server monitoring-plugins
```

If `monitoring-plugins` is unavailable in the configured repositories, search the package manager for the package providing `check_load`, `check_disk`, and `check_procs`, then confirm their actual paths:

```bash
command -v check_load
command -v check_disk
command -v check_procs
```

Copy the custom memory plugin to the same path referenced in the NRPE command:

```bash
sudo mkdir -p /usr/local/nagios/libexec
sudo install -m 755 plugins/check_mem.sh /usr/local/nagios/libexec/check_mem.sh
```

Merge the command definitions from `nrpe/nrpe-local.cfg.example` into `/etc/nagios/nrpe.cfg` or an included file. Do not replace the entire NRPE configuration.

Set the allowed Nagios server address in `/etc/nagios/nrpe.cfg`:

```ini
allowed_hosts=127.0.0.1,10.10.10.90
```

Adjust the IP to your monitoring server. Ensure there are no duplicate conflicting definitions for the same command.

## 4. Firewall and service

Allow NRPE only from the monitoring server:

```bash
sudo ufw allow from 10.10.10.90 to any port 5666 proto tcp
sudo systemctl enable --now nagios-nrpe-server
sudo systemctl restart nagios-nrpe-server
sudo ss -tlnp | grep 5666
```

If UFW is not used, implement the equivalent restriction in the active firewall/security group.

## 5. Test from Nagios server

```bash
nc -zv 10.10.10.70 5666
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_load
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_disk
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_mem
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_procs
```

Repeat for every monitored VM. Investigate `NRPE: Command ... not defined` by checking command definitions and NRPE include files. Investigate timeouts by checking service status, listening socket, firewall rules, and allowed hosts.

## 6. Validate and restart Nagios

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
sudo systemctl status nagios --no-pager
```

Only restart after the configuration validation reports no errors.
