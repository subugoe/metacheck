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
          "value": [1, 2, 3, 4, 5, 6, 7, 8, 9]
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
          "value": [true, false, true, true, true, true, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, false, true, true, true, true, true, true]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, false, false, false, false]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [true, null, null, true, true, null, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [false, null, null, true, false, null, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null, null, null, null]
        },
        {
          "type": "logical",
          "attributes": {},
          "value": [null, null, null, true, null, null, null, null, null]
        }
      ]
    }

---

    {
      "type": "logical",
      "attributes": {},
      "value": [false, false, false, true, false, false, true, true, false]
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
      "value": ["- 8 (89%) thereof fulfill the criterion `not_missing`: *DOIs must not be missing values.* (**1** dropped.)\n- 7 (88%) thereof fulfill the criterion `unique`: *DOIs must be unique.* (**1** dropped.)\n- 7 (100%) thereof fulfill the criterion `within_limits`: *Number of DOIs must be within the allowed limit.* (**0** dropped.)\n- 6 (86%) thereof fulfill the criterion `doi_org_found`: *DOIs must be resolveable on DOI.org.* (**1** dropped.)\n- 3 (50%) thereof fulfill the criterion `from_cr`: *DOIs must have been registered by the Crossref registration agency (RA).* (**3** dropped.)\n- 3 (100%) thereof fulfill the criterion `cr_md`: *DOIs must have metadata on Crossref.* (**0** dropped.)\n- 3 (100%) thereof fulfill the criterion `article`: *DOIs must resolve to a journal article.* (**0** dropped.)"]
    }

