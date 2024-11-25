select 
	t."Id" id,
	CONCAT('{'
			, '"__id": "', t."Id", '"'
			, ',"__name": "', replace(replace(replace(replace(replace(t."Name",chr(9),''),chr(13),''),chr(10),''),'\','\\'),'"','\"'), '"'
			, ',"email": "', t."Email", '"'
			, ',"fullname": ', '{"lastname": "', replace(replace(t."Surname",'\','\\'),'"','\"'), '","firstname": "'
				,replace(replace(t."GivenName",'\','\\'),'"','\"'), '","middlename": "', replace(replace(t."MiddleName",'\','\\'),'"','\"'), '"}'
			, ',"login": ', '""'
			, ',"osIds": ', 'null'
			, ',"owner": ', 'false'
			, ',"avatar": ', '["39e10615-a962-403e-840e-493731467b9c"]'
			, ',"__status": ', '{"order": 0, "status": ', case t."Active" when '1' then '2' else '3' end,' }'
			, ',"employee": ', '[]'
			, ',"groupIds": ', '["f25906e4-41c3-5a89-8ec2-06648dd1f614"]'
			, ',"hireDate": ', 'null'
			, ',"isPortal": ', 'true'
			, ',"timezone": ', '"Europe/Moscow"'
			, ',"profiles": ', '[{"id": "',t."ConId",'","code": "_user_profiles","namespace": "_system_catalogs"}]'
			, ',"birthDate": ', 'null'
			, ',"workPhone": ', '[]'
			, ',"integration": ', 'null'
			, ',"mobilePhone": ', '[]'
			,',"__createdAt": "', to_char(t."CreatedOn", 'YYYY-MM-DD'),'T',to_char(t."CreatedOn", 'HH24:MI:SSZ'), '"'
			, ',"__deletedAt": ', 'null'
			,',"__updatedAt": "', to_char(t."ModifiedOn", 'YYYY-MM-DD'),'T',to_char(t."ModifiedOn", 'HH24:MI:SSZ'), '"'
			,'}')::jsonb body
from (
	select t."Id", t."CreatedOn", t."ModifiedOn", t."Active", c."Id" "ConId", c."Name", c."Surname", c."GivenName", c."MiddleName", coalesce(t."Email", c."Email") "Email", 
		row_number() over (partition by case when t."Email"='' then c."Email" else t."Email" end order by t."CreatedOn" desc) as rn
	from public."SysAdminUnit" t
	inner join public."Contact" c on t."ContactId" = c."Id"
	where t."ConnectionType"=0
) t where t."rn"=1


         
