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
			,',"group_responsible": [{"code": "', t."Name",'","name": "', t."Name",'"}]'
			,',"__createdAt": "', to_char(t."CreatedOn", 'YYYY-MM-DD'),'T',to_char(t."CreatedOn", 'HH24:MI:SSZ'), '"'
			,',"__createdBy": "00000000-0000-0000-0000-000000000000"'
			,',"__updatedAt": "', to_char(t."ModifiedOn", 'YYYY-MM-DD'),'T',to_char(t."ModifiedOn", 'HH24:MI:SSZ'), '"'
			,',"__updatedBy": "00000000-0000-0000-0000-000000000000"'
			, ',"__deletedAt": ', 'null'
			,'}')::jsonb body,
	concat('{"values": ['
		,'{"group": {"id": "00000000-0000-0000-0000-000000000000","type": "user"},"types": ["read","create","update","delete","assign","export","import"],"inherited": true}'--system
		,',{"group": {"id": "f25906e4-41c3-5a89-8ec2-06648dd1f614","type": "group"},"types": ["create"],"inherited": true}'--external users
		,',{"group": {"id": "fda5c295-230a-5025-9797-b8b4e99e08aa","type": "group"},"types": ["read","create"],"inherited": true}'-- all users
		,'],"refItem": {'
		,'"id": "', t."KnowledgeBaseId",'",'
		,'"code": "', dir."code",'",'
		,'"namespace": "', dir."namespace",'"'
		,'},'
		--,'"timestamp": 1729975176,'
		,'"inheritParent": true}')::jsonb "permissions",
	array['00000000-0000-0000-0000-000000000000'::uuid,'fda5c295-230a-5025-9797-b8b4e99e08aa'::uuid] "read",
	true "inherit"
from public."KnowledgeBaseFile" t
left join (select 'service_desk' "namespace", 'decisions' "code", '6ced96cf-5eb3-5c4c-9a93-a4d679d3bbd0' "directory") dir on 1=1
where "Id" in ('4a8f3a68-c87a-4e04-8c9b-7bc10510c02d','2c9d6b31-89b5-46cc-83c8-ef1a5b5b55ed','96c62835-05d7-4659-893f-4ef6c2b53485','949f7a67-25a4-4d54-9249-6035c74128bf',
'd1dc0a0e-aa2b-46be-b0f0-e4b8325d54b2','bd25d155-2c98-4163-a07b-6b7a7c9c5137','63b4f666-87fd-485f-83eb-0b825b699c12','18e88d26-e712-4781-943b-f6fb7d7ca462',
'7a11002c-b326-4c9e-bc1b-839eef9af1f3','b441258f-8d93-46ad-9652-475834d09722','605384e3-6949-4965-b55a-ba3bab8f5046','db9bb1f9-6101-4ee8-8cd3-3d7f1a56f036',
'536fa0c6-ecb5-47cd-b552-8177b109b497','8fc1eeaf-fd67-494f-bee7-22fefab699a0','17b9d552-e55b-455a-b799-9ae42476679f','c92c7cb1-ae2c-4975-bcb0-3d37aca06fb3',
'd09957af-1153-44bf-b778-05ba02950559','658b5f33-7172-464b-9742-9561695beb81','a9b8b573-972a-4b41-9418-d9693af16e88','d0023b81-f138-47a7-9014-69cf794fdeaf',
'9257fad6-492a-4d7b-93c9-10e8e9eaaa30','c4176ecc-2a97-41a7-8dd3-65e5c7c52d0a','cff5523f-3574-4758-9b6c-1957c94494e2','a354e4d4-ba3f-4859-979d-dd3414695c63',
'4d1aa20f-b67e-44e4-8be2-f513bfeb693e','ae858551-752d-4ade-8b4f-6d9f6befee43','e9b08af7-03cb-4669-81b8-d65144533889','dc3a309b-3c8b-4c50-a654-4010d195033a',
'f7e80cd7-57a0-43f1-b38e-35fb996e9ca5','2d3517dd-ecaf-4bec-855c-ee912d79ab78','ef84b1b6-9efd-4196-b924-1cd3285a90c0','286e9f89-fa04-4881-afa6-80126ccdc45f',
'06a4e981-b05a-457d-beac-813247297b27','e817bbb4-2471-44d8-b62e-29901bbfa9df','fc341c32-8bec-44dd-afe3-0ef6ce3cc377','f7839980-0fad-41d9-af2a-866ab1d92237',
'92d6b6e4-2c4a-4ee7-a1c1-2f4538bd7c8a','58b500d7-334e-40fb-bffa-56c7d31321b8','125e3c4d-67d9-4e4d-9c09-a2396819ecb6','66d1207b-062a-4836-a8be-b548ee0d6130',
'1720b4b1-368b-4023-a7d1-4f82001e318b','7b397c60-886e-464e-9be5-6b4d203b769c','db1a78de-7a62-4f9a-b875-345d802fa0e2','18ecde36-8c41-4865-890c-96ad9562c629',
'54ed7219-83d8-4180-a533-8924d13ba4f7','f3251856-0d5c-4f29-8bba-e11d396ffaf7','78effa13-189e-47d4-9e66-c99ae417d12b','c4f428f7-5b5f-4fb8-a8e5-217b7f18cd50',
'58319187-bd19-4f04-9cc9-5827789793f1','dc1bc5db-86a5-4126-99ca-4a9285a8171c','4a4550dd-f0a0-4c30-b66e-797490a62b25','c80e03e0-1714-4e57-bb6f-9a5db5a83fa7',
'98ca273b-25dd-4794-9846-96920ad0f2d1','504b42a2-0673-47da-a373-3f6911a1ce0a','6e4a28ae-e109-44ad-8d76-698bea58a731','f95b97ec-7a05-457d-b468-d28aa0ee9662',
'67b36117-44af-4f9b-81e4-e5473d3b8489','e3190e9f-7486-488b-91a5-06f38ecee682','4722b317-d30d-4dda-8392-5af707da1988','8f080617-1090-43ea-979d-f016b4289406',
'7706e188-555d-48d2-ac48-de0443b03a19','ec1a9321-6209-4a9d-b0e1-169014ab39e0','389e0f10-2f86-42d4-a1ae-b054cbeb63b1')
