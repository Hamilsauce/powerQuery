(previousTable as table, searchKey as text, col1Rename as text) as table =>

let 
  unPacker = Table.RenameColumns(
    Table.FromList(
      Table.SelectRows(
        previousTable,  
        each (
          [Name] = searchKey)
        )[Value]{0},
        Splitter.SplitByNothing(), 
        null, 
        null, 
        ExtraValues.Error
      ),
    {
      {
        "Column1",
        col1Rename
      }
    }
  ),
unfoldColumns = Table.ExpandRecordColumn(unPacker, col1Rename, {"name", "start_timestamp", "end_timestamp"}, {"NAME", "EVENTSTART", "EVENTEND"})
in
  unfoldColumns
