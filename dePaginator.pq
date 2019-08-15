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
        )
in
    append