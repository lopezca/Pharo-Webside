Class {
	#name : #GtHomeWebsideGetStartedSection,
	#superclass : #GtHomeMultiCardSection,
	#category : #gt4Webside
}

{ #category : #'private - webside status' }
GtHomeWebsideGetStartedSection >> currentWebsideServer [
	^ WebsideServer current
]

{ #category : #accessing }
GtHomeWebsideGetStartedSection >> defaultPriority [
	^ 30
]

{ #category : #cards }
GtHomeWebsideGetStartedSection >> gtWebsideServerCard [
	<gtSectionCard>

	^ GtHomeCard explicit
		priority: 51;
		stencil: [ self websideServerStatusCardElement ]
]

{ #category : #accessing }
GtHomeWebsideGetStartedSection >> sectionTitle [
	^ 'Webside'
]

{ #category : #'private - webside status' }
GtHomeWebsideGetStartedSection >> websideServerEndpoint [
	| ws |
	ws := self currentWebsideServer.
	^ ws
		ifNil: [ 'http://localhost:' , WebsideServer defaultPort asString , WebsideServer defaultBaseUri asString ]
		ifNotNil: [ [ ws baseUrl asString ]
				on: Error
				do: [ 'http://localhost:' , ws port asString , ws baseUri asString ] ]
]

{ #category : #'private - webside status' }
GtHomeWebsideGetStartedSection >> websideServerIsRunning [
	| ws |
	ws := self currentWebsideServer.
	^ ws notNil
		and: [ [ ws server server isRunning ]
				on: Error
				do: [ false ] ]
]

{ #category : #cards }
GtHomeWebsideGetStartedSection >> websideServerStatusCardElement [
	| container titleLabel endpointLabel button |
	container := BrVerticalPane new
			matchParent;
			alignCenter;
			cellSpacing: 10.
	container
		padding: (BlInsets all: 20);
		margin: (BlInsets
				top: self spaceGap
				left: 2 * self spaceGap
				bottom: 2 * self spaceGap
				right: 2 * self spaceGap);
		background: Color white;
		addAptitude: BrShadowAptitude new beLarge;
		hExact: 350;
		vExact: 400.
	titleLabel := BrLabel new
			beLargeSize;
			aptitude: BrGlamorousLabelAptitude new bold;
			text: 'Webside Server' asRopedText.
	endpointLabel := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: self websideServerStatusLine asRopedText.
	button := BrButton new
			aptitude: BrGlamorousButtonWithLabelAptitude;
			label: 'Reset Webside server';
			action: [ :aButton |
				self websideServerIsRunning
					ifTrue: [ WebsideServer restart ]
					ifFalse: [ WebsideServer start ] ].
	container
		addChild: titleLabel;
		addChild: endpointLabel;
		addChild: button.
	^ container
]

{ #category : #'private - webside status' }
GtHomeWebsideGetStartedSection >> websideServerStatusLine [
	^ self websideServerIsRunning
		ifTrue: [ 'Running on ' , self websideServerEndpoint ]
		ifFalse: [ 'Configured endpoint: ' , self websideServerEndpoint ]
]
