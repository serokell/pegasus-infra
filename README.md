# Pegasus: Web App Cluster

![Pegasus Constellation](https://upload.wikimedia.org/wikipedia/commons/2/2c/PegasusCC.jpg)

_Image credit: Till Credner, CC BY-SA 3.0_

Serokell's web app servers

<!-- Don't forget to add the servers on https://www.notion.so/serokell/Server-Naming-Scheme-c189819000164fb090377c75e4ce7da6 -->

## Servers

| Name      | Provider      | Function               |
|-----------|---------------|------------------------|
| helvetios | EC2           | serokell.io staging    |
| enif      | EC2           | serokell.io production |
| matar     | EC2           | postgresql             |
| sadalbari | Hetzner Cloud | hackage-search         |


## Network

All EC2 servers are members of the same VPC and linked by private networks that
route transparently to one another.

There's a private DNS zone associated with the VPC that includes records for all
servers. The VPC has the local domain set to "pegasus.serokell.team", so simple
server names such as "matar" resolve to their private IP.

Public servers have ElasticIPs associated with them, and DNS names for this and
an IPv6 address.

### Hetzner Cloud

EC2 and Hetzner Cloud do not share a private network connection at this point.

## Backups

[See here for a reference](https://www.notion.so/serokell/Rsync-net-797d5fdca3744aed8e17db741b7fce5a).

This cluster uses user 12482. Despite multiple servers using the same SSH user,
they do not share their repo password (unless specified otherwise), and so can
not access each others data.

Helvetios and Enif use the same repo, but Helvetios does not generate backups.

Matar has its own folder.

## PostgreSQL

There's a shared instance on Matar, which is currently used by the website on
Helvetios and Enif. This allows to make these instances smaller and cheaper, as
well as centralized data administration, backups and hardening.

### Security

There is no difference between roles, users, and groups. There's only one
thing for Postgres: roles.

Roles with `LOGIN` are traditionally considered "users". You may grant roles to
other roles, effectively creating groups.

For each database, there is a role with a matching name. Authentication over the
private network requires a role matching the target database and a valid
password.

There are no special superuser roles. For administration tasks, SSH into `matar`
and use `sudo -u postgres psql`.

### User management

Say we have a database `www` and a matching role `www`. We would like a user
`www-user` to be able to connect to this database.

First, create the login role:

```
$ CREATE ROLE "www-user" WITH LOGIN PASSWORD 'super banana';
```

As described above, remote login requires a role matching the database name.
What this means is that the user trying to log in needs to either have the same
name as the database, or be a member of another role with the same name as the
database.

We will make the user a member of the role:

```
$ GRANT "www" TO "www-user";
```

The inverse is done like this:

```
$ REVOKE "www" FROM "www-user";
```

#### Changing a password

There's two ways, entirely equivalent:

This command is a special form only available in `psql`. It will ask you to write the password twice.

```
$ \password "username"
```

This form can be run over any SQL connection with enough privileges:

```
$ ALTER ROLE "username" WITH PASSWORD 'omega banana';
```

## What's where

DNS records and EC2 instances: [./terraform](./terraform)

NixOS configurations: [./servers](./servers), a directory per server
