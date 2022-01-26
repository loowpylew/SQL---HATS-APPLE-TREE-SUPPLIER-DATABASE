SET SERVEROUTPUT ON
/
DECLARE
  r_cnt NUMBER := 0 ;
  TYPE t_names IS VARRAY(7) OF VARCHAR2(16);
  table_list t_names;
  
BEGIN

  table_list := t_names('A3_ORDER_ITEM', 'A3_ORDER_FORM', 'A3_BATCH', 'A3_TREE', 'A3_CUSTOMER', 'A3_VARIETY', 'A3_ROOTSTOCK');
  
  DBMS_OUTPUT.PUT_LINE('Dropping Tables ...');
  
  FOR element IN 1 .. table_list.count LOOP
    SELECT COUNT (*) INTO r_cnt FROM all_tables WHERE TABLE_NAME = table_list(element) AND owner = (SELECT sys_context ('userenv', 'current_schema') from dual);
    IF (r_cnt > 0)
    THEN
      EXECUTE IMMEDIATE 'DROP TABLE ' || table_list(element) || ' CASCADE CONSTRAINTS';
      DBMS_OUTPUT.PUT_LINE(' ... ' || table_list(element));
    END IF;
  END LOOP; 
  DBMS_OUTPUT.PUT_LINE('Tables dropped.');
  
  DBMS_OUTPUT.PUT_LINE('Create Tables ...');
  
  EXECUTE IMMEDIATE 'CREATE TABLE A3_Rootstock
                     (
                      Rootstocktype VARCHAR2(5)   PRIMARY KEY,
                      Tree_Size     VARCHAR2(16)  NOT NULL
                        CHECK (Tree_Size IN (''Extreme Dwarfing'', ''Dwarfing'', ''Semi-Vigourous'', ''Vigourous'', ''Very Vigourous'')),
                      Description   VARCHAR2(500)
                     )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Rootstock');
  
  EXECUTE IMMEDIATE 'CREATE TABLE A3_Variety
                     (
                      Name		VARCHAR2(30)	PRIMARY KEY,
                      Pollination_Group	NUMBER(1,0)	NOT NULL
                        CHECK ( Pollination_Group BETWEEN 1 AND 8 ),
                      Fruiting_Season	VARCHAR2(5)	NOT NULL
                        CHECK ( Fruiting_Season IN (''Early'', ''Mid'', ''Late'')),
                      Cooking		VARCHAR2(1)	NOT NULL
                        CHECK ( Cooking IN (''Y'', ''N'')),
                      Eating		VARCHAR2(1)	NOT NULL
                        CHECK ( Eating IN (''Y'', ''N'')),
                      Fruit_Size	VARCHAR2(6)	NOT NULL
                        CHECK ( Fruit_Size IN (''Large'', ''Medium'', ''Small'')),
                      Fruit_Colour	VARCHAR2(15)	NOT NULL,
                      Yield		VARCHAR2(8)	NOT NULL
                        CHECK ( Yield IN (''Heavy'', ''Moderate'', ''Light''))
                     )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Variety');
  
  EXECUTE IMMEDIATE 'CREATE TABLE A3_Tree
                     (
                      ID VARCHAR2(6) PRIMARY KEY,
                      Roottype VARCHAR2(5) NOT NULL REFERENCES A3_Rootstock(Rootstocktype),
                      Variety	VARCHAR2(30) NOT NULL REFERENCES A3_Variety(Name),
                      Pot_Size NUMBER(2,0) NOT NULL,
                      Price NUMBER(5,2) NOT NULL
                     )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Tree');

  EXECUTE IMMEDIATE 'CREATE TABLE A3_Customer
                                  (
                                   Customer_ID		VARCHAR2(6)	PRIMARY KEY,
                                   Family_Name		VARCHAR2(20)	NOT NULL,
                                   Given_Name		VARCHAR2(30)	NOT NULL,
                                   Address		VARCHAR2(120)	NOT NULL,
                                   Town			VARCHAR2(40)	NOT NULL,
                                   Phone_No		VARCHAR2(11),
                                   Register_Date	DATE		NOT NULL
                                  )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Tree');

  EXECUTE IMMEDIATE 'CREATE TABLE A3_Batch
                                  (
                                   Tree_ID		VARCHAR(6)	NOT NULL REFERENCES A3_Tree(ID),
                                   Date_Grafted		DATE		NOT NULL,		
                                   Plants_in_Batch	NUMBER(2,0)	NOT NULL,
                                     PRIMARY KEY (Tree_ID, Date_Grafted)
                                  )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Batch');

  EXECUTE IMMEDIATE 'CREATE TABLE A3_Order_Form
                                  (
                                   Customer_ID	VARCHAR2(6)	NOT NULL REFERENCES A3_Customer(Customer_ID),
                                   Order_ID	VARCHAR2(8)	PRIMARY KEY,
				   Order_Date	DATE
                                  )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Order_Form');

  EXECUTE IMMEDIATE 'CREATE TABLE A3_Order_Item
                                  (
                                   Tree_ID	VARCHAR(6)	NOT NULL,
                                   Date_Grafted	DATE		NOT NULL,		
                                   Order_ID     VARCHAR2(8)	NOT NULL REFERENCES A3_Order_Form(Order_ID),
    				   Quantity	NUMBER(2,0)     DEFAULT 1 NOT NULL,
                                     PRIMARY KEY (Tree_ID, Date_Grafted, Order_ID),
                                     FOREIGN KEY (Tree_ID, Date_Grafted) REFERENCES A3_Batch(Tree_ID, Date_Grafted)
                                  )';
  DBMS_OUTPUT.PUT_LINE(' ... A3_Order_Item');
  
  DBMS_OUTPUT.PUT_LINE('Tables Created');
  
END;
/
SET SERVEROUTPUT OFF