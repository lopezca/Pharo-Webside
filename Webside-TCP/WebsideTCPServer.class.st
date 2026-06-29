"
I am a Webside API server that transports requests over **JSON-RPC 2.0 via raw TCP** instead of HTTP.

I mirror `WebsideServer` (which uses Teapot/HTTP) but use a `JRPCTCPServer` as the underlying transport. Each HTTP route in `WebsideServer` becomes a named JRPC method here: the method name equals the `WebsideAPI` selector (e.g. `classDefinition`, `evaluateExpression`).

### Parameter encoding

All HTTP routing parameters (URL path segments, query string keys, and body fields) are flattened into a single JSON object sent as the JRPC `params`. For example:

```
GET /pharo/classes/OrderedCollection
```
becomes:
```json
{ ""jsonrpc"": ""2.0"", ""method"": ""classDefinition"",
  ""params"": { ""name"": ""OrderedCollection"" }, ""id"": 1 }
```

### Starting the server

```smalltalk
WebsideTCPServer start.   ""singleton on default port 9003""
WebsideTCPServer stop.
WebsideTCPServer restart.
```

Or with a custom port:
```smalltalk
WebsideTCPServer new port: 9005; start.
```

### Key collaborators

- `JRPCTCPServer` — the TCP transport layer (one connection per request).
- `WebsideJRPCHandler` — one instance per API method; bridges JRPC params to `WebsideAPI`.
- `WebsideTCPRequest` — wraps the flat params dict so `WebsideAPI` accessors work transparently.
- `WebsideAPI` — the actual API implementation, shared with the HTTP server.

### Result normalization

`resultFrom:` normalizes every result through a `NeoJSONWriter` → `STONJSON` round-trip. This is required because `NeoJSONObject` intercepts `asJRPCJSON` via `doesNotUnderstand:` (maps unknown unary messages to dictionary key lookups), which would silently produce `nil` without the conversion.
"
Class {
	#name : #WebsideTCPServer,
	#superclass : #Object,
	#instVars : [
		'server',
		'apiClass',
		'port',
		'resources'
	],
	#classInstVars : [
		'defaultPort',
		'current'
	],
	#category : #'Webside-TCP'
}

{ #category : #accessing }
WebsideTCPServer class >> current [

	^ current
]

{ #category : #accessing }
WebsideTCPServer class >> current: aWebsideTCPServer [

	current := aWebsideTCPServer
]

{ #category : #accessing }
WebsideTCPServer class >> defaultPort [

	^ defaultPort ifNil: [ 9003 ]
]

{ #category : #accessing }
WebsideTCPServer class >> defaultPort: anInteger [

	defaultPort := anInteger
]

{ #category : #'instance creation' }
WebsideTCPServer class >> restart [

	<script>
	self stop.
	^ self start
]

{ #category : #'instance creation' }
WebsideTCPServer class >> start [

	<script>
	current ifNotNil: [ current stop ].
	current := self new
		           port: self defaultPort;
		           start.
	^ current
]

{ #category : #'instance creation' }
WebsideTCPServer class >> stop [

	<script>
	current ifNil: [ ^ self ].
	current stop.
	current := nil
]

{ #category : #resources }
WebsideTCPServer >> addChange: change [

	self changes add: change
]

{ #category : #accessing }
WebsideTCPServer >> apiClass [

	^ apiClass
]

{ #category : #accessing }
WebsideTCPServer >> apiClass: aClass [

	apiClass := aClass
]

{ #category : #resources }
WebsideTCPServer >> changes [

	^ self resourcesAt: #changes
]

{ #category : #resources }
WebsideTCPServer >> debuggers [

	^ self resourcesAt: #debuggers
]

{ #category : #accessing }
WebsideTCPServer >> defaultPort [

	^ self class defaultPort
]

{ #category : #'request handling' }
WebsideTCPServer >> errorResponseFor: anError [
	"Build a JSON-serializable error description from a Smalltalk error."

	^ Dictionary new
		  at: 'error' put: anError messageText;
		  at: 'class' put: anError class name;
		  yourself
]

{ #category : #resources }
WebsideTCPServer >> evaluations [

	^ self resourcesAt: #evaluations
]

{ #category : #initialization }
WebsideTCPServer >> initialize [

	super initialize.
	apiClass := WebsideAPI.
	port := self defaultPort.
	self initializeResources
]

{ #category : #initialization }
WebsideTCPServer >> initializeChangesRoutes [

	self
		registerHandler: #changes;
		registerHandler: #addChange
]

{ #category : #initialization }
WebsideTCPServer >> initializeCodeRoutes [

	self
		registerHandler: #packages;
		registerHandler: #package;
		registerHandler: #packageClasses;
		registerHandler: #packageMethods;
		registerHandler: #classes;
		registerHandler: #classDefinition;
		registerHandler: #subclasses;
		registerHandler: #superclasses;
		registerHandler: #variables;
		registerHandler: #instanceVariables;
		registerHandler: #classVariables;
		registerHandler: #categories;
		registerHandler: #usedCategories;
		registerHandler: #classFileOut;
		registerHandler: #selectors;
		registerHandler: #methods;
		registerHandler: #method;
		registerHandler: #methodFileOut;
		registerHandler: #allCategories;
		registerHandler: #usualCategories;
		registerHandler: #autocompletions;
		registerHandler: #search;
		registerHandler: #classTemplate;
		registerHandler: #methodTemplate;
		registerHandler: #selectorInSource
]

{ #category : #initialization }
WebsideTCPServer >> initializeCommandsRoutes [

	self
		registerHandler: #commandDefinitions;
		registerHandler: #processCommand
]

{ #category : #initialization }
WebsideTCPServer >> initializeDebuggingRoutes [

	self
		registerHandler: #activeDebuggers;
		registerHandler: #createDebugger;
		registerHandler: #debuggerFrames;
		registerHandler: #debuggerFrame;
		registerHandler: #frameBindings;
		registerHandler: #stepIntoDebugger;
		registerHandler: #stepOverDebugger;
		registerHandler: #stepThroughDebugger;
		registerHandler: #runToCursorDebugger;
		registerHandler: #restartDebugger;
		registerHandler: #resumeDebugger;
		registerHandler: #terminateDebugger;
		registerHandler: #deleteDebugger
]

{ #category : #initialization }
WebsideTCPServer >> initializeEpiceaRoutes [

	self
		registerHandler: #epiceaFiles;
		registerHandler: #epiceaChanges;
		registerHandler: #epiceaChange
]

{ #category : #initialization }
WebsideTCPServer >> initializeEvaluationRoutes [

	self
		registerHandler: #evaluateExpression;
		registerHandler: #activeEvaluations;
		registerHandler: #activeEvaluation;
		registerHandler: #cancelEvaluation;
		registerHandler: #pauseEvaluation;
		registerHandler: #resumeEvaluation
]

{ #category : #initialization }
WebsideTCPServer >> initializeExtensionsRoutes [

	self registerHandler: #extensions
]

{ #category : #initialization }
WebsideTCPServer >> initializeGeneralRoutes [

	self
		registerHandler: #dialect;
		registerHandler: #version;
		registerHandler: #logo;
		registerHandler: #colors;
		registerHandler: #saveImage;
		registerHandler: #stats;
		registerHandler: #themes;
		registerHandler: #icons;
		registerHandler: #desktopImage
]

{ #category : #initialization }
WebsideTCPServer >> initializeObjectsRoutes [

	self
		registerHandler: #pinnedObjects;
		registerHandler: #pinnedObject;
		registerHandler: #unpinObject;
		registerHandler: #pinnedObjectSlots;
		registerHandler: #pinObjectSlot;
		registerHandler: #unpinAllObjects
]

{ #category : #initialization }
WebsideTCPServer >> initializePharoGitRoutes [

	self
		registerHandler: #pharogitRepositories;
		registerHandler: #pharogitWorkingCopyPackages;
		registerHandler: #pharogitBranches;
		registerHandler: #pharogitCommitLog;
		registerHandler: #pharogitDiff
]

{ #category : #initialization }
WebsideTCPServer >> initializeProfilingRoutes [

	self
		registerHandler: #profileExpression;
		registerHandler: #activeProfilers;
		registerHandler: #activeProfiler;
		registerHandler: #profilerTreeResults;
		registerHandler: #profilerRankingResults;
		registerHandler: #deleteProfiler
]

{ #category : #initialization }
WebsideTCPServer >> initializeResources [

	resources := Dictionary new.
	resources
		at: #evaluations put: Dictionary new;
		at: #objects put: Dictionary new;
		at: #workspaces put: Dictionary new;
		at: #debuggers put: Dictionary new;
		at: #testRuns put: Dictionary new;
		at: #changes put: OrderedCollection new;
		at: #profilers put: Dictionary new
]

{ #category : #initialization }
WebsideTCPServer >> initializeRoutes [

	self
		initializeGeneralRoutes;
		initializeCodeRoutes;
		initializeChangesRoutes;
		initializeEvaluationRoutes;
		initializeObjectsRoutes;
		initializeWorkspacesRoutes;
		initializeDebuggingRoutes;
		initializeTestsRoutes;
		initializeProfilingRoutes;
		initializeExtensionsRoutes;
		initializeCommandsRoutes;
		initializeEpiceaRoutes;
		initializePharoGitRoutes
]

{ #category : #initialization }
WebsideTCPServer >> initializeServer [

	server := JRPCTCPServer new.
	server port: port.
	server messageProcessor: WebsideJRPCMessageProcessor new
]

{ #category : #initialization }
WebsideTCPServer >> initializeTestsRoutes [

	self
		registerHandler: #activeTestRuns;
		registerHandler: #runTests;
		registerHandler: #testRunStatus;
		registerHandler: #testRunResults;
		registerHandler: #runTestRun;
		registerHandler: #debugTest;
		registerHandler: #stopTestRun;
		registerHandler: #deleteTestRun
]

{ #category : #initialization }
WebsideTCPServer >> initializeWorkspacesRoutes [

	self
		registerHandler: #createWorkspace;
		registerHandler: #activeWorkspaces;
		registerHandler: #workspace;
		registerHandler: #updateWorkspace;
		registerHandler: #deleteWorkspace;
		registerHandler: #workspaceBindings
]

{ #category : #resources }
WebsideTCPServer >> objects [

	^ self resourcesAt: #objects
]

{ #category : #accessing }
WebsideTCPServer >> port [

	^ port
]

{ #category : #accessing }
WebsideTCPServer >> port: anInteger [

	port := anInteger
]

{ #category : #resources }
WebsideTCPServer >> profilers [

	^ self resourcesAt: #profilers
]

{ #category : #routing }
WebsideTCPServer >> registerHandler: aSymbol [
	"Register a JRPC handler that maps the method name (=aSymbol) to a WebsideAPI call."

	server addHandler:
		(WebsideJRPCHandler selector: aSymbol server: self)
]

{ #category : #lifecycle }
WebsideTCPServer >> reset [

	self debuggers removeAll.
	self evaluations removeAll.
	self objects removeAll.
	self workspaces removeAll
]

{ #category : #resources }
WebsideTCPServer >> resourcesAt: aSymbol [

	^ resources at: aSymbol ifAbsent: nil
]

{ #category : #resources }
WebsideTCPServer >> resourcesAt: aSymbol put: anObject [

	resources at: aSymbol put: anObject
]

{ #category : #'request handling' }
WebsideTCPServer >> resultFrom: anObject [
	"Extract a JRPC-serializable result from what WebsideAPI returned.
	ZnResponse objects are unwrapped; all results are normalized through a JSON
	round-trip (NeoJSONWriter -> STONJSON) so NeoJSONObjects become plain Dictionaries
	that JRPC can serialize correctly."

	| raw |
	(anObject isKindOf: ZnResponse)
		ifTrue: [
				anObject isSuccess
					ifTrue: [
							anObject hasEntity ifFalse: [ ^ nil ].
							^ STONJSON fromString: anObject entity contents ]
					ifFalse: [
							Error signal:
								'Webside error ' , anObject status code printString , ': '
								, anObject statusLine reasonPhrase ] ]
		ifFalse: [ raw := anObject ].
	^ STONJSON fromString: (NeoJSONWriter toString: raw)
]

{ #category : #lifecycle }
WebsideTCPServer >> start [

	self
		initializeServer;
		initializeRoutes;
		reset.
	server start
]

{ #category : #lifecycle }
WebsideTCPServer >> stop [

	server stop
]

{ #category : #resources }
WebsideTCPServer >> testRuns [

	^ self resourcesAt: #testRuns
]

{ #category : #resources }
WebsideTCPServer >> workspaces [

	^ self resourcesAt: #workspaces
]
