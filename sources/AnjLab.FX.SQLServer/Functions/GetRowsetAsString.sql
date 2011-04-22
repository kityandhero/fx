if exists (select * from sysobjects where id = object_id(N'fx.GetRowsetAsString') and xtype in (N'FN', N'IF', N'TF'))
drop function fx.GetRowsetAsString
go

/*
<summary>
	Returns set of column values as string with delimiters
</summary>

<remarks>
	The function uses custom data type SimpleTable
</remarks>

<author>
	Alex Zakharov
	Copyright © AnjLab 2010, http://anjlab.com. All rights reserved.
	The code can be used for free as long as this copyright notice is not removed.
	
	This code is based on code by loki1984 published on site sql.ru
	http://www.sql.ru/faq/faq_topic.aspx?fid=130
<author>

<param name="Date">Date to be checked</param>

<returns>true / false</returns>

<example>
	declare @Table fx.simpletable
	
	insert into @Table 
	select RecordID from fx.GetEmptyRowset(5) order by RecordID
	
	print fx.GetRowsetAsString(@Table, N',')
	> 1, 2, 3, 4, 5
</example>
*/

create function fx.GetRowsetAsString(@Table fx.SimpleTable readonly, @Delimeter nchar(1)) 
returns nvarchar(max) as
begin
	
	declare @Result nvarchar(max)
	set @Result = (
		select ltrim(rtrim([Value])) + @Delimeter as 'data()' 
		from (select [Value] from @Table) as A
		for xml path(''))
		
	return substring(@Result, 1, len(@Result) - 1)

end

go
