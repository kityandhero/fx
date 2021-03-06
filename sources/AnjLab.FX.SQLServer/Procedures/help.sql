if exists (select * from sysobjects where id = object_id(N'fx.help') and xtype in (N'P'))
	drop procedure fx.help

set quoted_identifier on
go

/*
<documentation>

<summary>
	Shows text description for fx programmable objects
</summary>

<remarks>
	FX programable objects documentation is stored directly in onject definition (syscomments table).
	Documentation is comment block with correct XML inside, in can be placed everywhere in object body.
	XML must have root tag 'documentation', inside you can use any XML structure.
	
	While printing documentation this procedure prints element name (in upper case) and, on next row,
	element value. This is main constuction we call 'section'.
	
	Second supported construction is enumeration (look at parameters section of this documentation).
	Each list element should have 'name' attribute. The procedure prints name value and element value on 
	next row.
</remarks>

<parameters>
<param name="Object">Name of fx programmable objects (without schema)</param>
</parameters>

<example>
	exec fx.help 'getXMLTable'
</example>

<author>
	Alex Zakharov
	Copyright © AnjLab 2011, http://anjlab.com. All rights reserved.
	The code can be used for free as long as this copyright notice is not removed.
</author>

</documentation>
*/

create procedure fx.help(@Object sysname = 'Help') as
begin

	set nocount on

	declare @Documentation xml
	declare @Element nvarchar(100), @Name nvarchar(100), @Value nvarchar(max)

	if not exists(
		select * from sysobjects 
		where id = object_id(N'fx.' + @Object)and xtype in ('P', 'V', 'FN', 'TF', 'TR'))
	begin
		raiserror('Specified object is not exist. ', 16, 1)	
		return -1
	end

	-- extract documentation XML from object body stored in syscommnts
	begin try

		;with data([Text]) as (
			select [Text] = (
				select [text] 
				from syscomments 
				where id = object_id('fx.' + @Object)
				for xml path(''), type).value('.', 'varchar(max)'))

			select @Documentation = 
				substring([Text], 
					charindex('<documentation>', [Text], 0) , 
					charindex('</documentation>', [Text], 0) - charindex('<documentation>', [Text], 0) + 16) 
			from data
	
	end try
	begin catch
		raiserror('Object''s documentation is absent or not well-formed.', 16, 1)	
		print 'Check exec fx.Help for more information'
		return -1
	end catch
	
	-- Transform XML data to relational table
	declare Data cursor for 
	select
		Element = NodeName,
		-- extract Name attribute value for node
		[Name]  = Query.value('*[1]/@name', 'nvarchar(100)'),
		[Value]
	from fx.getXMLElements(@Documentation) a
	where ParentNodeId is not null

	open Data
	fetch next from Data into @Element, @Name, @Value

	-- Print each record from the table
	while @@fetch_status = 0
	begin
		
		-- section
		if @Name is null print upper(@Element) + nchar(10) + isnull(@Value, space(0))
		-- subsection
		else print N'	' + @Name + nchar(10) + N'	' + isnull(@Value, space(0)) + nchar(10)

		fetch next from Data into @Element, @Name, @Value
	end

	close Data
	deallocate Data

end

go
