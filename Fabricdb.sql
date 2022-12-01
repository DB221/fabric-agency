CREATE TABLE employee (
     --depID 01:office, 02: operational, 03:manager, 04: partner
    emp_code     VARCHAR(9)     NOT NULL,
    fname        VARCHAR(40)    NOT NULL,
    lname        VARCHAR(40),
    gender       VARCHAR(9)     NOT NULL,
    address      VARCHAR(90)    NOT NULL,
    phone_number VARCHAR(15)    NOT NULL,
    depid        INT,
    PRIMARY KEY ( emp_code )
);

CREATE TABLE operational_staff (
    operational_staff_code VARCHAR(9)   NOT NULL,
    PRIMARY KEY ( operational_staff_code ),
    FOREIGN KEY ( operational_staff_code )
        REFERENCES employee ( emp_code )
);

CREATE TABLE manager (
    manager_code VARCHAR(9)     NOT NULL,
    PRIMARY KEY ( manager_code ),
    FOREIGN KEY ( manager_code )
        REFERENCES employee ( emp_code )
);

CREATE TABLE partner_staff (
    partner_staff_code VARCHAR(9)   NOT NULL,
    PRIMARY KEY ( partner_staff_code ),
    FOREIGN KEY ( partner_staff_code )
        REFERENCES employee ( emp_code )
);

CREATE TABLE office_staff (
    office_staff_code VARCHAR(9)    NOT NULL,
    PRIMARY KEY ( office_staff_code ),
    FOREIGN KEY ( office_staff_code )
        REFERENCES employee ( emp_code )
);

CREATE TABLE supplier (
    sup_code           VARCHAR(9)   NOT NULL,
    sname              VARCHAR(40)  NOT NULL,
    address            VARCHAR(100) NOT NULL,
    bank_account       VARCHAR(15)  NOT NULL UNIQUE,
    tax_code           VARCHAR(15)  NOT NULL UNIQUE,
    partner_staff_code VARCHAR(9)   NOT NULL,
    PRIMARY KEY ( sup_code ),
    FOREIGN KEY ( partner_staff_code )
        REFERENCES partner_staff ( partner_staff_code )
);

CREATE TABLE sup_phone_number (
    sup_code     VARCHAR(9)     NOT NULL,
    phone_number VARCHAR(15)    NOT NULL,
    PRIMARY KEY ( sup_code,
                  phone_number ),
    FOREIGN KEY ( sup_code )
        REFERENCES supplier ( sup_code )
);

CREATE TABLE fcategory (
    cat_code          VARCHAR(9)    NOT NULL,
    fabric_name       VARCHAR(15)   NOT NULL,
    color             VARCHAR(15)   NOT NULL,
    quantity          INT           CHECK (quantity > 0)    NOT NULL,
    sup_code          VARCHAR(9)    NOT NULL,
    fdate             DATE          NOT NULL,
    purchase_price    INT           CHECK (purchase_price > 0)      NOT NULL,
    imported_quantity INT           CHECK (imported_quantity > 0)    NOT NULL,
    PRIMARY KEY ( cat_code ),
    FOREIGN KEY ( sup_code )
        REFERENCES supplier ( sup_code )
);

CREATE TABLE cat_current_price (
    cat_code VARCHAR(9)     NOT NULL,
    price    INT    CHECK (Price > 0)   NOT NULL,
    cdate    DATE           NOT NULL,
    PRIMARY KEY ( cat_code,
                  price,
                  cdate ),
    FOREIGN KEY ( cat_code )
        REFERENCES fcategory ( cat_code )
);

CREATE TABLE bolt (
    cat_code    VARCHAR(9)     NOT NULL,
    bol_code    VARCHAR(9)     NOT NULL,
    blength  FLOAT  CHECK (blength > 0) NOT NULL,
    PRIMARY KEY ( bol_code,
                  cat_code ),
    FOREIGN KEY ( cat_code )
        REFERENCES fcategory ( cat_code )
);

CREATE TABLE customer (
    cus_code          VARCHAR(9)    NOT NULL,
    fname             VARCHAR(40)   NOT NULL,
    lname             VARCHAR(40),
    address           VARCHAR(100),
    arrearage         INT CHECK (arrearage >= 0) NOT NULL,
    office_staff_code VARCHAR(9)    NOT NULL,
    PRIMARY KEY ( cus_code ),
    FOREIGN KEY ( office_staff_code )
        REFERENCES office_staff ( office_staff_code )
);

CREATE TABLE cus_phone_number (
    cus_code     VARCHAR(9) NOT NULL,
    phone_number VARCHAR(15)    NOT NULL,
    PRIMARY KEY ( cus_code,
                  phone_number ),
    FOREIGN KEY ( cus_code )
        REFERENCES customer ( cus_code )
);

CREATE TABLE cus_partial_payment (
    cus_code VARCHAR(9) NOT NULL,
    pdate    DATE   NOT NULL,
    amount   INT    CHECK (Amount > 0)  NOT NULL,
    PRIMARY KEY ( cus_code,
                  pdate,
                  amount ),
    FOREIGN KEY ( cus_code )
        REFERENCES customer ( cus_code )
);

CREATE TABLE ord (
    ord_code               VARCHAR(9)   NOT NULL,
    total_price            INT CHECK (Total_Price > 0)  NOT NULL,
    cus_code               VARCHAR(9)   NOT NULL,
    ord_date               DATE         NOT NULL,
    operational_staff_code VARCHAR(9)   NOT NULL,
    ord_status             VARCHAR(15)  NOT NULL,
    history_payment        INT          CHECK (history_payment >= 0)  NOT NULL,
    PRIMARY KEY ( ord_code ),
    FOREIGN KEY ( operational_staff_code )
        REFERENCES operational_staff ( operational_staff_code ),
    FOREIGN KEY ( cus_code )
        REFERENCES customer ( cus_code )
);

CREATE TABLE cancel_order (
    ord_code               VARCHAR(9)   NOT NULL,
    cus_code               VARCHAR(9)   NOT NULL,
    operational_staff_code VARCHAR(9)   NOT NULL,
    reason                 VARCHAR(100) NOT NULL,
    PRIMARY KEY ( ord_code ), 
    FOREIGN KEY ( ord_code )
        REFERENCES ord ( ord_code ),
    FOREIGN KEY ( cus_code )
        REFERENCES customer ( cus_code ),  
    FOREIGN KEY ( operational_staff_code )
        REFERENCES operational_staff ( operational_staff_code )  
);



--

CREATE TABLE contain (
    cat_code VARCHAR(9) NOT NULL,
    bol_code VARCHAR(9) NOT NULL,
    ord_code VARCHAR(9) NOT NULL,
    PRIMARY KEY ( cat_code,
                  bol_code ),
    FOREIGN KEY ( bol_code,
                  cat_code )
        REFERENCES bolt ( bol_code,
                          cat_code )
);

---auto sequence to insert ID
CREATE SEQUENCE emp_seq START WITH 1;
CREATE  SEQUENCE sup_seq START WITH 1;
CREATE  SEQUENCE cat_seq START WITH 1;
CREATE SEQUENCE cus_seq START WITH 1;
/
CREATE OR REPLACE TRIGGER emp_id
BEFORE INSERT ON Employee
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('EC'  || TO_CHAR(emp_seq.NEXTVAL, 'fm0000'))
    INTO :new.emp_code
    FROM dual;
END;
/

CREATE TRIGGER sup_trigger
BEFORE INSERT ON Supplier
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('SU'  || TO_CHAR(sup_seq.NEXTVAL, 'fm0000'))
    INTO :new.sup_code
    FROM dual;
END;

/

CREATE TRIGGER cat_trigger
BEFORE INSERT ON Fcategory
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('CAT'  || TO_CHAR(cat_seq.NEXTVAL, 'fm0000'))
    INTO :new.cat_code
    FROM dual;
END;

/
CREATE OR REPLACE TRIGGER cus_trigger
BEFORE INSERT ON Customer
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('CC'  || TO_CHAR(cus_seq.NEXTVAL, 'fm0000'))
    INTO :new.cus_code
    FROM dual;
END;
/
----CONSTRAINT
ALTER TABLE Fcategory
ADD CONSTRAINT check_cate
CHECK (fabric_name IN ('Silk','Khaki','Crewel','Jacquard','Faux silk','Damask'));

/
ALTER TABLE ord
ADD CONSTRAINT check_ord
CHECK (ord_status IN ('new','cancelled','full paid','partial paid', 'ordered'));
/
---INSERT--
INSERT INTO Employee VALUES ('','Kim' ,'Walter','M', '835 Frank Tunnel Wrightmouth,MI', '+1 2025550118',01);
INSERT INTO Employee VALUES ('', 'Lebron',    'James',     'M', '1414 David Throughway Port Jason, OH',  '+1 2815550176',01);
INSERT INTO Employee VALUES ('',  'Carrie', 'Francis',  'M', '14023 Rodriguez Passage Port Jacobville, PR',   '+61 7 52775734',01);
INSERT INTO Employee VALUES ('',   'Lionel','Messi',  'F', '26104 Alexander Groves Alexandriaport, WY', '+1 613 555 0165',02);
INSERT INTO Employee VALUES ('',   'Joel', 'Combs',  'M', '975 Fire Oak, Humble, TX, US', '+1 256 555 0114',02);
INSERT INTO Employee VALUES ('',   'Johnny',  'English',  'F', '5631 Rice, Houston, TX, US',  '+1 281 555 0179',02);
INSERT INTO Employee VALUES ('',   'Carla','Stinson' ,'F', '6705 Miller Orchard Suite 186 Lake Shanestad, MO ',  '+1 281 555 0102',03);
INSERT INTO Employee VALUES ('',   'Andy', 'Harden',     'M', '450 Stone, Houston, TX', '+1 281 555 0147',04);
INSERT INTO Employee VALUES ('',   'Kobe', 'Bryant',   'F', '4118 Dictum, Berlin, Hamburg, Germany','+49 21 213 7385',04);

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
INSERT INTO Supplier VALUES ('', 'Faux  international', 'Chak no 214-RB Dhudhi Wala Ghousia Road,Pakistan',  'VG934578442495',       '74 7873724',       'EC0008');
INSERT INTO Supplier VALUES ('', 'Istanbul Textil', 'Zeytinburnu 103 sokak,Turkey',    '3637210',    '33 0086631',       'EC0008');
INSERT INTO Supplier VALUES ('', 'KPF Jacquard',                             '50 Chungjusandan, Chungju-Si, KR',             '123552529112',         '339 00 631',     'EC0008');
INSERT INTO Supplier VALUES ('', 'Khaki Agency',       '668 Donghai Rd., Xitangquiao, Haiyan, CN',     '91234567890',          '5151 6570','EC0009');
INSERT INTO Supplier VALUES ('', 'Damask Agency',                  '1-1 Ebiso-Cho, Yokohama . JAPAN',              '4571 8764',            '840751 718',  'EC0009');
INSERT INTO Supplier VALUES ('', 'Silk Agency',  'JAPAN',  '431 8764',  '8451 718',  'EC0009');

-- * Supplier Phone Numbers
INSERT INTO Sup_phone_Number VALUES ('SU0001', '8006457 270');
INSERT INTO Sup_phone_Number VALUES ('SU0002', '+1 800645 7270');
INSERT INTO Sup_phone_Number VALUES ('SU0003', '+1 877999 8784');
INSERT INTO Sup_phone_Number VALUES ('SU0004', '+2 031 389700');
INSERT INTO Sup_phone_Number VALUES ('SU0004', '+2 021 3808840');
INSERT INTO Sup_phone_Number VALUES ('SU0005', '+31 021 835450');
INSERT INTO Sup_phone_Number VALUES ('SU0006', '945192783');



INSERT INTO Fcategory VALUES ('', 'Faux silk', 'Black',1500, 'SU0001', '30-DEC-2020', 900, 2000);
INSERT INTO Fcategory VALUES ('', 'Crewel', 'Blue', 1000, 'SU0002', '15-JAN-2021',750, 4000);
INSERT INTO Fcategory VALUES ('', 'Silk', 'Yellow', 500, 'SU0006', '05-MAR-2019', 1200, 800);
INSERT INTO Fcategory VALUES ('', 'Crewel', 'Green', 300, 'SU0004', '24-MAY-2020', 500, 400);
INSERT INTO Fcategory VALUES ('', 'Damask', 'Purple', 2000, 'SU0005', '18-SEP-2021', 300, 3000);
INSERT INTO Fcategory VALUES ('', 'Silk', 'Yellow', 1000, 'SU0006', '20-DEC-2020', 100, 2000);
INSERT INTO Fcategory VALUES ('', 'Khaki', 'Beige', 1000, 'SU0003', '20-DEC-2021', 100, 2000);

INSERT INTO Cat_current_price VALUES ('CAT0001', 150, '03-JAN-2022');
INSERT INTO Cat_current_price VALUES ('CAT0002', 100, '17-JAN-2022');
INSERT INTO Cat_current_price VALUES ('CAT0003', 250, '23-FEB-2020');
INSERT INTO Cat_current_price VALUES ('CAT0003', 350, '08-JUL-2022');
INSERT INTO Cat_current_price VALUES ('CAT0004', 500, '29-DEC-2022');
INSERT INTO Cat_current_price VALUES ('CAT0005', 450, '03-AUG-2022');
INSERT INTO Cat_current_price VALUES ('CAT0006', 250, '02-AUG-2022');
INSERT INTO Cat_current_price VALUES ('CAT0007', 100, '05-AUG-2022');

INSERT INTO Customer VALUES ('', 'Hiep', 'Nguyen', '94 Tan Huong, SG ,VN ', 1000, 'EC0001');
INSERT INTO Customer VALUES ('', 'Hai', 'Bui', '8 W Cerritos Ave', 0, 'EC0001');
INSERT INTO Customer VALUES ('', 'Duy', 'Le', '302 Dunlap Ferry', 2000, 'EC0002');
INSERT INTO Customer VALUES ('', 'De', 'Paul', '34 Center St', 80, 'EC0003');
INSERT INTO Customer VALUES ('', 'Jesse', 'Pinkman', '34 Saint Mery St', 2500, 'EC0003');
INSERT INTO Customer VALUES ('', 'Walter', 'White', '34 New Mexico St', 1500, 'EC0003');
INSERT INTO Customer VALUES ('', 'John', 'Wick', '99 Indiana Jones St', 0, 'EC0002');

INSERT INTO cus_phone_number VALUES ('CC0001','0943053012');
INSERT INTO cus_phone_number VALUES ('CC0003','094902378');
INSERT INTO cus_phone_number VALUES ('CC0002','0840123401');
INSERT INTO cus_phone_number VALUES ('CC0005','086492152');
INSERT INTO cus_phone_number VALUES ('CC0004','056782209');
INSERT INTO cus_phone_number VALUES ('CC0006', '095300872');


INSERT INTO Bolt VALUES ('CAT0001', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CAT0002', 'BO0002', 15);
INSERT INTO Bolt VALUES ('CAT0003', 'BO0003', 20);
INSERT INTO Bolt VALUES ('CAT0004', 'BO0004', 40);
INSERT INTO Bolt VALUES ('CAT0005', 'BO0005', 10);
INSERT INTO Bolt VALUES ('CAT0006', 'BO0006', 20);
INSERT INTO Bolt VALUES ('CAT0001', 'BO0007', 30);
INSERT INTO Bolt VALUES ('CAT0007', 'BO0008', 20);


-- Hiep partial paid oc0001 tong 2000 tra 1000 mua CAT0001 BO0001
INSERT INTO ord VALUES ('OC0001', 2000, 'CC0001', '01-AUG-2022','EC0004','partial paid',1000);
INSERT INTO contain VALUES('CAT0001','BO0001','OC0001');

INSERT INTO ord VALUES ('OC0008', 120, 'CC0002', '24-DEC-2022','EC0004','ordered',120);
INSERT INTO contain VALUES('CAT0004','BO0004','OC0008');

INSERT INTO ord VALUES ('OC0004',1000, 'CC0003','11-SEP-2022','EC0006','full paid', 1000);
INSERT INTO contain VALUES('CAT0005','BO0005','OC0004');
INSERT INTO ord VALUES ('OC0005',2000, 'CC0003','11-SEP-2022','EC0006','new', 0);
INSERT INTO contain VALUES('CAT0007','BO0008','OC0005');

INSERT INTO ord VALUES ('OC0003',100, 'CC0004','01-SEP-2022','EC0006','partial paid', 20);
INSERT INTO contain VALUES('CAT0003','BO0003','OC0003');

INSERT INTO ord VALUES ('OC0002',4000, 'CC0005','29-AUG-2022','EC0005','partial paid', 1500);
INSERT INTO contain VALUES('CAT0002','BO0002','OC0002');

INSERT INTO ord VALUES ('OC0006',2000, 'CC0006','11-NOV-2022','EC0006','partial paid', 500);
INSERT INTO contain VALUES('CAT0006','BO0006','OC0006');

INSERT INTO ord VALUES ('OC0009',666666, 'CC0007','15-NOV-2022','EC0005','cancelled', 0);
INSERT INTO contain VALUES('CAT0001','BO0007','OC0009');
INSERT INTO cancel_order VALUES ('OC0009','CC0007','EC0005', 'Want to change another category of fabric');









-------2.2a increase purchase price of supplier 
CREATE PROCEDURE UpdateSilkprice
AS 
BEGIN 
UPDATE Fcategory
SET purchase_price= purchase_price*1.1
WHERE fabric_name='Silk' and fdate > TO_DATE('2020-09-01','YYYY-MM-DD');

END;
/
EXEC UpdateSilkprice;

--2.2b

--- get_order
SELECT * FROM Ord WHERE ord_code IN (SELECT ord_code FROM Contain WHERE (cat_code,bol_code)IN (SELECT  cat_code,bol_code from Bolt WHERE cat_code IN (SELECT cat_code from Fcategory where sup_code = (select sup_code from Supplier WHERE sname = 'Silk Agency'))));
/
---function total cau 2.2c
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
/
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
DBMS_OUTPUT.PUT_LINE(rec.cate_number||' '|| rec.sup_code);-- thu tu tang dan tu tren xuong
END LOOP;
END sort_cate;
/
SET SERVEROUTPUT ON;
EXEC sort_cate (TO_DATE('2018-09-01','YYYY-MM-DD'),TO_DATE('2023-09-01','YYYY-MM-DD'));

/

