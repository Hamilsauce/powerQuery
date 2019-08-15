
// Create a new column that contains for each row the sum of a column in a nested group table

sumNestedColumn =

    (groupedTable as table, columnOfTables as any, nestedColumn as any) as table =>
    
    let
        addSumColumn = 
            Table.AddColumn(
                groupedTable, 
                "Sum Column", 
                each List.Sum(
                    [columnOfTables][nestedColumn]
            )
        )
    in
        addSumColumn





Example in context:

let
    groupedByTopFolders = 
        Table.Group(
           splitCols, 
           {"Folder"}, 
           {
               {
                    "SubFolderGroups", 
                    each _, 
                    type table [
                        Folder=text, 
                        Subfolders=text, 
                        FolderGroups=table, 
                        FileCount=number
                    ]   
                }, 
                {
                    "FileCount", 
                    each Table.RowCount(_), 
                    type number
                }
            }
        ),

    addSumColumn = 
        Table.AddColumn(
            groupedByTopFolders, 
            "Sum Column", 
            each List.Sum(
                [SubFolderGroups][FileCount]
        )
    )
in
    addSumColumn

