CREATE TABLE Employee (
     --depID 01:office, 02: opertional, 03:manager, 04: partner
    emp_code VARCHAR(9),
    
    fname VARCHAR(40),
    lname VARCHAR(40),
    gender VARCHAR(3),
    address  VARCHAR(70),
  
    phone_number VARCHAR(15),
    depID INT,
    PRIMARY KEY (emp_code)
   );
   CREATE TABLE Operational_staff (
    operational_staff_code VARCHAR(9),
    PRIMARY KEY (operational_staff_code),
    FOREIGN KEY (operational_staff_code) REFERENCES Employee(emp_code)
);
CREATE TABLE Manager (
    manager_code VARCHAR(9),
    PRIMARY KEY (manager_code),
    FOREIGN KEY (manager_code) REFERENCES Employee(emp_code)
);
CREATE TABLE Partner_staff (
    partner_staff_code VARCHAR(9),
    PRIMARY KEY (partner_staff_code),
    FOREIGN KEY (partner_staff_code) REFERENCES Employee(emp_code)
);
CREATE TABLE Office_staff (
    office_staff_code VARCHAR(9),
    PRIMARY KEY (office_staff_code),
    FOREIGN KEY (office_staff_code) REFERENCES Employee(emp_code)
);
-- generate employee code
CREATE SEQUENCE emp_seq START WITH 1;
CREATE OR REPLACE TRIGGER emp_id
BEFORE INSERT ON Employee
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('EC'  || TO_CHAR(emp_seq.NEXTVAL, 'fm0000'))
    INTO :new.emp_code
    FROM dual;
END;
-------
CREATE TABLE Supplier (
sup_code VARCHAR(9),
sname VARCHAR(40),
address VARCHAR(100),
bank_account VARCHAR(15),
tax_code VARCHAR(15),
partner_staff_code VARCHAR(9),
 PRIMARY KEY (sup_code),
 FOREIGN KEY (partner_staff_code) REFERENCES Partner_staff (partner_staff_code)
);
CREATE Table Sup_phone_number (
    sup_code VARCHAR(9),
    phone_number VARCHAR(15),
    PRIMARY KEY (sup_code,phone_number),
    FOREIGN KEY (sup_code) REFERENCES Supplier(sup_code)

);
CREATE  SEQUENCE sup_seq START WITH 1;

CREATE TRIGGER sup_trigger
BEFORE INSERT ON Supplier
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('SU'  || TO_CHAR(sup_seq.NEXTVAL, 'fm0000'))
    INTO :new.sup_code
    FROM dual;
END;
CREATE TABLE Fcategory (
    
cat_code VARCHAR(9),
fabric_name VARCHAR(15),
color VARCHAR(15),
quantity INT NOT NULL,
sup_code VARCHAR(9),
fdate DATE,
purchase_price INT NOT NULL,
imported_quantity INT NOT NULL,
PRIMARY KEY (cat_code),
FOREIGN KEY(sup_code) REFERENCES Supplier(sup_code)


);

CREATE  SEQUENCE cat_seq START WITH 1;

CREATE TRIGGER cat_trigger
BEFORE INSERT ON Fcategory
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('CAT'  || TO_CHAR(cat_seq.NEXTVAL, 'fm0000'))
    INTO :new.cat_code
    FROM dual;
END;
CREATE TABLE Cat_current_price (
cat_code VARCHAR(9),
price INT NOT NULL,
cdate DATE,
PRIMARY KEY(cat_code,price,cdate),
FOREIGN KEY (cat_code) REFERENCES Fcategory(cat_code)

);
CREATE TABLE Bolt (
    cat_code VARCHAR(9),
    bol_code VARCHAR(9),
    blength INT NOT NULL,
    PRIMARY KEY (bol_code,cat_code),
    FOREIGN KEY (cat_code) REFERENCES Fcategory(cat_code)
);
INSERT INTO  Bolt VALUES ('CAT0006', 'BO0004', '15');

CREATE TABLE Ord (
    
    ord_code VARCHAR(9) ,
    total_price INT NOT NULL,
    cus_code VARCHAR(9),
    
    ord_date DATE,
    ord_time TIMESTAMP,
    operational_staff_code VARCHAR(9),
    ord_status VARCHAR(9),
    PRIMARY KEY (ord_code),
    FOREIGN KEY (operational_staff_code) REFERENCES Operational_staff(operational_staff_code)
);

CREATE TABLE Cancel_order (
    ord_code VARCHAR(9),
    cus_code VARCHAR(9),
    operational_staff_code VARCHAR(9),
    reason VARCHAR(100),
    FOREIGN KEY(ord_code) REFERENCES Ord(ord_code)
);




--

CREATE TABLE Contain (
     cat_code VARCHAR(9),
     bol_code VARCHAR(9),
     ord_code VARCHAR(9),
     PRIMARY KEY (cat_code,bol_code),
     FOREIGN KEY (bol_code,cat_code) REFERENCES Bolt(bol_code,cat_code)
);



CREATE TABLE Customer (
    
    cus_code VARCHAR(9)  ,
    fname    VARCHAR(40),
    lname    VARCHAR(40),
    address  VARCHAR(100),
    arrearage INT NOT NULL,
    office_staff_code  VARCHAR(9),
    PRIMARY KEY (cus_code),
    FOREIGN KEY (office_staff_code) REFERENCES Office_staff(office_staff_code)
    );
  
CREATE SEQUENCE cus_seq START WITH 1;
CREATE OR REPLACE TRIGGER cus_trigger
BEFORE INSERT ON Customer
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('CC'  || TO_CHAR(cus_seq.NEXTVAL, 'fm0000'))
    INTO :new.cus_code
    FROM dual;
END;
CREATE TABLE Cus_phone_number (
cus_code VARCHAR(9),
phone_number VARCHAR(15),
PRIMARY KEY(cus_code,phone_number),
FOREIGN KEY(cus_code) REFERENCES Customer(cus_code)
);
CREATE TABLE Cus_partial_payment (
   cus_code VARCHAR(9) ,
   pdate DATE,
   amount INT NOT NULL,
   
   PRIMARY KEY(cus_code,pdate,amount),
   FOREIGN KEY (cus_code) REFERENCES Customer(cus_code)
   

);
---INSERT--
INSERT INTO Employee VALUES ('','John' ,'Smith','M', '731 Fondren, Houston, TX, US', '+1 202 555 0118',01);
INSERT INTO Employee VALUES ('', 'Lebron',    'James',     'M', '638 Voss, Houston, TX, US',   '+1 281 555 0176',01);
INSERT INTO Employee VALUES ('',  'Micheal', 'Roberts',  'M', '869 Sit Rd., Bundaberg, NSW, Aus',   '+61 7 5277 5734',01);
INSERT INTO Employee VALUES ('',   'Leo','Messi',  'F', '291 Berry, Bellaire, TX, US', '+1 613 555 0165',02);
INSERT INTO Employee VALUES ('',   'Ramesh', 'Narayan',  'M', '975 Fire Oak, Humble, TX, US', '+1 256 555 0114',02);
INSERT INTO Employee VALUES ('',   'Johnny',  'English',  'F', '5631 Rice, Houston, TX, US',  '+1 281 555 0179',02);
INSERT INTO Employee VALUES ('',   'Ahmad',  'Jabbar',   'M', '980 Dallas, Houston, TX, US',  '+1 281 555 0102',03);
INSERT INTO Employee VALUES ('',   'James', 'Harden',     'M', '450 Stone, Houston, TX', '+1 281 555 0147',04);
INSERT INTO Employee VALUES ('',   'Khoa', 'Pug',   'F', '4118 Dictum, Berlin, Hamburg, Germany','+49 21 213 7385',04);

-- * Manager 03
INSERT INTO Manager
SELECT emp_code
FROM Employee
WHERE depID = 03;

-- * Office Staff 01
INSERT INTO Office_Staff
SELECT emp_code
FROM Employee
WHERE depID = 01;

-- * Operation Staff 02
INSERT INTO Operational_Staff
SELECT emp_code
FROM Employee
WHERE depID = 02;

-- * Partner Staff 04
INSERT INTO Partner_Staff
SELECT emp_code
FROM Employee
WHERE depId = 04;
-- * Supplier
-- S_Code, Name, Address, Bank_Acount, Tax_Code, Partner_Staff_Code
INSERT INTO Supplier VALUES ('', 'MSC Industrial Supply', '168 Odio. Rd., Melville, NY, US',  'VG934578442495',       '74 7873724',       'EC0008');
INSERT INTO Supplier VALUES ('', 'Wurth Industry North America', 'Ap #213-3892 Egestas. Rd., Ramsey, NJ, US',    '3637210',    '33 0086631',       'EC0008');
INSERT INTO Supplier VALUES ('', 'KPF',                             '50 Chungjusandan, Chungju-Si, KR',             '123552529112',         '339 00 631',     'EC0008');
INSERT INTO Supplier VALUES ('', 'Zhejiang Laibao Precision',       '668 Donghai Rd., Xitangquiao, Haiyan, CN',     '91234567890',          '5151 6570','EC0009');
INSERT INTO Supplier VALUES ('', 'Sanritsu Corp.',                  '1-1 Ebiso-Cho, Yokohama . JAPAN',              '4571 8764',            '840751 718',  'EC0009');
INSERT INTO Supplier VALUES ('', 'Silk Agency',  'JAPAN',  '431 8764',  '8451 718',  'EC0009');

-- * Supplier Phone Numbers
INSERT INTO Sup_phone_Number VALUES ('SU0026', '800 645 7270');
INSERT INTO Sup_phone_Number VALUES ('SU0027', '+1 800 645 7270');
INSERT INTO Sup_phone_Number VALUES ('SU0028', '+1 877 999 8784');
INSERT INTO Sup_phone_Number VALUES ('SU0029', '031 38 9700');

INSERT INTO Fcategory VALUES ('', 'Silk', 'Red', 626, 'SU0026', '30-DEC-2020', 900, 500);
INSERT INTO Fcategory VALUES ('', 'Silk', 'Blue', 153, 'SU0027', '15-JAN-2021',750, 1000);
INSERT INTO Fcategory VALUES ('', 'Silk', 'Yellow', 495, 'SU0028', '05-MAR-2019', 1200, 700);
INSERT INTO Fcategory VALUES ('', 'Crewel', 'Green', 123, 'SU0026', '24-MAY-2020', 500, 400);
INSERT INTO Fcategory VALUES ('', 'Damask', 'Purple', 86, 'SU0027', '18-SEP-2020', 300, 600);
INSERT INTO Fcategory VALUES ('', 'Silk', 'Yellow', 96, 'SU0030', '20-DEC-2020', 100, 500);

INSERT INTO Cat_current_price VALUES ('CAT0001', 550, '03-JAN-2021');
INSERT INTO Cat_current_price VALUES ('CAT0002', 900, '17-JAN-2022');
INSERT INTO Cat_current_price VALUES ('CAT0003', 600, '23-FEB-2020');
INSERT INTO Cat_current_price VALUES ('CAT0003', 650, '08-JUL-2021');
INSERT INTO Cat_current_price VALUES ('CAT0004', 500, '29-DEC-2021');
INSERT INTO Cat_current_price VALUES ('CAT0005', 500, '01-AUG-2022');
INSERT INTO Customer VALUES ('', 'Josephine', 'Darakjy', '4 B Blue Ridge Blvd', 0, 'EC0001');
INSERT INTO Customer VALUES ('', 'Art', 'Venere', '8 W Cerritos Ave', 0, 'EC0001');
INSERT INTO Customer VALUES ('', 'Lenna', 'Paprocki', '25 E 75th St', 0, 'EC0002');
INSERT INTO Customer VALUES ('', 'Paprocki', 'Foller', '34 Center St', 0, 'EC0003');

INSERT INTO Bolt VALUES ('CAT0001', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CAT0002', 'BO0002', 15);
INSERT INTO Bolt VALUES ('CAT0003', 'BO0003', 20);






-------2.2a increase purchase price of supplier 
CREATE PROCEDURE UpdateSilkprice
AS 
BEGIN 
UPDATE Fcategory
SET purchase_price= purchase_price*1.1
WHERE fabric_name='Silk' and fdate > TO_DATE('2020-09-01','YYYY-MM-DD');

END;

EXEC UpdateSilkprice;

--2.2b
INSERT INTO Ord VALUES ('OC0001', '500', 'CC0001', TO_DATE('2022-11-25 18:23:50', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2022-11-25 18:23:58.232500000', 'YYYY-MM-DD HH24:MI:SS.FF'), 'EC0004', 'ordered')

--- get_order
SELECT * FROM Ord WHERE ord_code IN (SELECT ord_code FROM Contain WHERE (cat_code,bol_code)IN (SELECT  cat_code,bol_code from Bolt WHERE cat_code IN (SELECT cat_code from Fcategory where sup_code = (select sup_code from Supplier WHERE sname = 'Silk Agency'))));

---function total cau c
CREATE OR REPLACE FUNCTION Total_price (b IN Fcategory.sup_code%TYPE)
RETURN NUMBER
AS 
a NUMBER;
BEGIN
      SELECT sum(purchase_price)  INTO a FROM Fcategory  
      WHERE sup_code = b
      GROUP BY sup_code;
      RETURN a;
END Total_price ;

--2.2d

---sort
create or replace PROCEDURE sort_cate
 (start_date in Fcategory.fdate%TYPE,end_date in Fcategory.fdate%TYPE)
 AS
  CURSOR C1 IS
  SELECT count(cat_code)  cate_number, sup_code 
  FROM Fcategory 
  WHERE fdate > start_date AND fdate < end_date
  GROUP BY sup_code
  ORDER BY cate_number ASC;
BEGIN
FOR rec in C1
LOOP
DBMS_OUTPUT.PUT_LINE(rec.cate_number||' '|| rec.sup_code);
END LOOP;
END sort_cate;

SET SERVEROUTPUT ON;
EXEC sort_cate (TO_DATE('2018-09-01','YYYY-MM-DD'),TO_DATE('2023-09-01','YYYY-MM-DD'));