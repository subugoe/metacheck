Vor dem eigentlichen Metadatentest findet eine umfangreiche Vorabprüfung statt.
Nur wenn DOIs die folgenden Kriterien erfüllen, kann ein Metadatentest durchgeführt werden.

Gültige DOIs müssen:

1. kein Fehlwert sein (`not_missing`).
    Weitere Details in `biblids::doi()`.
2. einmalig sein (`unique`).
    Alle Dubletten werden ausgeschlossen.
    Weitere Details in `biblids::doi()`.
3. innerhalb des Bearbeitungslimits von 1000 DOIs liegen (`within_limits`).
    Dieses Limit dient dazu die Webanwendung vor Missbrauch zu schützen.
    Bitte [kontaktieren Sie uns](https://subugoe.github.io/metacheck/articles/hilfe.html) wenn Sie mehr DOIs auf einmal testen möchten.
4. bei DOI.org eine hinterlegte URL haben (`doi_org_found`).
    Weitere Details in `biblids::is_doi_found()`.
5. durch Crossref registriert sein (`from_cr`).
    Nur durch Crossref registrierte DOIs haben Metadaten auf Crossref.
    Weitere Details in `biblids::get_doi_ra()`.
6. bei Crossref Metadaten hinterlegt haben (`cr_md`).
7. auf einen Artikel verweisen (`article`).
