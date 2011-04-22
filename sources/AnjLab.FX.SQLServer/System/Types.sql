set nocount on

if not exists(
	select * from sys.types t
	inner join sys.schemas s on s.schema_id = t.schema_id
	where s.name = 'fx' and t.name = 'SimpleTable')
	
	create type fx.SimpleTable as table([Value] nvarchar(max))
	
go
