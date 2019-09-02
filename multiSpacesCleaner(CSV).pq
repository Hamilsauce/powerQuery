//function to clean spaces, and groups of spaces of varing size
//helpful for csv imports 

let
    Source = (tbl as table, colName as text)  as table =>
        let
        //previousStep = RemoveCols2, colName = "colName",
        cleanFn = Table.TransformColumns(
            tbl,
            {
                {
                    colName,
                    each Text.Combine(
                        List.Select(
                            Text.SplitAny(_, " "),
                            each _ <> ""
                        )
                        ," "
                    ),
                    type text
                }
            }
        ) 
    in
        cleanFn
in
    Source