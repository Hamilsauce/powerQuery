let
    Source = Web.Page(Web.Contents("https://www.gimpusers.com/gimp/hotkeys")),
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Data"}),
    Data1 = #"Removed Other Columns"{1}[Data],
    Children = Data1{0}[Children],
    #"Expanded Children" = Table.ExpandTableColumn(Children, "Children", {"Kind", "Name", "Children", "Text"}, {"Kind.1", "Name.1", "Children.1", "Text.1"}),
    #"Expanded Children.1" = Table.ExpandTableColumn(#"Expanded Children", "Children.1", {"Kind", "Name", "Children", "Text"}, {"Kind.2", "Name.2", "Children", "Text.2"}),
    #"Expanded Children1" = Table.ExpandTableColumn(#"Expanded Children.1", "Children", {"Kind", "Name", "Children", "Text"}, {"Kind.3", "Name.3", "Children.1", "Text.3"}),
    #"Expanded Children.2" = Table.ExpandTableColumn(#"Expanded Children1", "Children.1", {"Kind", "Name", "Children", "Text"}, {"Kind.4", "Name.4", "Children", "Text.4"}),
    #"Expanded Children2" = Table.ExpandTableColumn(#"Expanded Children.2", "Children", {"Kind", "Name", "Children", "Text"}, {"Kind.5", "Name.5", "Children.1", "Text.5"}),
    #"Expanded Children.3" = Table.ExpandTableColumn(#"Expanded Children2", "Children.1", {"Kind", "Name", "Children", "Text"}, {"Kind.6", "Name.6", "Children", "Text.6"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Children.3", each ([Name.6] = "TR" or [Name.6] = "UL")),
    #"Removed Other Columns1" = Table.SelectColumns(#"Filtered Rows",{"Children"}),
    #"Expanded Children3" = Table.ExpandTableColumn(#"Removed Other Columns1", "Children", {"Kind", "Name", "Children", "Text"}, {"Kind", "Name", "Children.1", "Text"}),
    #"Expanded Children.4" = Table.ExpandTableColumn(#"Expanded Children3", "Children.1", {"Kind", "Name", "Children", "Text"}, {"Kind.1", "Name.1", "Children", "Text.1"}),
    #"Expanded Children4" = Table.ExpandTableColumn(#"Expanded Children.4", "Children", {"Kind", "Name", "Children", "Text"}, {"Kind.2", "Name.2", "Children.1", "Text.2"}),
    #"Expanded Children.5" = Table.ExpandTableColumn(#"Expanded Children4", "Children.1s", {"Kind", "Name", "Children", "Text"}, {"Kind.3", "Name.3", "Children", "Text.3"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Children.5",{{"Text.1", "Shortcuts"}}),
    #"Removed Other Columns2" = Table.SelectColumns(#"Renamed Columns",{"Shortcuts"}),
   
   removeTop1= Table.Skip(#"Removed Other Columns2",1),
    listContains = 
    Table.AddColumn(
            Table.AddIndexColumn(
                removeTop1, 
                "Index", 
                1, 1
            ),
            "Category",
            each (
                if List.ContainsAny(
                    dimCategories, 
                    {[Shortcuts]}
                ) = true or [Index] = 192 
                then 
                    [Shortcuts] 
                else 
                    null
        )
    ),
    #"Filled Down" = 
        Table.FillDown(listContains,{"Category"}),
    filterCatNames = Table.SelectRows(
        #"Filled Down", 
        each not (
            List.ContainsAny(
                dimCategories, 
                {[Shortcuts]}
            ) = true
            or [Index] = 192
        )
    ),
    #"Filtered Rows1" = Table.SelectRows(filterCatNames, each ([Shortcuts] <> null)),
    #"Kept First Rows" = Table.Skip(#"Filtered Rows1",1),
    Shortcuts1 = #"Kept First Rows"[Shortcuts],
    removeKeys = List.Alternate(Shortcuts1,1,1,1),
    removeNames = 
       List.Skip(
            List.Alternate(
                Shortcuts1, 
                1, 1, 2
            ), 1
        ),
        
    toTable =
    (list as list) as table =>
        let
            listToTable = 
                Table.AddIndexColumn(
                    Table.FromList(
                        list, 
                        Splitter.SplitByNothing(),
                        null, null, 
                        ExtraValues.Error
                    ),
                    "Index", 1, 1
                )
        in
            listToTable,

    keysTable = toTable(removeKeys),
    #"Renamed Columns1" = 
        Table.RenameColumns(keysTable,{{"Column1", "Action"}}),
    nameTable = toTable(removeNames),
    #"Renamed Columns2" = 
        Table.RenameColumns(nameTable,{{"Column1", "Shortcut"}}),

    mergeTables = Table.NestedJoin(#"Renamed Columns2", {"Index"}, #"Renamed Columns1", {"Index"}, "Merge", JoinKind.Inner),
    #"Expanded Merge" = Table.ExpandTableColumn(mergeTables, "Merge", {"Action"}, {"Action"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Expanded Merge",{{"Shortcut", "Action1"}, {"Action", "Shortcuts"}}),
    #"Merged Queries" = Table.NestedJoin(#"Renamed Columns3", {"Shortcuts"},#"Filled Down", {"Shortcuts"}, "Merge", JoinKind.Inner),
    #"Expanded Merge1" = Table.ExpandTableColumn(#"Merged Queries", "Merge", {"Category"}, {"Category"}),
    #"Renamed Columns4" = Table.RenameColumns(#"Expanded Merge1",{{"Shortcuts", "Action"}, {"Action1", "Shortcut"}}),
    #"Reordered Columns" = 
        Table.ReorderColumns(#"Renamed Columns4",{"Index", "Action", "Shortcut", "Category"}),
    #"Inserted Literal" = 
        Table.AddColumn(#"Reordered Columns", "Application", each "Gimp", type text)
 
in
    #"Inserted Literal"
