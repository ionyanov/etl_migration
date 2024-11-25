create or replace function cleare_text(p_words text)
  returns text
as
$$
  select trim(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(p_words,'|','/')
							,chr(13),'<br />')
						,chr(10),'')
					,chr(9),'')
				,'\','\\')
			,'"','\"')
		);
$$
language sql;
select 
	t."Id" id,
	CONCAT('{'
			, '"__id": "', t."Id", '"'
			, ',"__name": "', cleare_text(t."Name"), '"'
			, ',"_bik": ', 'null'
			, ',"_inn": "', cleare_text(t."INN"), '"'
			, ',"_kpp": "', cleare_text(t."KPP"), '"'
			, ',"code": "', t."Code", '"'
			, ',"file": [', af."FileList", ']'
			, ',"okpo": "', cleare_text(t."OKPO"), '"'
			, ',"_bank": ', 'null'
			, ',"_ogrn": "', cleare_text(t."OGRN"), '"'
			, ',"notes": "', cleare_text(t."Notes"), '"'
			, ',"_email": [', ae."EmailPrimary", ']'
			, ',"_phone": ', case when t."AdditionalPhone"='' then '[]' else CONCAT('[{"ext": null,"tel": "', cleare_text(t."AdditionalPhone"), '","type": "work","isValid": false}]') end
			, ',"phone_main": ', case when t."Phone"='' then '[]' else CONCAT('[{"ext": null,"tel": "', cleare_text(t."Phone"), '","type": "main","isValid": false}]') end
			, ',"_address": "', cleare_text(t."Address"), '"'
			, ',"_website": "', cleare_text(replace(t."Web",'~','`')), '"'
			, ',"_legalName": ', 'null'
			, ',"__isDuplicate": ', 'false'
			, ',"_legalAddress": ', 'null'
			, ',"_superiorName": ', 'null'
			, ',"name_alternative": "', cleare_text(t."AlternativeName"), '"'
			, ',"_operatingAccount": ', 'null'
			, ',"_correspondentAccount": ', 'null'
			, ',"_correspondenceAddress": ', 'null'
			, ',"__externalProcessMeta": null'
			, ',"__debug": ', 'false'
			, ',"__index": ', row_number() over()
			, ',"__directory": ', 'null'
			, ',"__externalId": "', t."Id", '"'
			, ',"__subscribers": ', '[]'
			,',"__createdAt": "', to_char(t."CreatedOn", 'YYYY-MM-DD'),'T',to_char(t."CreatedOn", 'HH24:MI:SSZ'), '"'
			,',"__createdBy": ', '"00000000-0000-0000-0000-000000000000"'
			, ',"__deletedAt": ', 'null'
			,',"__updatedAt": "', to_char(t."ModifiedOn", 'YYYY-MM-DD'),'T',to_char(t."ModifiedOn", 'HH24:MI:SSZ'), '"'
			,',"__updatedBy": ', '"00000000-0000-0000-0000-000000000000"'
			,'}')::jsonb "body",
			'{"values": [], "timestamp": 0, "inheritParent": true}' "permissions",
			true "inherit"
from public."Account" t
left join (select "AccountId", string_agg(concat('"',"Id",'"'),',') "FileList" from public."AccountFile" group by "AccountId") af on t."Id"=af."AccountId"
left join (select ac."AccountId", string_agg(concat('{"type": "work","email": "',ac."SearchNumber",'","isValid": true}'),',') "EmailList",
				max(case when ac."Primary" then concat('{"type": "work","email": "',ac."SearchNumber",'","isValid": true}') else null end) "EmailPrimary"
			from public."AccountCommunication" ac
			left join public."CommunicationType" ct on ac."CommunicationTypeId"=ct."Id"
			where ct."Name"='Email' group by ac."AccountId") ae on t."Id"=ae."AccountId"
left join (select ac."AccountId", string_agg(concat('{"ext": null, "type": "', case ct."Name" when 'Primary phone' then 'main' else 'work' end
								,'", "tel": "',ac."SearchNumber",'","isValid": true}'),',') "PhoneList"
			from public."AccountCommunication" ac
			left join public."CommunicationType" ct on ac."CommunicationTypeId"=ct."Id"
			where ct."Name" like '%phone%' group by ac."AccountId") ap on t."Id"=ap."AccountId"
ORDER BY t."Id"
LIMIT :limit
OFFSET :offset