# Acceptable DOIs are filtered

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["not_missing", "unique", "within_limits", "doi_org_found", "from_cr", "cr_md", "article"]
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
          "value": [false, null, null, true, false, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null, null, null]
        }
      ]
    }

---

    {
      "type": "logical",
      "attributes": {},
      "value": [false, false, false, true, false, false, true, true]
    }

# DOI acceptability is reported

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["glue", "character"]
        }
      },
      "value": ["- Davon erfüllen 7 (88%) das Kriterium `not_missing` (**1** ausgeschlossen)\n- Davon erfüllen 6 (86%) das Kriterium `unique` (**1** ausgeschlossen)\n- Davon erfüllen 6 (100%) das Kriterium `within_limits` (**0** ausgeschlossen)\n- Davon erfüllen 6 (100%) das Kriterium `doi_org_found` (**0** ausgeschlossen)\n- Davon erfüllen 3 (50%) das Kriterium `from_cr` (**3** ausgeschlossen)\n- Davon erfüllen 3 (100%) das Kriterium `cr_md` (**0** ausgeschlossen)\n- Davon erfüllen 3 (100%) das Kriterium `article` (**0** ausgeschlossen)"]
    }

