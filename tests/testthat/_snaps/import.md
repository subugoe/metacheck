# Acceptable DOIs are filtered

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["not_missing", "unique", "within_limits", "doi_org_found", "resolvable", "from_cr"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3, 4, 5, 6, 7, 8]
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
          "value": [true, false, true, true, true, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, false, true, true, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, false, false, false]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [false, null, null, false, false, null, null, null]
        }
      ]
    }

---

    {
      "type": "logical",
      "attributes": {},
      "value": [false, false, false, false, false, false, true, true]
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
      "value": ["- Davon sind **88%** `not_missing` (12% ausgeschlossen)\n- Davon sind **86%** `unique` (14% ausgeschlossen)\n- Davon sind **50%** `within_limits` (50% ausgeschlossen)\n- Davon sind **100%** `doi_org_found` (0% ausgeschlossen)\n- Davon sind **100%** `resolvable` (0% ausgeschlossen)\n- Davon sind **0%** `from_cr` (100% ausgeschlossen)"]
    }

