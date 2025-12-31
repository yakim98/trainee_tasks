CREATE OR REPLACE PROCEDURE test_2(param1 DATE, param2 TIMESTAMP, param3 DATE)
    RETURNS VARCHAR LANGUAGE SQL AS $$ BEGIN RETURN 'OK'; END; $$;

CREATE OR REPLACE TEMPORARY TABLE call_params (
                                                  seq INT,
                                                  date1 DATE,
                                                  date2 TIMESTAMP_NTZ,
                                                  date3 DATE
);

INSERT INTO call_params VALUES
                            (1, '2025-02-06', '2025-02-12 09:38:25.999982000', '2025-01-28'),
                            (2, '2025-02-14', '2025-02-14 16:17:14.095384000', NULL),
                            (3, '2025-02-20', '2025-02-21 08:41:53.643244000', NULL),
                            (4, '2025-02-25', '2025-03-11 15:52:28.575590000', NULL),
                            (5, '2025-03-06', '2025-03-13 15:35:21.729785000', NULL),
                            (6, '2025-03-13', '2025-03-13 16:32:27.178218000', NULL),
                            (7, '2025-03-20', '2025-03-26 08:35:19.585812000', NULL),
                            (8, '2025-03-27', '2025-03-28 07:23:03.611707000', NULL),
                            (9, '2025-04-07', '2025-04-08 18:57:03.804270000', NULL),
                            (10, '2025-04-10', '2025-04-15 11:19:51.275211000', NULL),
                            (11, '2025-04-14', '2025-04-15 14:34:32.097939000', NULL),
                            (12, '2025-04-24', '2025-04-24 14:41:48.705573000', NULL),
                            (13, '2025-05-02', '2025-05-08 11:05:44.640510000', NULL),
                            (14, '2025-05-15', '2025-05-21 10:00:08.361011000', NULL),
                            (15, '2025-05-22', '2025-05-28 08:07:06.096731000', NULL),
                            (16, '2025-05-29', '2025-05-30 10:01:45.906511000', NULL),
                            (17, '2025-06-05', '2025-06-09 09:22:04.668390000', NULL),
                            (18, '2025-06-19', '2025-07-03 08:27:40.115104000', NULL),
                            (19, '2025-06-26', '2025-07-03 09:15:38.292950000', NULL),
                            (20, '2025-07-03', '2025-07-07 10:53:30.915895000', NULL);

CREATE OR REPLACE PROCEDURE test2_cycle()
    RETURNS VARCHAR
    LANGUAGE SQL
AS
$$
DECLARE
    v_seq INT;
    v_date1 DATE;
    v_date2 TIMESTAMP_NTZ;
    v_date3 DATE;
    prev_date1 DATE DEFAULT NULL;
    c1 CURSOR FOR SELECT seq, date1, date2, date3 FROM call_params ORDER BY seq;
BEGIN
    FOR record IN c1 DO
            v_seq := record.seq;
            v_date1 := record.date1;
            v_date2 := record.date2;
            v_date3 := record.date3;

            IF (v_seq = 1) THEN
                CALL test_2(v_date1, v_date2, v_date3);
            ELSE
                CALL test_2(v_date1, v_date2, prev_date1);
            END IF;

            prev_date1 := v_date1;
        END FOR;
    RETURN 'Completed';
END;
$$;

CALL test2_cycle();

CALL test2_calls('2025-01-28');
