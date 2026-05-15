Extension { #name : #CodeError }

{ #category : #'*Webside' }
CodeError >> asWebsideJson [
	| interval |
	interval := NeoJSONObject new
		at: 'start' put: self location;
		at: 'end' put: self location; yourself.
	^ super asWebsideJson
		at: 'description' put: self messageText;
		at: 'interval' put: interval;
		yourself
		
]
