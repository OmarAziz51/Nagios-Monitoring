# Nagios Infrastructure Monitoring

A Nagios Core monitoring project for a small multi-tier application environment. It demonstrates host availability checks, service/port monitoring, and remote Linux health checks through NRPE.

## Architecture

- **Monitoring server:** Ubuntu Server 22.04, Nagios Core
- **Remote monitoring:** NRPE over TCP/5666
- **Nagios plugin directory (server):** `/usr/local/nagios/libexec`
- **Nagios configuration root:** `/usr/local/nagios/etc`
- **Web interface:** `http://<NAGIOS_SERVER_IP>/nagios`

### Example monitored inventory

| Host | Example IP | Role | Application check |
|---|---:|---|---|
| omdb01 | 10.10.10.70 | MariaDB | TCP/3306 |
| ommc01 | 10.10.10.71 | Memcached | TCP/11211 |
| omrmq01 | 10.10.10.72 | RabbitMQ | TCP/5672 |
| omapp01 | 10.10.10.73 | Tomcat | HTTP/8080 |
| omweb01 | 10.10.10.74 | Nginx | HTTP/80 |

> The addresses above are private lab addresses. Replace them with your own values before reusing the configuration in another environment. Do not publish public IPs, credentials, tokens, or customer data.

## Monitoring coverage

Each host is monitored for:
1. ICMP reachability
2. SSH availability (TCP/22)
3. CPU load through NRPE
4. Root filesystem usage through NRPE
5. Memory usage through NRPE
6. Process count through NRPE
7. Its application-specific port or HTTP endpoint

The sample configuration therefore defines 35 service checks across five hosts.

## Repository layout

```text
nagios-monitoring-project/
├── config/
│   ├── commands.cfg
│   └── hosts-services.cfg
├── docs/
│   ├── deployment-status.md
│   └── ubuntu-22.04-setup.md
├── nrpe/
│   └── nrpe-local.cfg.example
├── plugins/
│   └── check_mem.sh
├── .gitignore
└── README.md
```

## Deployment overview

1. Install Nagios Core and Nagios Plugins on the monitoring server.
2. Install and enable the NRPE agent on every monitored Linux VM.
3. Allow TCP/5666 from the Nagios server only.
4. Configure the NRPE command aliases shown in `nrpe/nrpe-local.cfg.example`.
5. Copy the Nagios command and host/service definitions into the Nagios configuration tree.
6. Validate the configuration and restart Nagios.

See [Ubuntu 22.04 deployment guide](docs/ubuntu-22.04-setup.md).

## Validate and reload Nagios

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
sudo systemctl status nagios --no-pager
```

## Test NRPE from the monitoring server

```bash
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_load
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_disk
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_mem
/usr/local/nagios/libexec/check_nrpe -H 10.10.10.70 -c check_procs
```

Repeat against each monitored host. A successful NRPE connection alone does not prove every command is defined; test each command individually.

## Notes

- Thresholds are examples and should be tuned to the workload of each VM.
- The memory plugin uses `MemAvailable` from `/proc/meminfo`.
- The NRPE agent should accept connections only from the Nagios server.
- Do not commit credentials, private keys, real customer data, or unredacted production configuration.
