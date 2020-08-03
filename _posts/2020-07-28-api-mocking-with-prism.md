---
title: "API Mocking with Prism"
date: 2020-07-18 18:31:00 +1000
categories: mocking prism
---

Recently my team has been working on API integration with a third party service.
Unfortunately, for some reason we do not yet have access to a sandbox
environment. Didn't want to be blocked by this, we decided to build a local
mocked API server.

Luckily for us, we were able to find an [OpenAPI][] specification file for the
API of this service and also discovered an excellent tool called [Prism][] for
creating a mock server out of that. This offers a very simple way to
spin up a local mock server with all the endpoints mocked. And with minimal
changes to the specification file, the ability to send back custom
responses if necessary.

## Setup

In this post, I'll use the OpenAPI [specification file][] of the [PetStore API][]
to demonstrate what [Prism][] has to offer. Please download it as well if you'd
like to follow along.

```bash
curl -o petstore.json https://raw.githubusercontent.com/api-evangelist/swagger/master/dev-api-openapi.json
```

> Note: The OpenAPI specification can be in JSON or YAML formats, but I'm be
> using JSON in this post.

You'll also need to install the [prism npm package][] by

```bash
npm install -g @stoplight/prism-cli
```

And then run

```bash
prism mock petstore.json
```

If everything goes well, your local mock server for the PetStore API should be
running :tada:.

## Add Example Responses

Having the server running is great, but at this point it would only return empty
responses because no example response has been defined in the JSON file. To add
example responses for various HTTP status codes, you'll need to edit the
`petstore.json` file.

For instance, say we'd like the `/pet/:petId` endpoint to return the following
example response for a successful GET request:

```json
{
  "id": 3,
  "name": "Kitten",
  "status": "available"
}
```

What we need to do is to add an `examples` key under `paths` -> `/pet/{petId}` ->
`get` -> `responses` -> `200` -> `content` -> `application/json` with the following
value:

```json
  "examples": {
    "success": {
      "value": {
        "id": 3,
        "name": "Kitten",
        "status": "available"
      }
    }
  }
```

For failure cases, say we want to add a 400 example response for the same
endpoint, it would involve adding the following under `paths` -> `/pet/{petId}`
-> `get` -> `responses` -> `200` -> `content` -> `application/json`:

```json
  "examples": {
    "failure": {
      "value": {
        "message": "Bad Request"
      }
    }
  }
```

Of course there are a lot more you could do with the specification file. I'm
just scratching the surface here. Please refer to the [Responses Object
Example][] section in the OpenAPI Specification for more information.

## Send Requests

Now that we have a local mock server with a butch of endpoints, and the
capability of returning desired example responses, it's time to send some sample
requests. Surely creating all the requests manually in your favorite HTTP client
would work, but if you use [Postman][], there is a better alternative. Postman
can directly import the OpenAPI specification file and create a new collection
with requests for each endpoint. After that you might still need to fill in some
variables like `baseUrl` for all endpoints or `petId` for the `/pet/:petId`
endpoint. But being able to import from the OpenAPI specification file still
saves a lot of effort.

Please refer to the screenshots below:

* Postman Environment Configuration
![environment configuration][]
* get `/pet/:petId/` endpoint
![get endpoint example][]

## Warning before Celebration

Being able to create a local mock server and to send sample requests to it are
definitely useful in some scenarios. Maybe you (like us) want to start the
development work before having access to the sandbox environment; or maybe you
would like some confirmations before sending out requests to the real API
server. But regardless, please always bear in mind that no matter how well it
worked with the mock server, this does _NOT_ replace actually integrating with
the API server and verifying things actually work. The work is far from done
with requests just hitting a local mock server. Again, always test with the
real API server and make sure everything works as expected.

## Summary

As you can see, if a third party service offer an OpenAPI specification file, it
is reasonably simple to get a local mock server up and running with Prism for
their API. It is also very approachable to add example responses for the mocked
endpoints by editing the specification file. Since Postman can import an OpenAPI
specification file into a Postman collection, sending sample requests to the
mock server is super easy as well.

[OpenAPI]: http://spec.openapis.org/oas/v3.0.3
[Responses Object Example]: http://spec.openapis.org/oas/v3.0.3#responses-object-example
[Postman]: https://www.postman.com/downloads/
[Prism]: https://meta.stoplight.io/docs/prism/README.md
[specification file]: https://raw.githubusercontent.com/api-evangelist/swagger/master/dev-api-openapi.json
[PetStore API]: https://petstore.swagger.io/
[prism npm package]: https://www.npmjs.com/package/prismjs
[environment configuration]: /assets/images/2020-07-31/postman-env-config.png
[get endpoint example]: /assets/images/2020-07-31/postman-get-pet.png
