Class {
	#name : #WebsideJRPCMessageProcessor,
	#superclass : #JRPCMessageProcessor,
	#category : #'Webside-TCP'
}

{ #category : #converting }
WebsideJRPCMessageProcessor >> convertJRPCJsonableObjectToJSON: aJRPCJsonableObject on: aStream [
	"Use NeoJSONWriter with asciiOnly: true so that non-ASCII characters in
	 method source code or other content are escaped as \uXXXX sequences,
	 preventing the WriteStream from being promoted to a WideString."

	(NeoJSONWriter on: aStream)
		asciiOnly: true;
		nextPut: aJRPCJsonableObject
]
