Extension { #name : #ReRenameMethodRefactoring }

{ #category : #'*Webside' }
ReRenameMethodRefactoring >> websideExecute [
	"Rename oldSelector to newSelector scoped to class only: unlike the inherited
	#execute (RBChangeMethodNameRefactoring>>#privateTransform), this never renames
	other implementors of oldSelector nor rewrites sends of it in other classes.
	`class` is an RBClass model-wrapper, converted to a real Behavior via #realClass
	so plain Behavior protocol can be used directly instead of RBMethod's staged-
	changes machinery. Steps: (1) rewrite the method's own header via
	#modifyImplementorParseTree:in: and recompile it under newSelector; (2) fix any
	self/super sends of oldSelector in class's other methods via
	RBReplaceMessageSendTransformation, scoped to {class} only (no inAllClasses:);
	(3) remove oldSelector, now that both selectors have coexisted long enough for
	step 2's precondition and nothing references the old one anymore."

	| realClass parseTree |
	oldSelector = newSelector ifTrue: [ ^ self ].
	realClass := class realClass.
	parseTree := realClass parseTreeForSelector: oldSelector.
	self modifyImplementorParseTree: parseTree in: realClass.
	realClass
		compile: parseTree newSource
		classified: (realClass >> oldSelector) protocolName.
	(RBReplaceMessageSendTransformation
		 replaceCallMethod: oldSelector
		 in: realClass
		 to: newSelector
		 permutation: permutation asArray) execute.
	realClass removeSelector: oldSelector
]

{ #category : #'*Webside' }
ReRenameMethodRefactoring class >> websideType [ 
	^'RenameMethod'
]
