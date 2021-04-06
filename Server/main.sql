--1: For Insert new deal'
--2: For Update User payment'
--3: For get daily Cash'
--4: For get daily remain'
--5: For customer Info'
SET VERIFY OFF;
SET SERVEROUTPUT ON;

ACCEPT S NUMBER PROMPT "Enter 1 | 2 | 3 | 4 | 5: "

DECLARE
	phone Customers.customer_phoneNumber%Type;
	S number := &S;
	given float;
	remain float;
	payment Deals.remain%Type;
	dt Date;
BEGIN
	IF S = 1 THEN
		phone := '01766771609';
		given := 2000.00;
		remain := 1000.00;
		BakiKhata.UpdateData(phone, given, remain);
	ELSIF S = 2 THEN
		phone := '01766771609';
		payment := 500;
		BakiKhata.RamainPay(phone, payment);
	ELSIF S = 3 THEN
		DBMS_OUTPUT.PUT_LINE('DATE FORMATE: YEAR-MONTH-DAY | EX: 2021-MAR-20');
		dt := '02-APR-21';
		BakiKhata.DailyCash(dt);
	ELSIF S = 4 THEN
		DBMS_OUTPUT.PUT_LINE('DATE FORMATE: YEAR-MONTH-DAY | EX: 2021-MAR-20');
		dt := '02-APR-21';
		BakiKhata.DailyRemain(dt);
	ELSIF S = 5 THEN
		phone := '01766771609';
		BakiKhata.customerDeal(phone);
	ELSE
		DBMS_OUTPUT.PUT_LINE('Invalid input!!!');
	END IF;

END;
/

--SELECT * FROM TOTALDEAL_VIEW@site1;
--SELECT * FROM TREMAIN_VIEW@site1;
--SELECT * FROM CUSTOMERS_VIEW@site1;
--SELECT * FROM TCASH_VIEW@site1;