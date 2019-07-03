HowTo Deduplicate Patrons with Loans/Holds/Fees on Two Cardnumbers
==================================================================

We have not encountered any unexpected issues with these
manual SQL updates, but **do be careful** when moving around
loans and fees from one account to another like this.

`Update issues with SQL <update-issues.sql>`_

.. include:: update-issues.sql
  :code: sql

Repeat for reserves and accountlines.

You may want to write a `Perl script`_ to automate
things a bit, if you have a long list of duplicates.
For logging, maybe use ``script`` or something.

.. _Perl script: transfer-issues-fees-reserves-of-borrower-dedup-list.pl
