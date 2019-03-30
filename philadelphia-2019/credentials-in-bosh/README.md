## Introduction 

The proliferation of X.509 Certificates by way of mutual TLS inside of Cloud
Foundry has increased pressure on operations teams to be able to generate,
inspect, verify, and rotate or renew credentials in a timely fashion.  In this
hands-on lab, you will walk through handling credentials and certificate
management with both Safe and Credhub.

Participants should finish this hands-on lab with a better understanding of the
complexities of proper PKI / X.509 certificate management, credentials
rotation, etc., as well as some familiarity with popular open source tools for
assisting with those activities in the Cloud Foundry ecosystem.

### Target Audience

This lab is targeted towards BOSH and Cloud Foundry users who are not
experienced with storing credentials in secure credential stores.

### Prerequisites

- A computer
- Knowledge of the Linux command line (bash).


## Lab

### Tools

### Start Up Credhub and Vault

This lab utilizes Docker to set up temporary Credhub and Vault instances. 
Run the following from the `credentials-in-bosh` directory (you should be in
this directory by default).
```
docker-compose up -d
``` 

While that is starting up, you can read a bit
about the tools you will be using in this lab.

We will be interacting with Credhub using the `credhub` CLI. `credhub` is the 
official CLI for the credhub server. For a list of credhub commands, you can
execute `credhub -h`. `credhub <command> -h` will display further help for each command.

We will be interacting with Vault using the `safe` CLI. `safe` is a CLI created
by Stark & Wayne that makes the K/V backend of Vault more accessible, and also
provides a multitude of other commands for generating and storing credentials.
`safe -h` will display the list of commands for safe. `safe help <command>`
will display further help for each command.

## Vault (with Safe!)

Vault is an encrypted-at-rest crendential store made by Hashicorp. BOSH does
not have any direct support for Vault, but despite that, it can still function
as an easy-to-use, stable, and secure credential storage. The `safe` CLI makes 
it even better.

### Targeting Vault 

First, we need to target the Vault with safe. This way, future commands will be
run against the specified Vault server. 

The Vault server running in the Docker container is being exposed on the host
machine (your cloud shell) on port 11003. It is listening for HTTP requests
(non-TLS).

To target the Vault server, run: 

```
safe target docker http://127.0.0.1:11003
```

Normally, we would not want to talk to the Vault without HTTPS, but for the purpose
of this lab, it makes setup simpler and quicker.

### Authenticating to the Vault

Vault doesn't just let anybody see your secrets, so you'll need to log in. The only
authentication method enabled for the Vault in this lab is with the root token. The
root token is created when the Vault is initialized, and it has complete access to
everything in the Vault.

For this lab, the root token has insecurely set to `root`.

So we tell safe that we want to authenticate with a token:

```
safe auth token
```

and then when prompted, type `root` and then hit enter.

### Generating Passwords

Let's generate a password and put it into the Vault.

Vault exposes a filesystem-esque path system for its mount points. Let's write
a password to the path `secret/generated`. Vault Key-Value have keys and
values.  Because we're generating a password, it makes sense to make the key
name `password`. In `safe` syntax, we would specify this path and key
combination as `secret/generated:password`.

Also, we can specify the length of the password that is generated with the `-l`
flag. Make a 20 character password with the following:

```
safe gen -l 20 "secret/generated:password"
```

### Reading From the Vault

We can get the contents of the secret you just wrote. 

```
safe get secret/generated
```

If you just wanted the `password` key alone (possibly for scripting purposes),
you can specify the key in the path, like this:

```
safe get secret/generated:password
```

### Putting Custom Things into the Vault

Maybe you have a username, password, or some other credential that you didn't
generate with `safe`. Let's write a custom key to the Vault using the `set`
command.

Write to the path `secret/custom`, setting the key `foo` to the value `bar`.
This can be done like this:

```
safe set secret/custom foo=bar
```

If you would like to write something into the vault but do not want to expose
the value to someone over your shoulder, you can omit the value and be prompted
for it as a hidden input via the following

```
safe set secret/custom bar
```

### SSH Keys

SSH uses an asymmetrical RSA keypair for authentication - a public key and
a private key. The server you want to SSH into gets the public key, and 
you keep the private key for use for authentication.  Let's generate an SSH 
keypair at the `secret/ssh` path.

```
safe ssh secret/ssh
```

This writes three keys to the path - `fingerprint`, `private` and `public`. 
You can see them if you run `safe get secret/ssh`.

### x509 Certificates

#### Issuing a Certificate

Certificates are another application of the RSA keypair used in the earlier SSH
section. X509 certificates allow for the encryption of web traffic and for the
validation of identities when talking to servers on the web. Most commonly, you
see the effects of X509 certificates as the green lock icon in your browser.

First, let's generate a certificate. This cert will be self-signed and marked
as a certificate authority (CA). This means that it can sign other certificates,
allowing us to make a chain of trust.

`safe x509 issue` is the command is what will create a new certificate. 

We will use the `--name` flag to specify for which hostnames / IPs the
certificate is valid.  These are called Subject Alternative Names. This flag
can be specified multiple times, once for each name you'd like to add to the
certificate, each time specifying the name as the value to the flag. For the
purpose of this exercise, we will only be adding one. 

We will also use the `--ca` flag to specify that it is a certificate authority.
This is a boolean flag, meaning it takes no value.

Certificates are only valid within a certain range of time, specified by the
certificate's "Not Before" and "Not After" fields. `safe` will set the Not
Before to the time at which you created the cert, and will set the Not After
to a time from specified by the `--ttl` flag. We will make our certificate
valid for two years, which can be specified with the value `2y`.

Also, notably, we will be omitting the `--signed-by` flag, which causes `safe`
to make the certificate self-signed. This leaves this certificate as the root
of its trust chain.

And lastly, we'll put our new cert at the path `secret/x509/ca`. This is the
sole positional argument for this command.

Altogether, this looks like:
```
safe x509 issue "secret/x509/ca" --ca --name "ca.example.com" --ttl 2y
```

#### Looking at the Certificate You Made

Maybe you want to see the details of the thing you just made. There's a
command for that, too: `safe x509 show`. It takes the path that the 
certificate is located at as the lone argument.

```
safe x509 show "secret/x509/ca"
```

#### Making a Certificate Signed By a CA

Making a certificate signed by another certificate is a lot like making a
self-signed, as we just did; this time, we specify the `--signed-by`
flag with the value being the path to the certificate that we wish to sign
it. In this case, we want the CA we just created to sign it. Also, we'll only
make this certificate valid for one year, and we will not make this new
certificate a Certificate Authority.

```
safe x509 issue "secret/x509/server" --name "server.example.com" --ttl 1y --signed-by "secret/x509/ca"
```

#### Renewing a Certificate

Certificates expire when the Not After attribute of the certificate is in the
past. If we have access to the CA certificate which signed the cert initially
and the CA is still valid (not expired or revoked), we can renew the 
certificate. The `safe x509 renew` command makes this pretty easy. Just
provide the certificate to renew as the positional argument and the
CA that it was signed with as the value to `--signed-by`, and safe will
generate the renewed certificate for you. If you would like to renew the
cert with a longer ttl you can specify the `--ttl` flag as well.

```
safe x509 renew "secret/x509/server" --signed-by "secret/x509/ca" --ttl 2y
```


## Credhub

Credhub is a credential storage made by Pivotal. It implements the BOSH Config
Server API, which means that BOSH can use it to generate and retrieve
credentials. Credential generation is built into Credhub itself!

### Targeting and Logging into Credhub

We'll use the `credhub login` command for this. It takes a `-s` flag for
specifying server target.  The `-u` and `-p` flags provide the username and
password, respectively. 

Unlike with the `safe` installation, we'll be talking to Credhub over HTTPS -
this means that the server performs TLS with a certificate and private key.
However, the key that the docker image installation is presenting is not going
to be trusted by your computer. Normally, this would cause your `credhub` CLI
to stop communicating with the credhub server because it would be deemed not a
trusted source. For the purpose of this lab, we don't care about validating the
certificate presented by a server we're running locally. To cause the validity
checks to be skipped, we give the `--skip-tls-validation` flag.

```
credhub login -s https://127.0.0.1:9000 -u credhub -p password --skip-tls-validation
```

### Generating Credentials in Credhub

The `credhub generate` command tells the Credhub server to generate a
credential on your behalf. All of your calls to this command will require the
`-n` flag, which you set to the path of the secret to write. They also will
require the `-t` flag, which you will set to the type of credential you would
like to generate. You can create username/password combinations, SSH keys, RSA
keys, and x509 certificates. The remainder of the flags to the `credhub generate`
command will give specific parameters about how to generate the particular type
of credential you requested with the `-t` flag.

To see the comprehensive list of flags, check out 

```
credhub generate -h
```

### Generating Passwords

Let's make another random string to use as a password. We'll put it at the path
`dir/password` with the `-n` (or `--name`) flag. 

We want a password, so we tell it the type is `password` with the `-t`
(`--type`) flag.

Also, we can set the length of the password. To set it to 20, add `-l 20`
(`--length 20`).

```
credhub generate -n "dir/password" -t password -l 20
```

### Reading Credentials

We can read our password back out with `credhub get`. The `-n` flag specifies
which path to read the credential from.

```
credhub get -n "dir/password"
```

It shows you the metadata of the credential along with its value. If you just
want to display the value, you can give the `-q` flag.

```
credhub get -n "dir/password" -q
```

### Writing Custom Secrets

To write your own custom credential, you can use `credhub set`. Let's make a
credential of the type `value` (with the `-t` flag). Let's store the string
`supersecret` at the path `dir/custom`.

```
credhub set -n "dir/custom" -t value -v supersecret
```

### Making Other Credentials

Credhub can also make SSH keys and x509 Certificates in a similar manner to
the `safe` CLI. At this point, we've made a whole bunch of credentials in
`safe` and `credhub`. You make credentials with Credhub in largely the same
way that you do in `safe` - the flag and command names are just different. 

To make an ssh key, set the `-t` flag to `ssh`. You can alter the bit length of
the key with the `-k` (`--key-length`) flag.

```
credhub generate -n "dir/ssh" -t ssh -k 2048
```

Similarly you can make an x509 certificate with the type `certificate`. Let's
make the Common Name ('-c') and the Subject Alternative Name (`-a`) to
`ca.example.com`.  Also, let's make it a CA by giving the `--is-ca` flag.

You can specify the `--ca` flag to specify a path to another certificate to
sign this certificate with, but here we'll omit it, and as a result the
certificate will be self-signed.

```
credhub generate -n "dir/x509" -t certificate -c "ca.example.com" -a "ca.example.com" --is-ca
```
