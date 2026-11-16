# Deployment Status

## Current project status

The user reports that the NRPE configuration and monitoring checks have been corrected and are now working in the lab environment.

### Implemented design

- Nagios Core monitoring server on Ubuntu Server 22.04
- Five monitored Linux VMs
- NRPE remote checks over TCP/5666
- ICMP and SSH availability checks
- Application port/HTTP checks for MariaDB, Memcached, RabbitMQ, Tomcat, and Nginx
- CPU load, root filesystem, memory, and process checks through NRPE
- Custom memory plugin based on `/proc/meminfo` and `MemAvailable`

### Validation record

The following checks were exercised during troubleshooting:

- NRPE client plugin exists on the Nagios server.
- TCP/5666 was initially unreachable before NRPE was configured on the monitored VM.
- NRPE connectivity and `check_load` responded on `omdb01`.
- The initial `check_disk`, `check_mem`, and `check_procs` aliases were missing and were subsequently configured.
- The user reports that the overall setup is now working.

> This is a user-reported deployment status, not an independently collected monitoring export. Update this document with screenshots or command output if you want to provide verifiable evidence in a public portfolio.

## Suggested evidence to add

- Nagios dashboard showing all five hosts and service checks
- `nagios -v` output showing a valid configuration
- Successful NRPE command outputs from each monitored VM
- A short architecture diagram showing Nagios server → NRPE agents

Before publishing screenshots, redact credentials, public addresses, customer names, and other sensitive environment details.
