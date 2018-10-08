# Introduction to Cloud Foundry UAA

## Introduction

The Cloud Foundry UAA (User Account & Authentication) was created for Cloud Foundry Application Runtime itself, but its influence has broadened to BOSH, CredHub, Concourse, and a growing beyond the Cloud Foundry ecosystem. Your own applications can use the UAA to authenticate your users, and authorize selective behaviour, including bridging to federated user directories such as ActiveDirectory; and applications can use the UAA to authorize access between each other.

In this 30 minute lab we will be doing the following:

* Run the UAA locally (or upon a jumpbox) using [Quaa - Quick UAA](https://github.com/starkandwayne/quaa)
* Progressively enhance some a sample application with UAA authorization

## Learning Objectives

1. The UAA is a simple Java application that runs within an environment such as Apache Tomcat, or with the Cloud Foundry Java Buildpack. It has an in-memory database; but supports PostgreSQL and MySQL for long-term data persistence.
1. The UAA has a web UI for users to login, grant authorization to client applications to their data, revoke authorization grants, and perform multi-factor authentication
1. The UAA has an HTTP API to act as an OAuth2 Authorization Server, an OpenID Connect user information provider, and for clients to configure the UAA itself (create/modify/delete new clients, users, etc).
1. Backend APIs, called Resource Servers, can delegate authentication and authorization to the UAA.
1. Client applications, such as user-facing web apps or CLIs, pass access tokens to resource servers. They do not necessarily know identity information about their human user or another application client.
1. All applications can be written in any programming language and hosted anywhere. The OAuth2 standard is well recognized and client libraries exist everywhere.

## Prerequisites

To run the UAA locally requires:

1. Java 8 / Java 1.8

    ```plain
    $ java -version
    java version "1.8.0_66"
    ```

    **NOTE:** Apache Tomcat may not work on Java 9 / Java 10; hence requirement for specifically Java 8.

1. Git

    ```plain
    $ git --version
    git version 2.17.1 (Apple Git-112)
    ```

To run the example applications requires:

1. Docker CLI and Docker Daemon running

    ```plain
    $ docker version
    Client:
     Version:           18.06.1-ce
      ...
    Server:
     Engine:
      Version:          18.06.1-ce
      ...
    ```

1. Docker image for sample application

    ```plain
    docker pull starkandwayne/uaa-example-resource-server
    ```

1. Example application source code:

    ```plain
    git clone https://github.com/starkandwayne/ultimate-guide-to-uaa-examples ~/workspace/ultimate-guide-to-uaa-examples
    ```

## Lab

Lab steps:

1. Quickly run UAA locally
1. Run a "resource server" for anonymous users
1. Create UAA user and authenticate with password

### Quickly run UAA locally

We will use the [Quick UAA Local](https://github.com/starkandwayne/quick-uaa-local/) project to download all remaining dependencies and run a local UAA.

On MacOS/Homebrew:

```plain
brew install starkandwayne/cf/quaa
```

On Linux/MacOS:

```plain
git clone https://github.com/starkandwayne/quick-uaa-local ~/workspace/quick-uaa-local
cd ~/workspace/quick-uaa-local
```

Either run `direnv allow` if prompted, or:

```plain
eval "$(bin/quaa env)"
```

On both:

To run a local UAA:

```plain
quaa up
```

### Run a "resource server" for anonymous users

The example resource server (data API to be protected by UAA later) is a list of Australian Airports.

The application supports anonymous users - those who interact with the API without any valid authorization.

We will use environment variables to configure the application with our local UAA:

```plain
quaa env

eval "$(quaa env)"
echo $UAA_URL
```

Either run with Docker, or investigate the [different Ruby/Golang implementations](https://github.com/starkandwayne/ultimate-guide-to-uaa-examples)

```plain
docker run -ti -p 9292:9292 -e UAA_URL=$UAA_URL -e UAA_CA_CERT=$UAA_CA_CERT starkandwayne/uaa-example-resource-server
```

The Airport API resource server application is now running on port `:9292`. We can interact with it using `curl`:

```plain
$ curl localhost:9292
[
  {
    "Airport ID": 3317,
    "Name": "Brisbane Archerfield Airport",
    "City": "Brisbane",
    "Country": "Australia",
    "IATA": "\\N",
    "ICAO": "YBAF",
```

If you have the `jq` CLI you can see that as an anonymous user we receive 10 results only:

```plain
$ curl localhost:9292 | jq length
10
```

See the [Ruby example source code](https://github.com/starkandwayne/ultimate-guide-to-uaa-examples/blob/master/ruby/resource-server/config.ru#L24-L27)

### Create UAA user and authenticate with password

We will use the [`uaa` CLI](https://github.com/cloudfoundry-incubator/uaa-cli) to configure our UAA and create a user for you.

The `quaa` CLI makes it easy to setup the `uaa` CLI for our UAA:

```plain
$ quaa auth-client
Target set to http://localhost:8080
Access token successfully fetched and added to context.
```

The [`uaa` CLI](https://github.com/cloudfoundry-incubator/uaa-cli) will be installed if missing; and will be targeted and authorized as an admin-level user.

You can now view and modify UAA objects:

```plain
uaa clients
uaa users
uaa groups
```

The `uaa` CLI returns JSON to make it friendly for scripting.

To create a user for yourself:

```plain
uaa create-user tutorialuser \
    --password tutorialsecret \
    --email drnic@starkandwayne \
    --givenName "Dr Nic" \
    --familyName "Williams"
```

We don't "login" to the Airport API.

Rather, we get an access token from the UAA and provide it to the API. Our future `curl` request will look similar to:

```plain
curl localhost:9292 -H 'Authorization: bearer <token>'
```

We can use the `uaa` CLI as `tutorialuser` to request an access token. The usage is:

```plain
uaa get-password-token CLIENT_ID -s CLIENT_SECRET -u USERNAME -p PASSWORD
```

That is, we need a UAA client in order to request an access token.

The `uaa clients` command shows that initially we only have one client `uaa_admin`, but it has scope `uaa.none` (which will prevent users from using it):

```plain
$ uaa get-client uaa_admin
{
  "client_id": "uaa_admin",
  "scope": [
    "uaa.none"
  ],
...
```

We can easily create a new UAA client for our Airport application:

```plain
uaa create-client airports -s airports \
  --authorized_grant_types password,refresh_token \
  --scope openid
```

The flag `--authorized_grant_types password` allows users to request access tokens using their username/password. The suffix `--authorized_grant_types password,refresh_token` means that their client application (which is the `uaa` CLI in our case) can automatically request new access tokens in future if the current one expires.

The client `airports` has a trivial secret `airports`. It is assumed this client/secret will be stored in public locations such as open source code repositories and we don't need a strong secret.

Our user can now use the `uaa` CLI to request an access token:

```plain
$ uaa get-password-token airports -s airports -u tutorialuser -p tutorialsecret
Access token successfully fetched and added to context.
```

To get our access token from the `uaa` client application it provides a handy `uaa context` command:

```plain
$ uaa context
{
  "client_id": "airports",
  "grant_type": "password",
  "username": "tutorialuser",
  "access_token": "eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vbG9jYWxob3N0OjgwODAvdG9rZW5fa2V5cyIsImtpZCI6InVhYS1qd3Qta2V5LTEiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiI2NDFjMmQ3NmNiZmY0NzZjYTExNzEzNDJjYjgwOGU1MCIsInN1YiI6ImNiNTRlYjVhLWQ4NGQtNDI0MS1iNTNjLWRkOGE3YTk2ZGFkMSIsInNjb3BlIjpbIm9wZW5pZCJdLCJjbGllbnRfaWQiOiJhaXJwb3J0cyIsImNpZCI6ImFpcnBvcnRzIiwiYXpwIjoiYWlycG9ydHMiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX2lkIjoiY2I1NGViNWEtZDg0ZC00MjQxLWI1M2MtZGQ4YTdhOTZkYWQxIiwib3JpZ2luIjoidWFhIiwidXNlcl9uYW1lIjoiZHJuaWMiLCJlbWFpbCI6ImRybmljQHN0YXJrYW5kd2F5bmUiLCJhdXRoX3RpbWUiOjE1Mzc4MjAwMzAsInJldl9zaWciOiJjOTQ5Y2U5YiIsImlhdCI6MTUzNzgyMDAzMCwiZXhwIjoxNTM3ODYzMjMwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvb2F1dGgvdG9rZW4iLCJ6aWQiOiJ1YWEiLCJhdWQiOlsib3BlbmlkIiwiYWlycG9ydHMiXX0.0I0yzodqDAjYZofzmdLWLzufhG_y0baOY0QBhpG1MOTsUNuExjbDQT1ZwhQXH7ng5mkTssnBjhNaWMETIY-B4xOD-bvIr_vVWZqYveBz7Ua2dx6hoq98HHKEdLuL1XbdhJgC_eDl9BVjCgjIxtxlEn1C9Q1rb6FHnIAyTvQUadz4YxSNLPzwClkBKIXCuBPULiNVHJ1nzhNNIuLf6h6oBu3-y_B4eDi77erC8HNXBujPDbJdC3w2QZbsdBY_HiErXc03cZ5WRKzaXKwsMsypbvlYdAghM7SaFZVcdRiDQ71S4GImcPf9Aiy3zbecAxvDpa-Mywtxzv3DExDp-e3YzQ",
  "refresh_token": "60bc2ec4b6e34b5eb35ce141e99148d5-r",
  "id_token": "",
  "token_type": "bearer",
  "expires_in": 43199,
  "scope": "openid",
  "jti": "641c2d76cbff476ca1171342cb808e50"
}
```

Copy and paste the large `access_token` value into your `curl` command:

```plain
curl -H 'Authorization: bearer eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vbG9jYWxob3N0OjgwODAvdG9rZW5fa2V5cyIsImtpZCI6InVhYS1qd3Qta2V5LTEiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiI2NDFjMmQ3NmNiZmY0NzZjYTExNzEzNDJjYjgwOGU1MCIsInN1YiI6ImNiNTRlYjVhLWQ4NGQtNDI0MS1iNTNjLWRkOGE3YTk2ZGFkMSIsInNjb3BlIjpbIm9wZW5pZCJdLCJjbGllbnRfaWQiOiJhaXJwb3J0cyIsImNpZCI6ImFpcnBvcnRzIiwiYXpwIjoiYWlycG9ydHMiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX2lkIjoiY2I1NGViNWEtZDg0ZC00MjQxLWI1M2MtZGQ4YTdhOTZkYWQxIiwib3JpZ2luIjoidWFhIiwidXNlcl9uYW1lIjoiZHJuaWMiLCJlbWFpbCI6ImRybmljQHN0YXJrYW5kd2F5bmUiLCJhdXRoX3RpbWUiOjE1Mzc4MjAwMzAsInJldl9zaWciOiJjOTQ5Y2U5YiIsImlhdCI6MTUzNzgyMDAzMCwiZXhwIjoxNTM3ODYzMjMwLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvb2F1dGgvdG9rZW4iLCJ6aWQiOiJ1YWEiLCJhdWQiOlsib3BlbmlkIiwiYWlycG9ydHMiXX0.0I0yzodqDAjYZofzmdLWLzufhG_y0baOY0QBhpG1MOTsUNuExjbDQT1ZwhQXH7ng5mkTssnBjhNaWMETIY-B4xOD-bvIr_vVWZqYveBz7Ua2dx6hoq98HHKEdLuL1XbdhJgC_eDl9BVjCgjIxtxlEn1C9Q1rb6FHnIAyTvQUadz4YxSNLPzwClkBKIXCuBPULiNVHJ1nzhNNIuLf6h6oBu3-y_B4eDi77erC8HNXBujPDbJdC3w2QZbsdBY_HiErXc03cZ5WRKzaXKwsMsypbvlYdAghM7SaFZVcdRiDQ71S4GImcPf9Aiy3zbecAxvDpa-Mywtxzv3DExDp-e3YzQ' -s http://localhost:9292/ | jq length
```

The result will be 20. The example resource server was implemented to expand the number of results returned if a valid access token was passed via an `Authorization: bearer <token>` header.

### Enhance Access Token with Scopes

Update the `airports` client to also support two new scopes: `airports.all`, and `airports.50`. These are already supported within the code base.

First, change the `uaa` client back to being a UAA admin client; and then run `uaa update-client airports` with a modified `--scope` to change the scope of `airports` client:

```plain
quaa auth-client
uaa update-client airports --scope openid,airports.all,airports.50
```

Next, we need to add our `tutorialuser` to a group with the same name as the scope expected by the application `airports.all`.

```plain
uaa create-group airports.all -d "Display all airports"
uaa create-group airports.50 -d "Display 50 airports"

uaa add-member airports.all tutorialuser
```

At this point, the authorization header's access token still represents the original grant that does not include `airports.all`. The user needs to authorize again to create a new access token that contains the updated scopes.

```plain
uaa get-password-token airports -s airports -u tutorialuser -p tutorialsecret
```

With `jq` you can get the `access_token` and store it in an environment variable:

```plain
access_token=$(uaa context | jq -r .access_token)
curl -sSH "Authorization: bearer ${access_token}" http://localhost:9292 | jq length
```

The result will be `297` since the authorized user's access token contains the `airports.all` scope.

With https://jwt.io or a `jwt` CLI, inspect the user's access token:

```plain
$ jwt decode ${access_token}
Token header
------------
{
  "typ": "JWT",
  "alg": "RS256",
  "jku": "https://192.168.50.1:8080/token_keys",
  "kid": "uaa-jwt-key-1"
}

Token claims
------------
{
  "aud": [
    "openid",
    "airports"
  ],
  "auth_time": 1538097346,
  "azp": "airports",
  "cid": "airports",
  "client_id": "airports",
  "email": "drnic@starkandwayne",
  "exp": 1538140546,
  "grant_type": "password",
  "iat": 1538097346,
  "iss": "http://192.168.50.1:8080/oauth/token",
  "jti": "8f57dcfba2ca4efdad6d1b1a393aba81",
  "origin": "uaa",
  "rev_sig": "b3ca88a",
  "scope": [
    "openid",
    "airports.all"
  ],
  "sub": "55eb9261-2511-4025-b089-d3ee35af2c9f",
  "user_id": "55eb9261-2511-4025-b089-d3ee35af2c9f",
  "user_name": "tutorialuser",
  "zid": "uaa"
}
```

### Trusting an access token

The Airports API resource server is receiving an access token - an easily decodable JSON Web Token string - and using its contents to determine what response it should give the request (in the Airports API resource server this decision is "how many results to return"; but for a normal app it might decide "who's data should I return?" or "is this user allowed to edit this data?")

Since it is very easy for anyone to generate their own JWT string, it is critical that the resource server can verify that the JWT string was produced by its own UAA, and was definitely not modified.

A resource server can either validate a JWT:

* online: by asking the UAA to validate it
* offline: by checking its signed token key

Our `quaa up` UAA is using asymmetric signed keys. The UAA uses a secret private key to sign the JWT, and publishes the matching public key at its `/token_keys` API endpoint. It is the responsiblity of each resource server to check that each JWT is signed with one of the keys published at this endpoint.

The decoded JWT access token has a header section that contains:

* the name of the signing token key: `uaa-jwt-key-1`
* the algorithm used to sign the JWT access token: `RS256`
* the URL to fetch the public key: `https://192.168.50.1:8080/token_keys`

NOTE: the JWT token `jku` URL for public keys forced into `https` protocol scheme. If your UAA is not running under `https` then change the URL yourself to `http://`:

```plain
$ curl http://192.168.50.1:8080/token_keys
{
  "keys": [
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "uaa-jwt-key-1",
      "alg": "RS256",
      "value": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxFoMC25Ys2p5ZUqAxvBD\ngdryekS0AgUkT0xYe5Yuhg02Xctj61aj3+7byLwXH1DISfOVLRlTIYmsFRLdjRYb\nRXH5DetA+fw4+eFzt8NNtlcVDgwVKXV7rBs/9kxaMiiWL2vKFE/d956iGqfFXD+W\nPhFnyIg+WwmMdz/X3ERPB23akdAf5iiRCSSrzGxNEsOCAMDgrZb4rm7n3APfctDD\nuC+fIhH6yDt67CwgyWePfkH6MW9vRALzq22kLNnCGKFbolORbG6yZgZ/MZkfVh5h\nUKjpExhlbtvqPopiymRrj7kofvhgy0Mefg/jBpwcbI1BHc9XQYjLAHsraPyKy4dG\nTwIDAQAB\n-----END PUBLIC KEY-----",
      "n": "AMRaDAtuWLNqeWVKgMbwQ4Ha8npEtAIFJE9MWHuWLoYNNl3LY-tWo9_u28i8Fx9QyEnzlS0ZUyGJrBUS3Y0WG0Vx-Q3rQPn8OPnhc7fDTbZXFQ4MFSl1e6wbP_ZMWjIoli9ryhRP3feeohqnxVw_lj4RZ8iIPlsJjHc_19xETwdt2pHQH-YokQkkq8xsTRLDggDA4K2W-K5u59wD33LQw7gvnyIR-sg7euwsIMlnj35B-jFvb0QC86ttpCzZwhihW6JTkWxusmYGfzGZH1YeYVCo6RMYZW7b6j6KYspka4-5KH74YMtDHn4P4wacHGyNQR3PV0GIywB7K2j8isuHRk8"
    }
  ]
}
```

The resource server must check that:

1. The named `"kid": "uaa-jwt-key-1"` in the JWT is available from `/token_keys`. In the example above, it is correctly available.
1. The published `"value"` public key correctly matches the signed portion of the JWT.

In the Ruby version of the Airports API resource server, this behaviour is encoded in the `cf-uaa-lib` library (at the time writing this is in a branch `auto-token-keys` in https://github.com/drnic/cf-uaa-lib fork):

```ruby
decoder = CF::UAA::TokenCoder.decode(access_token, info: uaa_info)
```

Other languages might not have this behaviour refactored into a shared library and might need to implement it themselves. Or refactor it into a shared library for everyone else.

## Learning Objectives Review

The UAA is many things to many people. We've only covered one small subset of its feature set - OAuth2.

## Beyond the Lab

* WIP book - [Ultimate Guide to UAA](https://www-staging.ultimateguidetouaa.com/)