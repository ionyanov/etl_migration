select 
	t."Id" id,
	CONCAT('{'
			, '"__id": "', t."Id", '"'
			, ',"hash": "', t."Id", '"'
			, ',"__name": "', t."Name",'"'
			, ',"size": ', t."Size"
			, ',"comment": ', '""'
			, ',"version": ', t."Version"
			, ',"directory": "', dir."directory",'"'
			, ',"thumbnails": ', '{"md64": "","size": 0}'
			, ',"uniqueName": ', 'false'
			, ',"originalName": "', t."Name",'"'
			, ',"__subscribers": ', 'null'
			, ',"editingSessions": ', 'null'
			, ',"group_responsible": [{"code": "', t."Name",'","name": "', t."Name",'"}]'
			, ',"__createdAt": "', to_char(t."CreatedOn", 'YYYY-MM-DD'),'T',to_char(t."CreatedOn", 'HH24:MI:SSZ'), '"'
			, ',"__createdBy": "00000000-0000-0000-0000-000000000000"'
			, ',"__updatedAt": "', to_char(t."ModifiedOn", 'YYYY-MM-DD'),'T',to_char(t."ModifiedOn", 'HH24:MI:SSZ'), '"'
			, ',"__updatedBy": "00000000-0000-0000-0000-000000000000"'
			,  ',"__deletedAt": ', 'null'
			, '}')::jsonb body,
	concat('{"values": ['
		,'{"group": {"id": "00000000-0000-0000-0000-000000000000","type": "user"},"types": ["read","create","update","delete","assign","export","import"],"inherited": true}'--system
		,',{"group": {"id": "f25906e4-41c3-5a89-8ec2-06648dd1f614","type": "group"},"types": ["create"],"inherited": true}'--external users
		,',{"group": {"id": "fda5c295-230a-5025-9797-b8b4e99e08aa","type": "group"},"types": ["read","create"],"inherited": true}'-- all users
		,'],"refItem": {'
		,'"id": "', t."ContactId",'",'
		,'"code": "', dir."code",'",'
		,'"namespace": "', dir."namespace",'"'
		,'},'
		,'"inheritParent": true}')::jsonb "permissions",
	array['00000000-0000-0000-0000-000000000000'::uuid,'fda5c295-230a-5025-9797-b8b4e99e08aa'::uuid] "read",
	true "inherit"
from public."ContactFile" t
left join (select '_clients' "namespace", '_contacts' "code", 'b2455ae7-cb43-5134-9176-cd5c0f2faf84' "directory") dir on 1=1