CREATE SEQUENCE IF NOT EXISTS CURS_SEQ INCREMENT 1 START 1 NOCACHE CYCLE;

CREATE TABLE IF NOT EXISTS CURS (
		  ID INTEGER NOT NULL PRIMARY KEY,
		  CURS_DATE DATE NOT NULL,
		  CURR_CODE VARCHAR(3) NOT NULL,
		  RATE DECIMAL(22,6)
          );

CREATE UNIQUE INDEX IF NOT EXISTS UK_CURS ON CURS (CURS_DATE, CURR_CODE);

CREATE VIEW IF NOT EXISTS CURS_AVG_YEAR (PART_DATE, CURR_CODE, AVG_RATE)
AS
  SELECT kk.PART_DATE,
         kk.CURR_CODE,
         AVG(kk.RATE) AS AVG_RATE
  FROM (
	   SELECT
	         TO_CHAR(k.CURS_DATE, '%Y') AS PART_DATE,
	         k.CURR_CODE,
	         k.RATE
	   FROM CURS k
       ) kk
  GROUP BY
	   kk.PART_DATE,
	   kk.CURR_CODE;

CREATE VIEW IF NOT EXISTS CURS_AVG (PART_DATE, CURR_CODE, AVG_RATE)
AS
	SELECT
	    f.PART_DATE AS PART_DATE,
	    f.CURR_CODE AS CURR_CODE,
	    AVG(f.AVG_RATE) AS AVG_RATE
	FROM
	    (
	    SELECT
	        TO_CHAR(k.CURS_DATE, '%m-%d') AS PART_DATE,
	        k.CURR_CODE,
	        (k.RATE / a.AVG_RATE)* 100 AS AVG_RATE
	    FROM CURS k
	    INNER JOIN CURS_AVG_YEAR a ON a.PART_DATE = TO_CHAR(k.CURS_DATE, '%Y') AND a.CURR_CODE = k.CURR_CODE
	    ) f
	GROUP BY
	    f.PART_DATE,
	    f.CURR_CODE;


CREATE VIEW IF NOT EXISTS CURS_REPORT (CURS_DATE, CURR_CODE, RATE, AVG_RATE)
AS
	SELECT
	    k.CURS_DATE,
	    k.CURR_CODE,
	    k.RATE,
	    a.AVG_RATE AS AVG_RATE
	FROM CURS k
	INNER JOIN CURS_AVG a ON a.PART_DATE = TO_CHAR(k.CURS_DATE, '%m-%d') AND a.CURR_CODE = k.CURR_CODE
	WHERE TO_CHAR(k.CURS_DATE, '%Y') IN ( SELECT TO_CHAR(MAX(kk.CURS_DATE), '%Y') FROM CURS kk) AND a.AVG_RATE <= 100;
