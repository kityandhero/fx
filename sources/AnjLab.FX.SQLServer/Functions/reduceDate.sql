if exists (select * from sysobjects where id = object_id(N'fx.reduceDate') and xtype in (N'FN', N'IF', N'TF'))
	drop function fx.reduceDate

set quoted_identifier on
go

/*
<documentation>
<summary>
	For given datetime returns start or end of current hour, day, month, etc,
	in other words, truncates datetime. There Start means first millisecond of
	given period, End - last millisecond.
</summary>

<parameters>
<param name="Grouping">Period length. Possible values:
	1 - second
	2 - minute
	3 - hour
	4 - day
	5 - month
	6 - year
</param>
<param name="Date">Datetime to be changed</param>
<param name="Mode">Points what should be returned - period start or period end</param>
</parameters>

<returns>
	Datetime
</returns>

<example>
	-- The query below returns all possible 12 variants for current date and time.
	-- NOTE, it also includes @Grouping = 7 which out of bound. In this case the function 
	-- just returns input date.
	
	select 
		[@Grouping] = RecordID,
		[@Date] = getDate(),
		[@Mode = 0] = fx.reduceDate(RecordID, getDate(), 0),
		[@Mode = 1] = fx.reduceDate(RecordID, getDate(), 1)
	from fx.getEmptyTable(7)
</example>

<author>
	Alex Zakharov
	Copyright © AnjLab 2010, http://anjlab.com. All rights reserved.
	The code can be used for free as long as this copyright notice is not removed.
</author>
</documentation>
*/

create function [fx].[reduceDate](@Grouping int, @Date datetime, @Mode bit) 
returns datetime as
begin

	return (
		select
			case when @Mode = 1 then dateadd(ms, -2, 
				case @Grouping
					when 1 then dateadd(ss, 1, [Date])
					when 2 then dateadd(mi, 1, [Date])
					when 3 then dateadd(hh, 1, [Date])
					when 4 then dateadd(dd, 1, [Date])
					when 5 then dateadd(mm, 1, [Date])
					when 6 then dateadd(yy, 1, [Date])
					else [Date]
					end)
			else [Date] end
		from
			(select [Date] = case when @Grouping in(6)                then dateadd(mm, -datepart(mm, [Date]) + 1, [Date]) else [Date] end from 
			(select [Date] = case when @Grouping in(5, 6)             then dateadd(dd, -datepart(dd, [Date]) + 1, [Date]) else [Date] end from 
			(select [Date] = case when @Grouping in(4, 5, 6)          then dateadd(hh, -datepart(hh, [Date]), [Date])     else [Date] end from 
			(select [Date] = case when @Grouping in(3, 4, 5, 6)       then dateadd(mi, -datepart(mi, [Date]), [Date])     else [Date] end from 
			(select [Date] = case when @Grouping in(2, 3, 4, 5, 6)    then dateadd(ss, -datepart(ss, [Date]), [Date])     else [Date] end from 
			(select [Date] = case when @Grouping in(1, 2, 3, 4, 5, 6) then dateadd(ms, -datepart(ms, @Date), @Date)       else @Date  end
		) ms ) ss ) mi ) hh ) dd ) mm 
	)

end

go
