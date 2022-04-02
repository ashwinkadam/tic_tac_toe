set serveroutput on;


--DROP TABLE  TIC_TAC_TOE;
--DROP TABLE TIC_TAC_TOE_TRACKER;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--CREATING THE TIC TAC TOE TABLE 
CREATE TABLE TIC_TAC_TOE(
ROW_NUM NUMBER(1) ,
COL1 VARCHAR(1) CHECK(COL1 IN ('X','0')),
COL2 VARCHAR(1) CHECK(COL2 IN ('X','0')),
COL3 VARCHAR(1) CHECK(COL3 IN ('X','0'))
);

--CREATING A TRACKER TABLE 
CREATE TABLE TIC_TAC_TOE_TRACKER(
SYMBOL_CHK VARCHAR(1));

--INSERTING A DUMMY VALUE IN TRACKER TABLE
INSERT INTO TIC_TAC_TOE_TRACKER(SYMBOL_CHK) VALUES(NULL);


--CREATING THE EMPTY BOARD
INSERT INTO TIC_TAC_TOE(COL1,COL2,COL3) VALUES(NULL,NULL,NULL);
INSERT INTO TIC_TAC_TOE(COL1,COL2,COL3) VALUES(NULL,NULL,NULL);
INSERT INTO TIC_TAC_TOE(COL1,COL2,COL3) VALUES(NULL,NULL,NULL);
COMMIT;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--STORED PROCEDURE TO SET/RESET GAME
CREATE OR REPLACE PROCEDURE SET_RESET_GAME AS 

BEGIN 
--DELETING THE RECORDS
DELETE FROM TIC_TAC_TOE;
DELETE FROM TIC_TAC_TOE_TRACKER;

--INITIALIZING THE BOARD
FOR I in 1..3 LOOP
INSERT INTO TIC_TAC_TOE VALUES (I,NULL,NULL,NULL);
END LOOP;

INSERT INTO TIC_TAC_TOE_TRACKER VALUES (NULL);
COMMIT;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--STORED PROCEDURE TO PRINT THE GAME BOARD
CREATE OR REPLACE PROCEDURE PRINT_GAME AS

A VARCHAR(1);
B VARCHAR(1);
C VARCHAR(1);


BEGIN
  FOR I in (SELECT * FROM TIC_TAC_TOE) LOOP
    IF I.COL1 IS  NULL THEN 
        A := '_';
    ELSE
        A:= I.COL1;
    END IF;
    
    IF I.COL2 IS NULL THEN 
        B := '_';
    ELSE
        B:= I.COL2;
    END IF;

    IF I.COL3 IS NULL THEN 
        C := '_';
    ELSE
        C:= I.COL3;
    END IF;
    
    dbms_output.put_line(I.ROW_NUM || '|' || A || '|' || B ||  '|' || C || '|');
  END LOOP; 
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---TRIGGER TO CHECK EACH MOVE AND IDENTIFY THE GAME STATUS
CREATE OR REPLACE TRIGGER MOVE_CHECK AFTER UPDATE ON TIC_TAC_TOE  FOR EACH ROW 
BEGIN 
-- THE BELOW CONDITION IS CHECKING FOLLOWING CONDITIONS
--IF OLD VALUE IS NULL -- UNPLAYED SPOT
--IF NEW VALUE IS NULL -- NOT ACCEPTABLE
--OVERWRITE -- NOT ACCEPTALE

IF  (:OLD.COL1 IS NULL AND :NEW.COL1 IS NOT NULL) OR 
    (:OLD.COL2 IS NULL AND :NEW.COL2 IS NOT NULL) OR 
    (:OLD.COL3 IS NULL AND :NEW.COL3 IS NOT NULL) THEN
    
    DBMS_OUTPUT.PUT_LINE('');
    --DBMS_OUTPUT.PUT_LINE(:OLD.COL1);
    --DBMS_OUTPUT.PUT_LINE(:NEW.COL1);
    
ELSE
-- (-20010) IS USER DEFINED ERROR
    raise_application_error(-20010,'EITHER UPDATING WITH NULL OR THE PLACE IS ALREADY FILLED WITH OTHER VALUE');
END IF;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRACKER_CHECK AFTER UPDATE ON TIC_TAC_TOE_TRACKER FOR EACH ROW
BEGIN

--CHECKING IF  THE PLAYERS ARE PLAYING ALTERNATELY
IF (:OLD.SYMBOL_CHK IS NULL OR :OLD.SYMBOL_CHK <> :NEW.SYMBOL_CHK) THEN 
    --DBMS_OUTPUT.PUT_LINE('PLAYERS ARE PLAYING ALTERNATELY');
    DBMS_OUTPUT.PUT_LINE('');
ELSE
    raise_application_error(-20010,'SAME PLAYER IS PLAYING IMMEDIATELY');
END IF;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--STORRED PROCEDURE TO PLAY THE GAME
CREATE OR REPLACE PROCEDURE PLAY_GAME (SYMBOL IN VARCHAR, COL_NUM IN NUMBER, R_NUM IN NUMBER) AS 

A1 VARCHAR(1);
A2 VARCHAR(1);
A3 VARCHAR(1);
B1 VARCHAR(1);
B2 VARCHAR(1);
B3 VARCHAR(1);
C1 VARCHAR(1);
C2 VARCHAR(1);
C3 VARCHAR(1);

BEGIN

---UPDATING THE MAIN TABLE 
    IF COL_NUM = 1 THEN 
    UPDATE  TIC_TAC_TOE SET COL1 = SYMBOL WHERE ROW_NUM = R_NUM;
    ELSIF COL_NUM = 2 THEN
    UPDATE  TIC_TAC_TOE SET COL2 = SYMBOL WHERE ROW_NUM = R_NUM;
    ELSIF COL_NUM = 3 THEN
    UPDATE  TIC_TAC_TOE SET COL3 = SYMBOL WHERE ROW_NUM = R_NUM;
    END IF;
    
---AFTER THIS UPDATED IT WILL GO TO THE MOVE CHECK TRIGGER 

    UPDATE TIC_TAC_TOE_TRACKER SET SYMBOL_CHK = SYMBOL;
 
---AFTER THIS UPDATED IT WILL GO TO THE TRACKER TRIGGER  


----ASSIGN ALL VARIABLES
    SELECT COL1 INTO A1 FROM TIC_TAC_TOE  WHERE ROW_NUM = 1;
    SELECT COL2 INTO A2 FROM TIC_TAC_TOE  WHERE ROW_NUM = 1;
    SELECT COL3 INTO A3 FROM TIC_TAC_TOE  WHERE ROW_NUM = 1;
    ----2ND ROW ------
    SELECT COL1 INTO B1 FROM TIC_TAC_TOE  WHERE ROW_NUM = 2;
    SELECT COL2 INTO B2 FROM TIC_TAC_TOE  WHERE ROW_NUM = 2;
    SELECT COL3 INTO B3 FROM TIC_TAC_TOE  WHERE ROW_NUM = 2;
    ----3RD ROW----
    SELECT COL1 INTO C1 FROM TIC_TAC_TOE  WHERE ROW_NUM = 3;
    SELECT COL2 INTO C2 FROM TIC_TAC_TOE  WHERE ROW_NUM = 3;
    SELECT COL3 INTO C3 FROM TIC_TAC_TOE  WHERE ROW_NUM = 3;
    
        --ROWS WIN CHECK
    IF (A1 IS NOT NULL AND A2 IS NOT NULL AND A3 IS NOT NULL) THEN
        IF (A1 = A2) AND (A2 = A3) THEN 
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A1 || ' WON BY FIRST ROW STRIKE');
        END IF;
        
    ELSIF (B1 IS NOT NULL AND B2 IS NOT NULL AND B3 IS NOT NULL) THEN
        IF (B1 = B2) AND (B2 = B3) THEN 
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || B1 || ' WON BY SECOND ROW STRIKE');
        END IF;
        
    ELSIF (C1 IS NOT NULL AND C2 IS NOT NULL AND C3 IS NOT NULL) THEN
        IF (C1 = C2) AND (C2 = C3) THEN 
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || C1 || ' WON BY THIRD ROW STRIKE');
        END IF;
        
    --COLUMN WIN CHECK
    ELSIF (A1 IS NOT NULL AND B1 IS NOT NULL AND C1 IS NOT NULL) THEN
        IF (A1 = B1) AND (B1 = C1) THEN
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A1 || ' WON BY FIRST COLUMN STRIKE');
        END IF;
        
    ELSIF (A2 IS NOT NULL AND B2 IS NOT NULL AND C2 IS NOT NULL) THEN
        IF (A2 = B2) AND (B2 = C2) THEN
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A2 || ' WON BY SECOND COLUMN STRIKE');
        END IF;
        
    ELSIF (A3 IS NOT NULL AND B3 IS NOT NULL AND C3 IS NOT NULL) THEN
        IF (A3 = B3) AND (B3 = C3) THEN
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A3 || ' WON BY THIRD COLUMN STRIKE');
        END IF;
        
    --NO STRIKE, GAME STILL ON
    ELSIF (A1 IS NULL OR A2 IS NULL OR A3 IS NULL OR B1 IS NULL OR B2 IS NULL OR B3 IS NULL OR C1 IS NULL OR C2 IS NULL OR C3 IS NULL) THEN
    DBMS_OUTPUT.PUT_LINE('GAME IS STILL ON');
    
    --NO STRIKE, TIE
    ELSE 
    DBMS_OUTPUT.PUT_LINE('TOUGH FIGHT GAME TIED');
    END IF;

    --DIAGONAL WIN CHECK
    IF (A1 IS NOT NULL AND B2 IS NOT NULL AND C3 IS NOT NULL) THEN
        IF (A1 = B2) AND (B2 = C3) THEN
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A1 || ' WON BY FIRST DIAGONAL STRIKE');
        END IF;
    
    ELSIF (A3 IS NOT NULL AND B2 IS NOT NULL AND C1 IS NOT NULL) THEN
        IF (A3 = B2) AND (B2 = C1) THEN 
        DBMS_OUTPUT.PUT_LINE('PLAYER WITH ' || A3 || ' WON BY SECOND DIAGONAL STRIKE');
        END IF;
    END IF;
        
     PRINT_GAME();
     COMMIT;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--TEST CASE (COLUM STRIKE)
EXECUTE SET_RESET_GAME;
EXECUTE PLAY_GAME('X',1,1);
EXECUTE PLAY_GAME('0',2,2);
EXECUTE PLAY_GAME('X',2,1);
EXECUTE PLAY_GAME('0',3,3);
EXECUTE PLAY_GAME('X',3,1);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--TEST CASE (ROW STRIKE)
EXECUTE SET_RESET_GAME;
EXECUTE PLAY_GAME('X',1,1);
EXECUTE PLAY_GAME('0',2,2);
EXECUTE PLAY_GAME('X',1,2);
EXECUTE PLAY_GAME('0',3,1);
EXECUTE PLAY_GAME('X',1,3);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--TEST CASE (DIAGONAL STRIKE)
EXECUTE SET_RESET_GAME;
EXECUTE PLAY_GAME('X',1,1);
EXECUTE PLAY_GAME('0',2,1);
EXECUTE PLAY_GAME('X',2,2);
EXECUTE PLAY_GAME('0',2,3);
EXECUTE PLAY_GAME('X',3,3);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--TEST CASE WHEN TRYING TO PASS NULL (IT WILL THROW ERROR - 'EITHER UPDATING WITH NULL OR THE PLACE IS ALREADY FILLED WITH OTHER VALUE')
EXECUTE SET_RESET_GAME;
EXECUTE PLAY_GAME(NULL,1,1);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--TEST CASE WHEN UPDATING ALREADY FILLED PLACED WITH "X" OR "Y" (IT WILL THROW ERROR - 'EITHER UPDATING WITH NULL OR THE PLACE IS ALREADY FILLED WITH OTHER VALUE')
EXECUTE PLAY_GAME('X',1,1);
EXECUTE PLAY_GAME('0',1,1);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



--SELECT * FROM TIC_TAC_TOE_TRACKER;
--SELECT * FROM TIC_TAC_TOE;
