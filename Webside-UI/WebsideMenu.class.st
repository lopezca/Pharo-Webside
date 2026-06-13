Class {
	#name : #WebsideMenu,
	#superclass : #Object,
	#category : #'Webside-UI'
}

{ #category : #accessing }
WebsideMenu class >> label [ 

	^ 'Webside'
]

{ #category : #menu }
WebsideMenu class >> mainMenu: aBuilder [
<worldMenu>

	(aBuilder item: self menuTag)
		label: self label;
		order: 200;
		icon: (aBuilder iconNamed: #remote)
]

{ #category : #menu }
WebsideMenu class >> menuTag [

	^ #WebsideMenu
]

{ #category : #'as yet unclassified' }
WebsideMenu class >> restartServerMenuClass: aBuilder [

	<worldMenu>
	(aBuilder item: #WebsideRestartServer)
		parent: self menuTag;
		label: 'Restart webside server';
		order: 150;
		icon: (aBuilder iconNamed: #refresh);
		action: [
			WebsideServer restart ]
]
