--Remove extra spaces at the beginning and end of the date field, and remove the time
--Replace various delimiters (. / -) with a single one (-)

create OR REPLACE FUNCTION public.date_clean(date_raw text)
RETURNS text
LANGUAGE sql
as $$
   select
	split_part(
            REPLACE(REPLACE(TRIM(date_raw), '/', '-'), '.', '-'),
	' ',
 	1);
$$;
