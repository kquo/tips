---
type: note
---
## Microsoft Access Token Validation

In OAuth2 and OpenID Connect flows with Azure, an access token is issued to a client for use against one resource, and the question I kept running into was who is allowed to validate it. Microsoft's [documentation](https://learn.microsoft.com/en-us/entra/identity-platform/access-tokens#token-ownership) is direct:

> "An access token request involves two parties: the client, who requests the token, and the resource (Web API) that accepts the token. The resource that the token is intended for (its audience) is defined in the `aud` claim in a token. Clients use the token but shouldn't understand or attempt to parse it. Resources accept the token."

So a client should not parse or validate a token; only the intended resource should.

### Why Azure Management tokens can be validated

Azure Management (`https://management.azure.com`) is a resource like any other, but its tokens are often handled by automation, scripts, and external apps; its signing keys are public and consistent; and the tokens are standard JWTs signed with keys available from the JWKS endpoint. Validating one, by checking its signature and claims, is feasible and sometimes useful: to make sure automation is not passing an expired or malformed token, to debug an authentication flow before calling an API, and to audit claims such as tenant and app IDs in a verifiable way.

### Why you should not validate Microsoft Graph tokens

When a request reaches Microsoft Graph with a bearer token, Graph extracts it from the `Authorization` header and uses its own trust system, backed by Entra ID, to fetch the signing keys, verify the signature, and confirm claims such as `aud`, `iss`, `exp`, and `nbf`. Graph is the resource, so it owns validation. The client should treat the token as opaque: its structure is not guaranteed to stay stable, and validating it client-side adds security and compatibility risk for no benefit.

My rule: validate an Azure token when you control the resource or need introspection, and never validate a Graph token client-side. Treat tokens as bearer credentials, not as application-owned data.
