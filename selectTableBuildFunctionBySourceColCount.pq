// tocList
let
    Source = Pdf.Tables(File.Contents("C:\Users\jacob\OneDrive - Sea Hag Enterprises\008 - Coding and Dev Documents\Javascript, CSS, HTML\JavaScript Cheat Sheet.pdf")),
    #"Filtered Rows" = Table.SelectRows(Source, each [Name] <> "Page001" and [Name] <> "Page002" and [Name] <> "Table001 (Page 1)"),
    #"Replaced Value" = Table.ReplaceValue(#"Filtered Rows","Table002","toc",Replacer.ReplaceText,{"Id"}),
    Data1 = #"Replaced Value"{0}[Data],
    #"Uppercased Text" = Table.TransformColumns(Data1,{{"Column1", Text.Upper, type text}}),
    Column1 = #"Uppercased Text"[Column1]
in
    Column1

// getLastRowVal, to fill new column with as category/groupId col
(table as table) as any =>
let
    lastRowVal =
        Number.FromText(
            Text.Split(
            table{Table.RowCount(table) - 1}[Column1],
            " "
        ){0}
    )
in
  lastRowVal

// extractPageNumber
(previousTable as table) as number =>
let
  page = previousTable,
  lastRowVal = (table as table) =>
  let
    getLastRowVal2 = Number.FromText(
        Text.Split(
            table{Table.RowCount(table) - 1}[Column1],
            " "
        ){0}
    ),
    pageColumn = Table.AddColumn(table, "Column2", each getLastRowVal(table))
  in
    pageColumn,
  constructCol = lastRowVal(page)
in
  constructCol



// singleColumnTable
(table as table) as table =>
let
    pageColumn = Table.AddColumn(table, "Page Number", each getLastRowVal(table)),
    removePageNumberRow = Table.RemoveLastN(pageColumn,1),
    splitColumn1 = Table.SplitColumn(removePageNumberRow, "Column1", Splitter.SplitTextByEachDelimiter({" — "}, QuoteStyle.Csv, false), {"Method/Property", "Description"})
in
  splitColumn1

// twoColumnTable
(table as table) as table =>
let
    twoColsToOne = Table.CombineColumns(table,{"Column1", "Column2"},Combiner.CombineTextByDelimiter("", QuoteStyle.None),"Column1"),
    pageColumn = Table.AddColumn(twoColsToOne, "Page Number", each getLastRowVal(twoColsToOne)),
    removePageNumberRow = Table.RemoveLastN(pageColumn,1),
    splitColumn1 = Table.SplitColumn(removePageNumberRow, "Column1", Splitter.SplitTextByEachDelimiter({" — "}, QuoteStyle.Csv, false), {"Method/Property", "Description"})
in
  splitColumn1

// buildTables
(table as table) as table =>

let
  pickFunctionAndExecute =
    if Table.ColumnCount(table) = 1 then
      singleColumnTable(table)
    else if Table.ColumnCount(table) = 2 then
      twoColumnTable(table)
    else twoColumnTable(table)
in
  pickFunctionAndExecute