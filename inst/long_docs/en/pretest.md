Before even checking what metadata has been deposited for a DOI, a DOI has to pass a number of criteria to be eligible for metacheck.

Eligible DOIs must be:

1. non-missing (`not_na`).
    For details, see `biblids::doi()`.
2. non-duplicated (`unique`).
    Every 2nd and later repetition of a DOI fails this test.
    For details, see `biblids::doi()`.
3. within the limit of 1000 DOIs (`within_limits`).
    This limit is set for the web application to avoid misuse.
    Please contact [support](https://subugoe.github.io/metacheck/articles/help.html) if you need to test more DOIs.
4. resolvable on DOI.org (`doi_org_found`).
    For details, see `biblids::is_doi_found()`.
5. have been deposited by the Crossref registration agency (as per doi.org) (`from_cr`).
    DOIs registered by an agency other than Crossref will not have metadata on Crossref.
6. have metadata deposited on Crossref (`cr_md`).
7. have to resolve to a journal article (`article`).
