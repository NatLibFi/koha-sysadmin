select *
from borrowers
where cardnumber in (?, ?);

select borrowernumber, count(*)
from issues
where borrowernumber in (?, ?)
group by borrowernumber;

update issues
set borrowernumber = ?
where borrowernumber = ?
;
