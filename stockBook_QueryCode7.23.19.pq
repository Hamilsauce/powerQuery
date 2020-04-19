
// ARQL
let
    Source = Web.Page(Web.Contents("https://www.nasdaq.com/symbol/arql/historical")),
    Data0 = Source{0}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Data0,{{"Date", type text}, {"Open", type number}, {"High ""High"" is the highest sales price the stock has achieved during the regular trading hours, the intra-day high.", type number}, {"Low ""Low"" is the lowest sales price the stock has fallen to during the regular trading hours, the intra-day low.", type number}, {"Close / Last ""Close"" is the period at the end of the trading session. Sometimes used to refer to closing price.", type number}, {"Volume ""Volume"" The closing daily official volumes represented graphically for each trading day.", Int64.Type}}),
    #"Rounded Off" = Table.TransformColumns(#"Changed Type",{{"Open", each Number.Round(_, 2), type number}, {"High ""High"" is the highest sales price the stock has achieved during the regular trading hours, the intra-day high.", each Number.Round(_, 2), type number}, {"Low ""Low"" is the lowest sales price the stock has fallen to during the regular trading hours, the intra-day low.", each Number.Round(_, 2), type number}, {"Close / Last ""Close"" is the period at the end of the trading session. Sometimes used to refer to closing price.", each Number.Round(_, 2), type number}}),
    headerList = Table.ColumnNames(#"Rounded Off"),
    newHeaders =
        let
            #"Converted to Table" = Table.FromList(headerList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Extracted Text Before Delimiter" = Table.TransformColumns(#"Converted to Table", {{"Column1", each Text.BeforeDelimiter(_, " """), type text}}),
            #"Extracted Text Before Delimiter1" = Table.TransformColumns(#"Extracted Text Before Delimiter", {{"Column1", each Text.BeforeDelimiter(_, " /"), type text}}),
            Column1 = #"Extracted Text Before Delimiter1"[Column1]
        in
            Column1,
    NamePair =
        List.Zip({headerList, newHeaders}),
    rename = Table.RenameColumns(
        #"Rounded Off",
        NamePair
    )
in
    rename

// newFinalARQL
//combine data from multiple paginated webpages within only 1 query using function to create each page-query, then combining.
//can be automated with VBA 



let
    dePaginator =
    (pageNumber as text) as table =>
    let
        filterForTable = 
            Table.SelectRows(
                Web.Page(Web.Contents("https://stockinvest.us/ARQL-stock-price?page=" & pageNumber) //concat pagenumber to end of URL
                ),
                each (
                    [Source] = "Table"
                )
            ),
            //can add in whatever transformations this point on
            Data = 
                Table.PromoteHeaders(
                    filterForTable{0}[Data],
                    [PromotedAllScalars=true]
                ),
            FormatCols = 
                Table.TransformColumnTypes(
                    Data,
                    {
                        {"Date", type date}, 
                        {"Open", Currency.Type}, 
                        {"High", Currency.Type}, 
                        {"Low", Currency.Type}, 
                        {"Close", Currency.Type}, 
                        {"Volume", Int64.Type}
                    }
                )
        in
            FormatCols,
    //repeat function
    page1 = dePaginator("1"),
    page2 = dePaginator("2"), 
    page3 = dePaginator("3"),
    page4 = dePaginator("4"),
    page5 = dePaginator("5"),
    page6 = dePaginator("6"),
    page7 = dePaginator("7"),
    page8 = dePaginator("8"),
    page9 = dePaginator("9"),

    append = 
        Table.Combine(
            {
                page1,
                page2, 
                page3,
                page4,
                page5,
                page6,
                page7,
                page8,
                page9
            }
        ),
    #"Added Index" = Table.AddIndexColumn(append, "Index", 1, 1)
in
    #"Added Index"



// stocksHistoricalCVRS
let
    dePaginator =
    (pageNumber as text) as table =>
    let
        filterForTable = 
            Table.SelectRows(
                Web.Page(Web.Contents("https://stockinvest.us/CVRS-stock-price?page=" & pageNumber) //concat pagenumber to end of URL
                ),
                each (
                    [Source] = "Table"
                )
            ),
            //can add in whatever transformations this point on
            Data = 
                Table.PromoteHeaders(
                    filterForTable{0}[Data],
                    [PromotedAllScalars=true]
                ),
            FormatCols = 
                Table.TransformColumnTypes(
                    Data,
                    {
                        {"Date", type date}, 
                        {"Open", Currency.Type}, 
                        {"High", Currency.Type}, 
                        {"Low", Currency.Type}, 
                        {"Close", Currency.Type}, 
                        {"Volume", Int64.Type}
                    }
                )
        in
            FormatCols,
    //repeat function
    page1 = dePaginator("1"),
    page2 = dePaginator("2"), 
    page3 = dePaginator("3"),
    page4 = dePaginator("4"),
    page5 = dePaginator("5"),
    page6 = dePaginator("6"),
    page7 = dePaginator("7"),
    page8 = dePaginator("8"),
    page9 = dePaginator("9"),

    append = 
        Table.Combine(
            {
                page1,
                page2, 
                page3,
                page4,
                page5,
                page6,
                page7,
                page8,
                page9
            }
        ),
    #"Added Index" = Table.AddIndexColumn(append, "Index", 1, 1)
in
    #"Added Index"

// stocksHistoricalHSGX
let
    dePaginator =
    (pageNumber as text) as table =>
    let
        filterForTable = 
            Table.SelectRows(
                Web.Page(Web.Contents("https://stockinvest.us/HSGX-stock-price?page=" & pageNumber) //concat pagenumber to end of URL
                ),
                each (
                    [Source] = "Table"
                )
            ),
            //can add in whatever transformations this point on
            Data = 
                Table.PromoteHeaders(
                    filterForTable{0}[Data],
                    [PromotedAllScalars=true]
                ),
            FormatCols = 
                Table.TransformColumnTypes(
                    Data,
                    {
                        {"Date", type date}, 
                        {"Open", Currency.Type}, 
                        {"High", Currency.Type}, 
                        {"Low", Currency.Type}, 
                        {"Close", Currency.Type}, 
                        {"Volume", Int64.Type}
                    }
                )
        in
            FormatCols,
    //repeat function
    page1 = dePaginator("1"),
    page2 = dePaginator("2"), 
    page3 = dePaginator("3"),
    page4 = dePaginator("4"),
    page5 = dePaginator("5"),
    page6 = dePaginator("6"),
    page7 = dePaginator("7"),
    page8 = dePaginator("8"),
    page9 = dePaginator("9"),

    append = 
        Table.Combine(
            {
                page1,
                page2, 
                page3,
                page4,
                page5,
                page6,
                page7,
                page8,
                page9
            }
        ),
    #"Added Index" = Table.AddIndexColumn(append, "Index", 1, 1)
in
    #"Added Index"