HowTo Undelete Biblios
======================

We didn’t find documentation for this, but undeleting Koha biblios
seems to have been working with SQL queries like this.

This would be for a Koha installation (almost) matching version 24.05.

Undeleted biblios still need to be reindexed afterwards, of course.

`Undelete Biblios with Insert Into SQL queries <with-INSERT-INTOs.sql>`_

.. include:: with-INSERT-INTOs.sql
  :code: sql

Yes, we noted that the (deleted)biblio_metadata tables had
autoincremented, colliding id fields...

Also, these tables had a schema field, whose name is a
reserved word and thus needed to be quoted with backticks...

...

One more thing to note is that if the biblios had had holdings records,
those would probably have been lost when their biblios were deleted.
(If only the holdings records were deleted, they might still
be found in the holdings and holdings_metadata tables
as long as their biblios were not deleted.)

(Holdings records are not supported in the main branch of
Community Koha version 24.05, but they are used in our setup.)
