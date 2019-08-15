//Function -  DeUnix
let q = (date) => 
let
    Source = (#datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, date))
in
    Source
in
    q

/Function -  eventSorter
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


// fullTwlightSearch
let
    search = 
    Table.SelectRows(
        finalEvenTableBackup, 
        each(
            Text.Contains([NAME], "twilight")
            or Text.Contains([NAME], "ti3") 
            or Text.Contains([NAME], "ti4") 
            or Text.Contains([NAME], "imperium")
            or Text.Contains([NAME], "edition")
            or Text.Contains([NAME], "iii")
            or Text.Contains([NAME], "twilight imperium")
            or Text.Contains([NAME], "galactic")
        )   
    )
in
    search
    

// finalEvenTableBackup
let
    Source = Json.Document(File.Contents("C:\Users\jacob\Sea Hag Enterprises\Macrosoft - Documents\facebook-data\events\your_event_responses.json"))[event_responses],
    #"Converted to Table" = Record.ToTable(Source),
    replaceVal1 = 
        Table.ReplaceValue(
            #"Converted to Table",
            "events_",
            "",
            Replacer.ReplaceText,
            {"Name"}
        ),

    //STORED TABLES - These tables are just being stored for use at later step, is not used in step order now
    eventsDeclined =
        Table.AddColumn( 
            eventSorter(
                replaceVal1,
                "declined",
                "DECLINEDEVENTS"
            ),
            "CATEGORY",
            each "Declined"
        ),

    eventsJoined =
        Table.AddColumn( 
            eventSorter(
                replaceVal1,
                "joined",
                "JOINEDEVENTS"
            ),
            "CATEGORY",
            each "Joined"
        ),

    eventsInterested = 
        Table.AddColumn( 
            eventSorter(
                replaceVal1,
                "interested",
                "INTERESTEDEDEVENTS"
            ),
            "CATEGORY",
            each "Interested"
        ),

//combine tables, apply DeUix on dates
    CombineTablesAndFormatDates = 
        Table.TransformColumns(
            Table.Combine(
                {
                    eventsDeclined, 
                    eventsJoined, 
                    eventsInterested
                }
            ),
            {
                {
                    "EVENTSTART",
                    each DeUnix(_)
                },
                {
                    "EVENTEND",
                    each DeUnix(_)
                }
            }
        ),
    #"Added Index" = Table.AddIndexColumn(CombineTablesAndFormatDates, "Index", 1, 1),
    ChangedVales = Table.TransformColumnTypes(#"Added Index",{{"Index", Int64.Type}, {"NAME", type text}, {"EVENTSTART", type date}, {"EVENTEND", type date}, {"CATEGORY", type text}}),
    #"Lowercased Text" = Table.TransformColumns(ChangedVales,{{"NAME", Text.Lower, type text}})
in
    #"Lowercased Text"

