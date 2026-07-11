Class {
	#name : #WebsideMenu,
	#superclass : #Object,
	#category : #'Webside-UI'
}

{ #category : #'server control' }
WebsideMenu class >> isServerRunning [

	^ WebsideServer current notNil
]

{ #category : #'world menu' }
WebsideMenu class >> label [

	^ 'Webside'
]

{ #category : #'world menu' }
WebsideMenu class >> mainMenu: aBuilder [
	<worldMenu>

	(aBuilder item: self menuTag)
		label: self label;
		order: 200;
		icon: (aBuilder iconNamed: #remote)
]

{ #category : #'world menu' }
WebsideMenu class >> menuTag [

	^ #WebsideMenu
]

{ #category : #'server control' }
WebsideMenu class >> resetServer [

	WebsideServer stop.
	WebsideServer start
]

{ #category : #'world menu' }
WebsideMenu class >> resetServerMenu: aBuilder [
	<worldMenu>

	(aBuilder item: #WebsideResetServer)
		parent: self menuTag;
		label: 'Reset server instance';
		order: 110;
		icon: (aBuilder iconNamed: #refresh);
		action: [ self resetServer ]
]

{ #category : #'server control' }
WebsideMenu class >> toggleServer [

	self isServerRunning
		ifTrue: [ WebsideServer stop ]
		ifFalse: [ WebsideServer start ]
]

{ #category : #'world menu' }
WebsideMenu class >> toggleServerLabel [

	^ self isServerRunning
		ifTrue: [ '[X] Server running, turn off' ]
		ifFalse: [ '[ ] Server inactive, turn on' ]
]

{ #category : #'world menu' }
WebsideMenu class >> toggleServerMenu: aBuilder [
	<worldMenu>

	(aBuilder item: #WebsideToggleServer)
		parent: self menuTag;
		label: self toggleServerLabel;
		order: 100;
		action: [ self toggleServer ]
]
