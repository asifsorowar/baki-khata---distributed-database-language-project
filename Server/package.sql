SET VERIFY OFF;
SET SERVEROUTPUT ON;
ALTER SESSION SET nls_date_format='YYYY-MON-DD';
	
CREATE OR REPLACE PACKAGE BakiKhata AS
	FUNCTION findCustomer(phone IN Customers.customer_phoneNumber@site1%Type)
	RETURN int;
	PROCEDURE createCustomerAccount(phone IN Customers.customer_phoneNumber@site1%Type);
	PROCEDURE UpdateData(phone IN Customers.customer_phoneNumber@site1%Type, given IN Deals.given@site1%Type, remain IN Deals.remain@site1%Type);
	PROCEDURE RamainPay(phone IN Customers.customer_phoneNumber@site1%Type, payment float);
	PROCEDURE DailyRemain(rDate TRemains.RemainDate@site1%Type);
	PROCEDURE DailyCash(dDate TCash.dealDate@site1%Type);
	PROCEDURE customerDeal(phone IN Customers.customer_phoneNumber@site1%Type);
	PROCEDURE AllCustomers;
END BakiKhata;
/

CREATE OR REPLACE PACKAGE BODY BakiKhata AS

	FUNCTION findCustomer(phone IN Customers.customer_phoneNumber@site1%Type)
	RETURN int
	IS
	checkPhone Customers.customer_phoneNumber@site1%TYPE;
	CURSOR isCustomer is 
      SELECT customer_phoneNumber FROM Customers@site1 WHERE customer_phoneNumber=phone;
	  
	BEGIN
		OPEN isCustomer;
		FETCH isCustomer into checkPhone;
		IF isCustomer%NOTFOUND THEN
			RETURN 0;
		ELSE
			CLOSE isCustomer;
			RETURN 1;
		END IF;
	END findCustomer;
	

	PROCEDURE createCustomerAccount(phone IN Customers.customer_phoneNumber@site1%Type)
	IS
	customer_name Customers.customer_name@site1%TYPE := 'asif';
	address Customers.address@site1%TYPE := 'lax';
	BEGIN
		INSERT INTO Customers@site1 values(phone, customer_name, address);
	END createCustomerAccount;
	
	
	
	PROCEDURE UpdateData(phone IN Customers.customer_phoneNumber@site1%Type, given IN Deals.given@site1%Type, remain IN Deals.remain@site1%Type)
	IS
	isCustomer int;
	dealCount number;
	dlDate DATE;
	tCash float;
	tRemain float;
	phLen int;
	Value_Error EXCEPTION;
	INVALID_PHONE EXCEPTION;
	
	PRAGMA AUTONOMOUS_TRANSACTION;
	
	BEGIN
		SELECT LENGTH(phone) INTO phLen FROM dual;
		IF (phLen < 10) THEN
			RAISE INVALID_PHONE;
		ELSIF (given < 0 OR remain <0) THEN
			RAISE Value_Error;
		ELSE
			isCustomer := findCustomer(phone);
			SELECT COUNT(Deals.deal_id) into dealCount FROM Deals@site1;
			SELECT sysdate  into dlDate FROM dual;
			IF isCustomer = 1 THEN
					INSERT INTO Deals@site1 values(dealCount+1, phone, given, remain, dlDate, 'shoping');
					SELECT totalCash INTO tCash FROM TCash@site1 WHERE customer_phoneNumber=phone;
					SELECT totalRemain INTO tRemain FROM TRemains@site1 WHERE customer_phoneNumber=phone;
					
					tCash := tCash + given;
					tRemain := tRemain + remain;
					
					UPDATE TCash@site1
					SET dealDate = dlDate, totalCash = tCash
					WHERE customer_phoneNumber=phone;
					UPDATE TRemains@site1
					SET RemainDate = dlDate, totalRemain = tRemain
					WHERE customer_phoneNumber=phone;
			ELSE
				DBMS_OUTPUT.PUT_LINE('OPPS! NO CUSTOMER DATA FOUND!!');
				DBMS_OUTPUT.PUT_LINE('CREATING AN ACCOUNT');
				createCustomerAccount(phone);
				INSERT INTO Deals@site1 VALUES(dealCount+1, phone, given, remain, dlDate, 'shoping');
				INSERT INTO TCash@site1 VALUES(dlDate, given, phone);
				INSERT INTO TRemains@site1 VALUES(dlDate, remain, phone);
			END IF;
		END IF;
		COMMIT;
		
	EXCEPTION
		WHEN Value_Error THEN
			DBMS_OUTPUT.PUT_LINE('Cash or Remain can not be negative!!!');
		WHEN INVALID_PHONE THEN
			DBMS_OUTPUT.PUT_LINE('Phone Number Length must be 11');
	END UpdateData;
	
	
	PROCEDURE RamainPay(phone IN Customers.customer_phoneNumber@site1%Type, payment float)
	IS
	isCustomer int;
	tCash float;
	tremain float;
	dt DATE;
	sRemain float;
	dealCount number;
	phLen int;
	Value_Error EXCEPTION;
	INVALID_PHONE EXCEPTION;
	
	PRAGMA AUTONOMOUS_TRANSACTION;
	
	BEGIN
		SELECT LENGTH(phone) INTO phLen FROM dual;
		IF (phLen < 10) THEN
			RAISE INVALID_PHONE;
		ELSE
			SELECT sysdate  into dt FROM dual;
			isCustomer := findCustomer(phone);
			IF isCustomer = 1 THEN
				SELECT totalRemain INTO tremain FROM TRemains@site1 WHERE customer_phoneNumber=phone;
				SELECT totalCash INTO tCash FROM TCash@site1 WHERE customer_phoneNumber=phone;
				IF tremain < payment THEN
					RAISE Value_Error;
				ELSE				
					SELECT COUNT(Deals.deal_id) into dealCount FROM Deals@site1;
					INSERT INTO Deals@site1 values(dealCount+1, phone, payment, payment-tremain, dt, 'Remain Paid');
				
					UPDATE TCash@site1
					SET dealDate = dt, totalCash = tCash+payment
					WHERE customer_phoneNumber=phone;
					UPDATE TRemains@site1
					SET RemainDate = dt, totalRemain = tRemain-payment
					WHERE customer_phoneNumber=phone;
					
					SELECT totalCash INTO Tcash FROM TCash@site1 WHERE customer_phoneNumber=phone;
					SELECT totalRemain INTO Tremain FROM TRemains@site1 WHERE customer_phoneNumber=phone;
				
					DBMS_OUTPUT.PUT_LINE('Total Payment: ');
					DBMS_OUTPUT.PUT_LINE(TCash);
					DBMS_OUTPUT.PUT_LINE('Total Remain: ');
					DBMS_OUTPUT.PUT_LINE(Tremain);
				END IF;
			ELSE
				DBMS_OUTPUT.PUT_LINE('No data found!!!');
			END IF;
		END IF;
		COMMIT;
		
	EXCEPTION
		WHEN Value_Error THEN
			DBMS_OUTPUT.PUT_LINE('Payment can not be bigger then remain!!');
		WHEN INVALID_PHONE THEN
			DBMS_OUTPUT.PUT_LINE('Phone Number Length must be 11');
	END RamainPay;
	
	PROCEDURE DailyRemain(rDate TRemains.RemainDate@site1%Type)
	IS
	BEGIN
		DBMS_OUTPUT.PUT_LINE('CUSTOMERPHONE' || ' --- ' || 'TOTAL REMAIN' || ' --- ' || 'DATE');
		FOR R IN (SELECT customer_phoneNumber, totalRemain, RemainDate FROM TRemains@site1 WHERE TO_DATE(RemainDate)=rDate) LOOP
			DBMS_OUTPUT.PUT_LINE(R.customer_phoneNumber || ' ------- ' || R.totalRemain || ' ------- ' || R.RemainDate);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Invalid Date Formate!!!');
	END DailyRemain;
	
	PROCEDURE DailyCash(dDate TCash.dealDate@site1%Type)
	IS
	BEGIN
		DBMS_OUTPUT.PUT_LINE('CUSTOMERPHONE' || ' --- ' || 'TOTAL CASH' || ' --- ' || 'DATE');
		FOR R IN (SELECT customer_phoneNumber, totalCash, dealDate FROM TCash@site1 WHERE TO_DATE(dealDate)=dDate) LOOP
			DBMS_OUTPUT.PUT_LINE(R.customer_phoneNumber || ' ------- ' || R.totalCash || ' ------- ' || R.dealDate);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Invalid Date Formate!!!');
	END DailyCash;
	
	PROCEDURE customerDeal(phone IN Customers.customer_phoneNumber@site1%Type)
	IS
	total float;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('GIVEN' || ' --- ' || 'TOTAL CASH' || ' --- ' || 'DATE' || ' --- ' || 'History');
		FOR R IN (SELECT given, Deals.dealDate, reason FROM Deals@site1 JOIN TCash@site1 ON Deals.customer_phoneNumber = TCash.customer_phoneNumber WHERE Deals.customer_phoneNumber=phone) LOOP
			DBMS_OUTPUT.PUT_LINE(R.given || ' ------- ' || '--' || ' ------- ' || R.dealDate || ' ------- ' || R.reason );
		END LOOP;
		SELECT totalCash INTO total FROM TCash@site1 WHERE customer_phoneNumber=phone;
		DBMS_OUTPUT.PUT_LINE('Total Cash Received: ' || total );
		
		DBMS_OUTPUT.PUT_LINE('REMAIN' || ' --- ' || 'TOTAL REMAIN' || ' --- ' || 'DATE' || ' --- ' || 'History');
		FOR R IN (SELECT remain, RemainDate, reason FROM Deals@site1 NATURAL JOIN TRemains@site1 WHERE customer_phoneNumber=phone) LOOP
			DBMS_OUTPUT.PUT_LINE(R.remain || ' ------- ' || '--' || ' ------- ' || R.RemainDate || ' ------- ' || R.reason);
		END LOOP;
		SELECT totalRemain INTO total FROM TRemains WHERE customer_phoneNumber=phone;
		DBMS_OUTPUT.PUT_LINE('Total Cash Remaining: ' || total );
		
	EXCEPTION
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Invalid Date Formate!!!');
	END customerDeal;
	
	PROCEDURE AllCustomers
	IS
	BEGIN
		null;
	END AllCustomers;
END BakiKhata;
/
	

