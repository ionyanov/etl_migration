select 
	row_number() over() id,
	t."Id" "from",
	t."TypeId" "to"
from public."Account" t
where t."TypeId" is not null