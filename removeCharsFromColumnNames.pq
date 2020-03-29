/*  Remove Several Characters from Column Names  */
//  (Not efficient formula - shouldnt need intermediate transforms - find better function)

FormatColumnNames = (previousTable as any) =>
let
    colNamesList = Table.ColumnNames(previousTable),
    // nest as many replace functions as neeeded - the deepest/most nested function must use 'colNamesList' as its list reference
    removeChars =
    List.ReplaceValue( // 1. remove spaces for example
        List.ReplaceValue( // 2. remove underscores for example
            colNamesList, "_", "", Replacer.ReplaceText
        ),
        " ", "", Replacer.ReplaceText
    ),
    ConvertedToTable = Table.FromList(ConvertedToList , Splitter.SplitTextByDelimiter(","), null, null, ExtraValues.Error)
    Combine = Table.Combine({ConvertedToTable, RemovedTop1Rows}),
    PromotedHeaders = Table.PromoteHeaders(Combine)
in
    PromotedHeaders
