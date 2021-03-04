# Acceptable DOIs are filtered

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["not_missing", "unique", "within_limits", "doi_org_found", "resolvable", "from_cr", "from_cr_cr", "cr_md", "article"]
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
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [false, null, null, true, false, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null]
        }
      ]
    }

---

    {
      "type": "logical",
      "attributes": {},
      "value": [false, false, false, true, false, false]
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
      "value": ["- Davon erfüllen 5 (83%) das Kriterium `not_missing` (**1** ausgeschlossen)\n- Davon erfüllen 4 (80%) das Kriterium `unique` (**1** ausgeschlossen)\n- Davon erfüllen 4 (100%) das Kriterium `within_limits` (**0** ausgeschlossen)\n- Davon erfüllen 4 (100%) das Kriterium `doi_org_found` (**0** ausgeschlossen)\n- Davon erfüllen 4 (100%) das Kriterium `resolvable` (**0** ausgeschlossen)\n- Davon erfüllen 1 (25%) das Kriterium `from_cr` (**3** ausgeschlossen)\n- Davon erfüllen 1 (100%) das Kriterium `from_cr_cr` (**0** ausgeschlossen)\n- Davon erfüllen 1 (100%) das Kriterium `cr_md` (**0** ausgeschlossen)\n- Davon erfüllen 1 (100%) das Kriterium `article` (**0** ausgeschlossen)"]
    }

