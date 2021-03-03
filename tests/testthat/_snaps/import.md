# Acceptable DOIs are filtered

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["not_missing", "unique", "within_limits"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3, 4, 5, 6]
        },
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["tbl_df", "tbl", "data.frame"]
        }
      },
      "value": [
        {
          "type": "logical",
          "attributes": {},
          "value": [true, false, true, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, false, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, false]
        }
      ]
    }

---

    {
      "type": "logical",
      "attributes": {},
      "value": [true, false, false, true, true, true]
    }

# DOI eligiblity is reported

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["glue", "character"]
        }
      },
      "value": ["- Davon sind **83%** `not_missing` (17% ausgeschlossen)\n- Davon sind **80%** `unique` (20% ausgeschlossen)\n- Davon sind **75%** `within_limits` (25% ausgeschlossen)"]
    }

