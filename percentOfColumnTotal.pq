percentOfColumnTotal =
    Table.TransformColumnTypes(
        Table.AddColumn(  // creating new column for %s using a previous existing table, name the column
            #"Previous Table",
            "NameOfNew%Column",
            each Number.From(   //  for each row in table, take the value in the current row of original column, divide it by sum of all values in original column
                [OriginalColumnName] / List.Sum(#"Previous Table"[OriginalColumnName])
            )
        ),
        {
            "NameOfNew%Column", Percentage.Type //  convert the data type of our new value from number into %
        }
    )


