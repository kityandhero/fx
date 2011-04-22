set nocount on

declare @SQL nvarchar(100)

if not exists(select * from sys.schemas where name = 'fx')
begin
	set @SQL = 'create schema fx'
	exec sp_executesql @SQL
end

go
