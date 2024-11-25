select 
	row_number() over() id,
	t."Id" "from",
	t."ParentId" "to"
from public."Account" t
where t."ParentId" is not null