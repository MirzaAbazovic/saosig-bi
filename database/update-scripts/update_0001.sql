drop procedure if exists dim_time_insert;
delimiter //
CREATE PROCEDURE dim_time_insert (p_start_date DATE, p_end_date DATE)
BEGIN
    DECLARE v_full_date DATE;
    DELETE FROM datedim;
    SET v_full_date = p_start_date;
    WHILE v_full_date <= p_end_date DO
		INSERT INTO dim_time(`time_id`,`date`,`day_eng`,`month_eng`,`day_bos`,`month_bos`,`year`,`day_of_month`,`week_of_year`,`quarter`,`half_year`,`month`)
		SELECT 
			DATE_FORMAT(v_full_date,'%Y%m%d') as time_id,
            v_full_date as full_date,
            DAYNAME(v_full_date) as day_name_eng,
			MONTHNAME(v_full_date) as month_name_eng,
			CASE DAYNAME(v_full_date) WHEN 'Monday' THEN 'Ponedjeljak' WHEN 'Tuesday' THEN 'Utorak' WHEN 'Wednesday' THEN 'Srijeda' WHEN 'Thursday' THEN 'Četvrtak' WHEN 'Friday' THEN 'Petak' WHEN 'Saturday' THEN 'Subota' WHEN 'Sunday' THEN 'Nedjelja' ELSE NULL END as day_name_bos,
			CASE MONTH(v_full_date) WHEN 1 THEN 'Januar' WHEN 2 THEN 'Februar' WHEN 3 THEN 'Mart' WHEN 4 THEN 'April' WHEN 5 THEN 'Maj' WHEN 6 THEN 'Juni' WHEN 7 THEN 'Juli' WHEN 8 THEN 'August' WHEN 9 THEN 'Septembar' WHEN 10 THEN 'Oktobar' WHEN 11 THEN 'Novembar' WHEN 12 THEN 'Decembar' ELSE NULL END as month_name_bos,						
			YEAR(v_full_date) as "year",
			DAYOFMONTH(v_full_date) as day_of_month,
			WEEK(v_full_date) as week_of_year,
			QUARTER(v_full_date) as "quarter",
            CEIL(MONTH(v_full_date) / 6) AS "half_year",
            MONTH(v_full_date) as "month";
	SET v_full_date = DATE_ADD(v_full_date, INTERVAL 1 DAY);
    END WHILE;
END;
/*
-- insert 2014 godina
CALL `insurance_dw`.`dim_time_insert`('2014-01-01', '2014-12-31');

*/

/*
%a	Abbreviation of the day (from Sun-Sat)
%b	Abbreviation of the month (from Jan-Dec)
%c	Numeric month (from 1-12)
%D	Numeric day of the month with suffix (1st, 2nd, and so on)
%d	Numeric day of the month with two digits(from 00-31)
%e	Numeric day of the month with one or two digits(from 0-31)
%H	Hour (from 00-23)
%h	Hour (from 01-12)
%i	Minutes (from 00-59)
%I	Hour (from 01-12)
%j	Day of the year (from 001-366)
%k	Hour with one or two digits (from 0-23)
%l	Hour with one digit (from 1-12)
%M	Month name (from January-December)
%m	Numeric month (from 01-12)
%p	A.M. or P.M.
%r	12-hour time (hh:mm:ss A.M.or P.M.)
%S	Seconds (from 00-59)
%s	Seconds (from 00-59)
%T	24 hour time (hh:mm:ss)
%U	Week (from 00-53, Sunday being the first day of the week)
%u	Week (from 00-53, Monday being the first day of the week)
%V	Week (from 01-53, Sunday being the first day of the week)
%v	Week (from 01-53, Monday being the first day of the week)
%W	Name of the day in the week (from Sunday-Saturday)
%w	Day of the week (from 0 - Sunday, to 6 - Saturday)
%X	Four-digit numeric year for the week (Sunday being the first day of the week)
%x	Four-digit numeric year for the week (Monday being the first day of the week)
%Y	Four-digit numeric year
%y	Two-digit numeric year
%%	Percentage sign (escaped)
Let's look at converting a standard date into a format used in the US.

mysql> SELECT DATE_FORMAT('2003-07-14','%b %d,%Y');
*/