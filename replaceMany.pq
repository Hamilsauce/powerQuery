/* Replace Values en Masse */

(x as text) as text =>
let
	maxIterations = Table.RowCount(TranslationTable),
	
	Iterations = List.Generate( () =>
		[Result = Text.Replace(x, TranslationTable[OldText]{0}, TranslationTable[NewText]{0}), Counter = 0],
			each [Counter] < maxIterations,
			each [Result = Text.Replace[Result], TranslationTable[OldText]{Counter}, TranslationTable[NewText]{Counter}),
		Counter = [Counter] +1], each [Result]),
	output = Iterations{maxIterations -1}
in
	output
