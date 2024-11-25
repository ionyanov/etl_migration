select 
	row_number() over() id,
	t."Id" "from",
	t."DepartmentId" "to"
from public."Contact" t
left join (select t."ContactId", t."ConnectionType" "ConnectionType", row_number() over (partition by "ContactId" order by t."CreatedOn" desc) as rn 
			from public."SysAdminUnit" t) au on au."ContactId" = t."Id" and au."rn"=1
WHERE coalesce(au."ConnectionType",'1')=1 and t."DepartmentId"  is not null