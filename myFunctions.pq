
/*fnCleanColNames - Uppercases, removes spaces from Column names; can be modified and expanded */

(OriginalData as any) =>
	let
		CurrentColumnNames = Table.ColumnNames(OriginalData),                                      //Get existing column names
		UppercasedCols = List.Transform(CurrentColumnNames, Text.Upper),                           //Take that list and uppercase it as New List
		RemoveSpaces = List.ReplaceValue(UppercasedCols," ","",Replacer.ReplaceText),
		NamePairing = List.Zip({CurrentColumnNames, RemoveSpaces}),                                 //Pair each list item with the corresponding item from other list
		NewColNames = Table.RenameColumns(OriginalData, NamePairing)                                //With the list of lists "NamePairing" mapping new column names to the ones currently exisitng in PreviousStepUsing RenameCol8n Function, replace with Desired names in zip,														
	in
		NewColNames


				/*ReorderColumnSubsetOnly - ReOrders (and modifies if desired) only specific columns, thus increasing robustness of query by avoiding explicit references to other columns */

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
	Heads
	
	
				/*NESTED RANKINGS */
()
let
    Source = Exchange.Contents("jake@seahag.onmicrosoft.com"),
    People = Source{[Name="People"]}[Data],
    
	//The Grouped Data --- dummy data used below
	Grouped = 
    Table.Group(
        People, 
        {"DisplayName"}, 
        {
            {"Count", each _, type table [Folder Path=text, DisplayName=text, Surname=text, GivenName=text, MiddleName=text, CompanyName=text, JobTitle=text, FileAs=text, OfficeLocation=text, EmailAddresses=record, ImAddresses=record, PhoneNumbers=record, Categories=list, HasAttachments=logical, Attachments=table, Notes=text, Preview=text, Attributes=record, Body=record, Id=text]}
        }
    ),

	//Create Function to loop in transformcolumn

    Ranker = (TableToBeRanked as table) as table =>
    let
        indexer = Table.AddIndexColumn(TableToBeRanked, "Index", 1, 1)
    in
         indexer,
    
	//TransformColumns Trickery!
    nestleRank = Table.TransformColumns(Grouped, {"Count", each Ranker(_)}) 
in
    nestleRank
	
				
				
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
	
	

//END