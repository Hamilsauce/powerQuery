(covidSource as text, isoCodeSource as text) as table =>
let
  isoCodes = (isoCodeSource as text) as table =>  //this query fetches a json file containing country names and codes, used to get country names into main table
  let
    source = Table.ExpandRecordColumn(
      Table.FromList(
        Json.Document(File.Contents(isoCodeSource)),
          Splitter.SplitByNothing(), null, null, ExtraValues.Ignore),
          "Column1",
          {
              "CODE",
              "COUNTRY"
          },
          {
              "isoCode",
              "countryName"
          }
      )
  in
      source,

  //fetch covid json, parse it/
  covidData = (covidSource as text, isoTable as table) as table =>
  let
    resultData = Json.Document(Web.Contents(covidSource))[result],
    recordsToTable =
      Table.FromList(resultData, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    //extract data from nexted json structures into new column
    extractData =
      Table.ExpandTableColumn(
        Table.AddColumn(
        recordsToTable,
        "extractData",

        //for each record, drill in on the record, then expand the list found in column named Value
        each Table.ExpandRecordColumn(
          Record.ToTable(
            recordsToTable{_}[Column1]),
            "Value",
            {"confirmed", "deaths", "recovered"}, {"confirmed", "deaths", "recovered"}
          )
        ),
        "extractData",
        {"Name", "confirmed", "deaths", "recovered"}, {"isoCode", "confirmed", "deaths", "recovered"}
      ),

    //take table from other query, and merge it to this table. keep only country names
    getCountryNames =
      Table.ExpandTableColumn(
        Table.NestedJoin(
          extractData, {"isoCode"},
          isoTable, {"isoCode"},
          
          "countries",
          JoinKind.LeftOuter
        ),
      "countries",
      {"countryName"}, {"country"}
    )
  in
    getCountryNames,

  buildTable =
    Table.Sort(
      covidData(
        "https://covidapi.info/api/v1/global/latest",
        isoCodes("C:\Users\jacob\source\covid-tracker\data\isocodes.json")
      ),
    {"country", Order.Ascending}
  )
in
  buildTable