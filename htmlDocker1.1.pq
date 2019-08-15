//Must use on a Table with "Children" Column full of tables



// htmlDocker
(filterTbl as table, i as number) as table =>
let
    
    expandAndFilter = 
        htmlBuster(
            Table.SelectRows(
                filterTbl,
                each (
                    [Name] = "BODY"
                )
            ), 
            i
        ),
    breakOut = 
        htmlDocGuy(expandAndFilter, i)
in
    breakOut


// htmlBuster
(tbl as table, i as number) as table =>
let

    ex1 = 
        Table.ExpandTableColumn(
            tbl, 
            "Children" ,//& Text.From(i -1), 
            {
                "Kind", 
                "Name", 
                "Children",
                "Text"
            }, 
            {
                "Kind0",
                "Name0",// & Text.From(i),
                "Children0",// & Text.From(i)
                "Text0"
            }
        )
in
    ex1


// htmlDocGuy
(htmlTable as table, optional i as number) =>
let
    ex1 = 
        Table.ExpandTableColumn(
            htmlTable, 
            
            "Children" & Text.From(i - 1), 
            {
                "Kind", 
                "Name", 
                "Children",
                "Text"
            }, 
            {
                "Kind" & Text.From(if i = null then i = 0 else i),
                "Name" & Text.From(if i = null then i = 0 else i),
                "Children" & Text.From(if i = null then i = 0 else i),
                "Text" & Text.From(if i = null then i = 0 else i)
            } 
        )
in
    ex1





    // indexedHTMLTable = 
    //  Table.AddIndexColumn(
        
    //     // let
    //         // () as table =>
    //         // let
    //             // getTable = 
    //                 Web.Page(
    //                     Web.Contents(URL)
    //                 ){0}[Data],
    //         // in
    //         //     getTable
    //     // in
    //         // htmlsdf,
            
    //         // htmlsdf,
    //         "Index",
    //         1,
    //         1
    //     ),