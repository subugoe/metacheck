# Acceptable DOIs are filtered

    {
      "type": "list",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["tbl_df", "tbl", "data.frame"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3, 4, 5, 6, 7, 8]
        },
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["not_missing", "unique", "within_limits", "doi_org_found", "from_cr", "cr_md", "article"]
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
      "value": ["- 7 (88%) thereof fulfill the criterion `not_missing` (**1** dropped)\n- 6 (86%) thereof fulfill the criterion `unique` (**1** dropped)\n- 6 (100%) thereof fulfill the criterion `within_limits` (**0** dropped)\n- 6 (100%) thereof fulfill the criterion `doi_org_found` (**0** dropped)\n- 3 (50%) thereof fulfill the criterion `from_cr` (**3** dropped)\n- 3 (100%) thereof fulfill the criterion `cr_md` (**0** dropped)\n- 3 (100%) thereof fulfill the criterion `article` (**0** dropped)"]
    }

