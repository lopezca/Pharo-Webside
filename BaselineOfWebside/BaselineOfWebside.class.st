Class {
	#name : #BaselineOfWebside,
	#superclass : #BaselineOf,
	#category : #BaselineOfWebside
}

{ #category : #baselines }
BaselineOfWebside >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
				self dependencyJRPC: spec.
				
			spec
				package: 'Webside' with: [ spec requires: #('Teapot' 'NeoJSON' 'JRPC') ];
		
				package: 'Webside-Tests' with: [ spec requires: #('Webside') ] ]
]

{ #category : #'as yet unclassified' }
BaselineOfWebside >> dependencyJRPC: spec [

	spec
		baseline: 'JRPC'
			with: [ spec
				repository: 'github://panalcloud/JRPC/src:main';
				loads: #('Deployment') ];
		import: 'JRPC'.
]

{ #category : #baselines }
BaselineOfWebside >> projectClass [

^ MetacelloCypressBaselineProject 
]

{ #category : #baselines }
BaselineOfWebside >> setUpDependencies: spec [

	spec
		baseline: 'Teapot'
		with: [ spec repository: 'github://zeroflag/Teapot/source' ].


	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON/repository' ]
]
