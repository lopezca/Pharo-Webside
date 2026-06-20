"
I am a JSON-RPC handler that bridges a single JRPC method call to the corresponding `WebsideAPI` selector.

I am a subclass of `JRPCAbstractHandler`. One instance is registered on the `JRPCTCPServer` for each `WebsideAPI` selector. My method name (the JRPC method string) equals the selector name.

### How I work

When the JRPC server receives a request whose method name matches mine, it calls `executeWithArguments: paramsOrNil` with the JRPC `params` value (a `Dictionary` for named params, or `nil` if absent).

I then:
1. Normalize `paramsOrNil` to a `Dictionary` (empty dict if nil or not a dictionary).
2. Wrap it in a `WebsideTCPRequest` so `WebsideAPI` accessors (`urlAt:`, `queryAt:`, `bodyAt:`) work transparently.
3. Create a `WebsideAPI` instance configured with the `WebsideTCPServer` and the request.
4. Invoke the selector via `api perform: handlerSelector`.
5. Route the result through `tcpServer resultFrom:` to normalize `ZnResponse` and `NeoJSONObject` values.

### Creation

```smalltalk
WebsideJRPCHandler selector: #classDefinition server: aTCPServer
```
"
Class {
	#name : #WebsideJRPCHandler,
	#superclass : #JRPCAbstractHandler,
	#instVars : [
		'handlerSelector',
		'tcpServer'
	],
	#category : #'Webside-TCP'
}

{ #category : #'instance creation' }
WebsideJRPCHandler class >> selector: aSymbol server: aWebsideTCPServer [

	^ self new
		  handlerSelector: aSymbol;
		  tcpServer: aWebsideTCPServer;
		  methodName: aSymbol asString;
		  yourself
]

{ #category : #handler }
WebsideJRPCHandler >> executeWithArguments: paramsOrNil [
	"paramsOrNil is a Dictionary (named params) or nil from the JRPC request.
	We wrap it in a WebsideTCPRequest so WebsideAPI accessors work transparently."

	| params request api result |
	params := paramsOrNil ifNil: [ Dictionary new ].
	params isDictionary ifFalse: [ params := Dictionary new ].
	request := WebsideTCPRequest withParams: params.
	api := tcpServer apiClass new
		       server: tcpServer;
		       request: request.
	result := [ api perform: handlerSelector ]
		          on: Error
		          do: [ :e | ^ tcpServer errorResponseFor: e ].
	^ tcpServer resultFrom: result
]

{ #category : #accessing }
WebsideJRPCHandler >> handlerSelector: aSymbol [

	handlerSelector := aSymbol
]

{ #category : #accessing }
WebsideJRPCHandler >> tcpServer: aWebsideTCPServer [

	tcpServer := aWebsideTCPServer
]
