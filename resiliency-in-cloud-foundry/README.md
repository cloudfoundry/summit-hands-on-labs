```
$ cd bbl-labs-user[1-12]
$ eval "$(bbl print-env)"
```

```
$ cat cf_creds.txt
```

```
$ cf api api.user[1-12].altoros-labs.xyz --skip-ssl-validation
$ cf login -u admin -p PASSWORD
$ cf target -o "system" -s "labs"
```

```
$ git clone https://github.com/cloudfoundry-samples/spring-music.git
```
