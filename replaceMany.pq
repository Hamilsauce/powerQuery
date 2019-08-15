/*Power Query Custom Functions


*/


// 1). Replace Values en Masse

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


// 2). Remove Characters from ColumnNames (Not efficient formula - shouldnt need intermediate transforms - find better function)

let
	FormatColumnNames = (StepName as any) =>
	let
		DemotedHeaders = Table.DemoteHeaders(StepName),
		RemovedTop1Rows = Table.Skip(DemotedHeaders,1),
		TabletoList = Table.ToList(DemotedHeaders),
		TabletoList1 = TabletoList{0},
		RemoveUscore = Text.Replace(Text.Proper(TabletoList1),"_",""),
		RemoveSpaces = Text.Replace(Text.Proper(RemoveUscore)," ",""),
		ConvertedToList = {RemoveSpaces},
		ConvertedToTable = Table.FromList(ConvertedToList , Splitter.SplitTextByDelimiter(","), null, null, ExtraValues.Error),
		Combine = Table.Combine({ConvertedToTable, RemovedTop1Rows}),
		PromotedHeaders = Table.PromoteHeaders(Combine)
	in
	 
		PromotedHeaders
 
in 
	FormatColumnNames