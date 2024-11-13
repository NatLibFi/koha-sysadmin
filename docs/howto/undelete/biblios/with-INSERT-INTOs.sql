INSERT INTO biblio
SELECT * FROM deletedbiblio
WHERE biblionumber IN (0,0,0);

INSERT INTO biblioitems
SELECT * FROM deletedbiblioitems
WHERE biblionumber IN (0,0,0);

INSERT INTO biblio_metadata (
        biblionumber,
        format,
        `schema`,
        metadata,
        timestamp,
        record_source_id
) SELECT biblionumber, format, `schema`,
        metadata, timestamp, record_source_id
FROM deletedbiblio_metadata
WHERE biblionumber IN (0,0,0);

-- DELETE FROM deletedbiblio_metadata WHERE biblionumber IN (0,0,0);
-- DELETE FROM deletedbiblioitems WHERE biblionumber IN (0,0,0);
-- DELETE FROM deletedbiblio WHERE biblionumber IN (0,0,0);
