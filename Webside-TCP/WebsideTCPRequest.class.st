"
I am a thin adapter that makes a flat JSON-RPC params dictionary look like an HTTP request to `WebsideAPI`.

In the HTTP server (`WebsideServer`), `WebsideAPI` reads request data via three paths:
- `urlAt: key` — URL path segment (e.g. class name, id)
- `queryAt: key` — query string parameter
- `bodyAt: key` — JSON body field

All three ultimately call `request at: key ifAbsent: block` (for url/query) or parse `request entity` as JSON (for body). I satisfy both interfaces using a single flat `params` dictionary that the JRPC client sends as the `params` field of the JSON-RPC 2.0 request object.

### Protocol convention

The Python (or other) client must flatten all parameters — URL path segments, query params, and body fields — into the `params` object. For example:

```json
{ ""jsonrpc"": ""2.0"", ""method"": ""frameBindings"",
  ""params"": { ""id"": ""some-debugger-uuid"", ""index"": 2 },
  ""id"": 42 }
```

### Creation

```smalltalk
WebsideTCPRequest withParams: aDictionary
```
"
Class {
	#name : #WebsideTCPRequest,
	#superclass : #Object,
	#instVars : [
		'params'
	],
	#category : #'Webside-TCP'
}

{ #category : #'instance creation' }
WebsideTCPRequest class >> withParams: aDictionary [

	^ self new
		  params: aDictionary;
		  yourself
]

{ #category : #accessing }
WebsideTCPRequest >> at: aString ifAbsent: aBlock [
	"Handles both urlAt: and queryAt: lookups which use request at:key ifAbsent:block.
	Params dict contains URL path params, query params, and body fields flattened together."

	^ params at: aString ifAbsent: aBlock
]

{ #category : #accessing }
WebsideTCPRequest >> entity [
	"Return the params dict serialized as JSON so that WebsideAPI>>bodyAt:ifAbsent: can parse it.
	This lets body fields be sent in the same flat params dictionary."

	^ NeoJSONWriter toString: params
]

{ #category : #accessing }
WebsideTCPRequest >> params: aDictionary [

	params := aDictionary
]
