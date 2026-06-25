Class {
	#name : #WebsideSettings,
	#superclass : #Object,
	#classInstVars : [
		'useTCP'
	],
	#category : #'Webside-UI'
}

{ #category : #settings }
WebsideSettings class >> connectionTypeSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #useTCP)
		target: self;
		label: 'Use TCP connection';
		description:
			'When enabled, Webside uses a JSON-RPC/TCP server (WebsideTCPServer) instead of HTTP (WebsideServer)';
		parent: #Webside
]

{ #category : #settings }
WebsideSettings class >> groupSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #Webside) label: 'Webside'
]

{ #category : #accessing }
WebsideSettings class >> useTCP [

	^ useTCP ifNil: [ useTCP := true ]
]

{ #category : #accessing }
WebsideSettings class >> useTCP: aBoolean [

	useTCP := aBoolean
]
