# Opensearch

Helm chart for [Opensearch](https://opensearch.org/docs/opensearch/index/)

## Installing the chart

Prerequisites:
* A kubernetes cluster
* Helm 3.x
* openssl (for generating keys)

### Virtual memory
Opensearch uses a mmapfs directory to store indices. It wont start if it detects low mmap counts.
Set the limits with following command:
```
> sudo sysctl -w vm.max_map_count=262144
```

### Install Opensearch with:
```
> cd opensearch
> export OPENSEARCH_RELEASE=arbeidsplassen-opensearch
> export OPENSEARCH_NAMESPACE=teampam
> ../scripts/generate_certs.sh
> ../scripts/generate_kubernetes_secrets.sh <changeme>
> ../scripts/deploy-opensearch.sh <path.to.values.yaml>
```

### Install Dashbards with:
```
> cd opensearch-dashbards
> export DASHBOARDS_RELEASE=arbeidsplassen-dashboards
> export DASHBOARDS_NAMESPACE=teampam
> ../scripts/deploy-dashboards.sh <path.to.values.yaml>
```

## Deploy to production:
Before going to production, reconfigure the settings in the values.yaml file  according to your need.
Depending on traffic load and index size, increase the memory for data and master nodes.
[More about settings](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html#_memory)

### Linkerd
This chart is compatible with linkerd, you can enable/disable linkerd by setting the flag "security.linkerd.enabled" to true/false.
When running with linkerd, it will create a networkpolicy, you need to change the policy according to your services.

## Security
Security is now enabled by default. 
Opensearch supports a variety of authentication and authorization protocols like LDAP, Kerberos, SAML, OpenID and [more](https://opensearch.org/docs/security-plugin/index/). 
By default this installation creates a list of internal users with passwords. NOTE by convenient all users is set to the same password on startup, 
you can change this by logging into Dashboards and change the password [there](https://aws.amazon.com/blogs/opensource/change-passwords-open-distro-for-elasticsearch/). 

Use the script generate_certs.sh to generate self signed certs:
```
> ./scripts/generate_certs.sh
```

The script creates all keys necessary needed for this setup, and are placed under .secrets/ folder. 
Keep root-ca-key.pem and root-ca.pem in case you need to add more keys and need to sign them.

Apply the secrets to kubernetes using following command:

```
> ./scripts/generate_kubernetes_secrets.sh <password>
```
Remember to change the password later in Dashboards. Finally deploy with security enabled:

```
> ./scripts/deploy-opensearch.sh
```

