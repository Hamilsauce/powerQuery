LAST UPDATED 7.25.19



/*fnCleanColNames - Uppercases, removes spaces from Column names; can be modified and expanded */

fnCleanCols = (OriginalData as any) =>
	let
	    currentCols  = Table.ColumnNames(OriginalData),                                      
	    //UppercasedCols = List.Transform(Current, Text.Upper),                           
	    //RemoveSpaces = List.ReplaceValue(List.Transform(Current, Text.Upper)," ","",Replacer.ReplaceText),
	    NamePairing =     
                List.Zip( 
                    {currentCols,     
                    List.ReplaceValue(
                        List.Transform(        
                            currentCols, 
                            Text.Upper),
                            " ",    
                            "",
                        Replacer.ReplaceText
                    )}
                ),                         
            NewColNames = Table.RenameColumns(OriginalData, NamePairing)                               
        in
            NewColNames,


/*ReorderColumnSubsetOnly 
- ReOrders (and modifies if desired) only specific columns, 
thus increasing robustness of query by avoiding explicit references to other columns */

(tbl as table, reorderedCols as list, offset as number) as table =>
	let
		reOrder = 
		Table.ReorderColumns(
			tbl,
			List.InsertRange(
				List.Difference(
					Table.ColumnNames(tbl),
					reorderedCols
				),
				offset,
				reorderedCols
			)
		)	
	in
		reOrder


/*fnCleanMultiSpaces - CLEANS MULTIPLE SPACES FROM BETWEEN WORDS IN TEXT */

fnCleanMultiSpaces = (tbl as table, colName as text)  as table =>
let
    //previousStep = RemoveCols2, colName = "colName",
    cleanFn = Table.TransformColumns(
        tbl,
        {{colName,
        each Text.Combine(
            List.Select(
                Text.SplitAny(_, " "),
                each _ <> ""
            )
            ," "
        ),
        type text
        }}
    ) 
in
    cleanFn
		

/*Replace Values en Masse*/

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
	

//New Ranked Groupings 7.25.19

(groupedTable as table, transformCol as text) as table => 
let
    RankWithinGroups = (groupedTable as table) =>
    let
    AddIndex = 
        Table.AddIndexColumn(
            groupedTable,
            "Rank",
            1,1
    )
    in
    AddIndex,
    AddRank = 
        Table.TransformColumns(
            groupedTable, {
            transformCol, 
            each RankWithinGroups(_)
        })
in
	AddRank



	
/*Old Nested Ranks*/

//Create Function to loop in transformcolumn
let
    Ranker = (TableToBeRanked as table) as table =>
    let
        indexer = Table.AddIndexColumn(TableToBeRanked, "Index", 1, 1)
    in
         indexer,
    
	//call the ranking function for each row using TransformColumns function
    nestleRank = Table.TransformColumns(Grouped, {"Count", each Ranker(_)}) 
in
    nestleRank
	

/*SUPER FnCleanColNames*/

let
	Heads = (OriginalData as table) as table=>
	let
		CurrentColumnNames = Table.ColumnNames(
			OriginalData
		),    
		UppercasedCols = List.Transform(
			CurrentColumnNames, Text.Upper
		),
		HeaderToTable = Table.FromList(
			UppercasedCols, Splitter.SplitByNothing(),
			null, null, ExtraValues.Error
		),
		SplitHeader1 = Table.SelectColumns(
			Table.SplitColumn(
				HeaderToTable, "Column1", 
				Splitter.SplitTextByEachDelimiter(
					{" "}, QuoteStyle.Csv, true),
				{"ColumnNames", "Column1.2"}),
			{"ColumnNames"}
		),

		//Embedded fn for replacing specific characters (replace colon with whatever)
		Coloner = (PreviousStep) =>
		let
			RemoveColon = Table.ToList(
				Table.ReplaceValue(
					PreviousStep,":","",
					Replacer.ReplaceText, {"ColumnNames"}
				)
			),    
			RemoveSpaces = List.ReplaceValue(
				RemoveColon ," ","",Replacer.ReplaceText
			),
			NamePairing = List.Zip(
				{CurrentColumnNames, RemoveColon}
			), 
			NewColNames = Table.RenameColumns(
				OriginalData, NamePairing
			) 	   
		in
			NewColNames 
	in
		Coloner(SplitHeader1)
in

				
				



