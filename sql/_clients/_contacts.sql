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
			, ',"notes": "', cleare_text(t."Notes"), '"'
			, ',"file": [',cf."FileList",']'
			, ',"_email": [{"type": "work","email": "', cleare_text(case when t."Email" like '%href%' then em."Email" else t."Email" end), '","isValid": false}]'
			, ',"_phone": [',replace(array_to_string(ARRAY[case when t."Phone"<>'' 
								then CONCAT('{"ext": ', 'null' ,
								',"tel": "',trim(replace(replace(replace(replace(cleare_text(t."Phone"),'-',''),'(',''),')',''),' ','')),'","type": "main","isValid": false}') end
							,case when t."HomePhone"<>'' 
								then CONCAT('{"ext": null,"tel": "',trim(replace(replace(replace(replace(cleare_text(t."HomePhone"),'-',''),'(',''),')',''),' ','')),'","type": "home","isValid": false}') end
							,case when t."MobilePhone"<>'' then 
								CONCAT('{"ext": null,"tel": "',trim(replace(replace(replace(replace(cleare_text(t."MobilePhone"),'-',''),'(',''),')',''),' ','')),'","type": "mobile","isValid": false}') end]
				,','),chr(9),''),']'
			, ',"_skype": "', t."Skype", '"'
			, ',"userid": "', t."UserId", '"'
			, ',"_fullname": ', '{"lastname": "', cleare_text(t."Surname"), '","firstname": "',cleare_text(t."GivenName"), '","middlename": "', cleare_text(t."MiddleName"), '"}'
			, ',"_position": "', cleare_text(t."JobTitle"), '"'
			, ',"__isDuplicate": ', 'false'
			, ',"__debug": ', 'false'
			, ',"__index": ', row_number() over()
			,',"__createdAt": "', to_char(t."CreatedOn", 'YYYY-MM-DD'),'T',to_char(t."CreatedOn", 'HH24:MI:SSZ'), '"'
			,',"__createdBy": ', '"00000000-0000-0000-0000-000000000000"'
			,',"__updatedAt": "', to_char(t."ModifiedOn", 'YYYY-MM-DD'),'T',to_char(t."ModifiedOn", 'HH24:MI:SSZ'), '"'
			,',"__updatedBy": ', '"00000000-0000-0000-0000-000000000000"'
			,',"__subscribers": ', '[]'
			, ',"__deletedAt": ', 'null'
			, ',"__directory": ', 'null'
			, ',"__externalId": "', t."Id", '"'
			,'}')::jsonb body,
	'{"values": [], "timestamp": 0, "inheritParent": true}' permissions,
	true "inherit",
	'{}' "subscriber"
from public."Contact" t
left join (select t."Id", substring(t."Email", '([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)') "Email" from public."Contact" t group by "Id") em on t."Id"= em."Id"
left join (select "ContactId", string_agg(concat('"',"Id",'"'),',') "FileList" from public."ContactFile" group by "ContactId") cf on t."Id"=cf."ContactId"
left join (select cc."ContactId",string_agg(concat('{"type": "work","email": "',cleare_text(cc."SearchNumber"),'","isValid": true}'),',') "EmailList"
					from public."ContactCommunication" cc
					left join public."CommunicationType" ct on cc."CommunicationTypeId"=ct."Id"
					where ct."Name"='Email' group by cc."ContactId") ce on t."Id"=ce."ContactId"
left join (select t."ContactId", t."ConnectionType" "ConnectionType", row_number() over (partition by "ContactId" order by t."CreatedOn" desc) as rn 
			from public."SysAdminUnit" t) au on au."ContactId" = t."Id" and au."rn"=1
where coalesce(au."ConnectionType",'1')='1'
ORDER BY t."Id"
LIMIT :limit
OFFSET :offset