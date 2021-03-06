if exists (select * from sysobjects where id = object_id(N'fx.truncateString') and xtype in (N'FN', N'IF', N'TF'))
	drop function fx.truncateString

set quoted_identifier on
go

/*
<documentation>
<summary>
	Returns input string with replaced sequences of several the same given symbols
	with one symbol
</summary>

<parameters>
<param name="String">Initial string</param>
<param name="Symbol">Symbol, whose sequences will be tuncated</param>
</parameters>

<returns>
	Truncated string
</returns>

<example>
	print fx.truncateString(N'       b    c d     e     ', space(1))
	--  ' b c d e '
</example>

<author>
	Alex Zakharov
	Copyright (c) AnjLab 2008, http://anjlab.com. All rights reserved.
	The code can be used for free as long as this copyright notice is not removed.
	The main idea was discussed on http://sql.ru
</author>
</documentation>
*/

create function [fx].[truncateString](@String nvarchar(max), @Symbol nchar(1))
returns nvarchar(max) as
begin

	return 
		replace(
			replace(
				replace(@String, @Symbol + @Symbol, @Symbol + nchar(1))
				, nchar(1) + @Symbol, space(0))
			, nchar(1), space(0))

end

go
