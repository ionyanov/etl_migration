select 
	row_number() over() id,
	max(t."Id") "from",
	t."AccountId" "to"
from public."Contact" t
left join public."SysAdminUnit" au on au."ContactId" = t."Id"
where coalesce(au."ConnectionType",'1')=1 and t."AccountId"  is not NULL
GROUP BY t."AccountId"