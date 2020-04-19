//Query: fnTableFromBinary - Extracts tables from binary, manipulates nested data within the tables prior to expanding column
//Itsbegins with the querying of a file/web/folder data sources and extracting  binary file is in column

let
    Source = (parameterFile as binary) => 
    let
        //filter out non-table data rows returned by the Web.Page function
        getTables = 
            Table.SelectRows(
                Web.Page(Parameter1),
                each ([Source] = "Table")
        ),

        //Drills down on table data (rather than expand the columsn...better for robustness), and with the data returned by drill down,
        //promotes headers, creates ID col.
        DrillAndPromote =
            Table.AddIndexColumn(
                Table.PromoteHeaders(
                    getTables{0}[Data]
                ),
                "ID", 1, 1
            ),
        //The newly exposed data has rows containing table names filtered out by filtering against ":"
        //then adds a column filled only with application name
        AddedAppColumn = 
            Table.AddColumn(
                Table.SelectRows(
                    DrillAndPromote,
                    each not (Text.Contains([Action],":")) //= true
                ),
                "Application", 
                each "Chrome", 
                type text
            ),
        //Looks for empty fields in Shortcuts column and then extracts the value in Action for that column 
        //as category/table header. Fills down.
        getCatsInColumn = 
            Table.FillDown(
                Table.AddColumn(
                    AddedAppColumn, 
                    "Category", 
                    each if 
                        Text.Length([Shortcut]) < 1 
                    then [Action] else null
                ),
                {"Category"}
            )
    in
        getCatsInColumn
in 
    Source






//Query: compiledChromeShortcuts
//This query does not extract table data from binaries, it was shortened to accommodate a different table





let
    Source = 
        Excel.CurrentWorkbook(){[Name="Table1"]}[Content],
    PromoteHeads = 
        Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    AddedAppColumn = 
        Table.AddColumn(
            Table.SelectRows(
                PromoteHeads,
                each not (
                    Text.Contains([Action], ":")
                ) //= true
            ),
            "Application", 
            each "Chrome", 
            type text
        ),
    AddIndex = 
        Table.AddIndexColumn(
            AddedAppColumn,
            "Index",
             1, 1
        ),
    getCatsInColumn = 
        Table.FillDown(
            Table.AddColumn(
                AddIndex, 
                "Category", 
                each if [Shortcut] = null  
                    then [Action]
                else if [Index] = 1
                    then "Tab And Window"
                else null         
            ),
        {"Category"}
    ),
    filterLast = 
        Table.SelectRows(getCatsInColumn, each [Shortcut] <> null and [Shortcut] <> "Shortcut"),
    orderCols = 
        Table.ReorderColumns(filterLast, {"Index","Action","Shortcut","Category","Application"}),
    #"Cleaned Text" = Table.TransformColumns(orderCols,{{"Action", Text.Clean, type text}, {"Shortcut", Text.Clean, type text}, {"Category", Text.Clean, type text}, {"Application", Text.Clean, type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Cleaned Text",{{"Action", Text.Trim, type text}, {"Shortcut", Text.Trim, type text}, {"Category", Text.Trim, type text}, {"Application", Text.Trim, type text}}),
    #"Uppercased Text" = Table.TransformColumns(#"Trimmed Text",{{"Shortcut", Text.Upper, type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Uppercased Text","  "," ",Replacer.ReplaceText,{"Shortcut"})
  in
    #"Replaced Value"


//TABLE: Example using the above function

let
    Source = Folder.Files("C:\Users\jacob\OneDrive - Sea Hag Enterprises\002 Keyboard Shortcuts Project\Google"),
    #"Filtered Rows" = Table.SelectRows(Source, each Text.StartsWith([Extension], ".html") or Text.StartsWith([Extension], ".HTM")),
    #"Added Index" = Table.AddIndexColumn(#"Filtered Rows", "Index", 1, 1),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Index",{"Index","Name", "Date modified", "Content"}),
    #"Filtered Hidden Files1" = Table.SelectRows(#"Removed Other Columns", each [Attributes]?[Hidden]? <> true),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File", each fnBuildTable([Content])),
    #"Removed Other Columns1" = Table.SelectColumns(#"Invoke Custom Function1", {"Transform File"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File", Table.ColumnNames(fnBuildTable(#"Sample File")))
in
    #"Expanded Table Column1"
