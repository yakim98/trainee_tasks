CREATE OR REPLACE PROCEDURE test2(param1 DATE, param2 TIMESTAMP, param3 DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'call test2(%, %, %)', param1, param2, param3;

end;
$$;

CREATE OR REPLACE FUNCTION test2_calls(start_date DATE)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    prev_date DATE := start_date;
BEGIN
    CREATE TEMP TABLE temp_table_test2(
        param1 DATE,
        param2 TIMESTAMP
    )
     ON COMMIT DROP;

    INSERT INTO temp_table_test2(param1, param2) VALUES ('2025-02-06','2025-02-12 09:38:25.999982000'),
                                                        ('2025-02-14','2025-02-14 16:17:14.095384000'),
                                                        ('2025-02-20','2025-02-21 08:41:53.643244000'),
                                                        ('2025-02-25','2025-03-11 15:52:28.575590000'),
                                                        ('2025-03-06','2025-03-13 15:35:21.729785000'),
                                                        ('2025-03-13','2025-03-13 16:32:27.178218000'),
                                                        ('2025-03-20','2025-03-26 08:35:19.585812000'),
                                                        ('2025-03-27','2025-03-28 07:23:03.611707000'),
                                                        ('2025-04-07','2025-04-08 18:57:03.804270000'),
                                                        ('2025-04-10','2025-04-15 11:19:51.275211000'),
                                                        ('2025-04-14','2025-04-15 14:34:32.097939000'),
                                                        ('2025-04-24','2025-04-24 14:41:48.705573000'),
                                                        ('2025-05-02','2025-05-08 11:05:44.640510000'),
                                                        ('2025-05-15','2025-05-21 10:00:08.361011000'),
                                                        ('2025-05-22','2025-05-28 08:07:06.096731000'),
                                                        ('2025-05-29','2025-05-30 10:01:45.906511000'),
                                                        ('2025-06-05','2025-06-09 09:22:04.668390000'),
                                                        ('2025-06-19','2025-07-03 08:27:40.115104000'),
                                                        ('2025-06-26','2025-07-03 09:15:38.292950000'),
                                                        ('2025-07-03','2025-07-07 10:53:30.915895000');
    FOR rec in SELECT * FROM temp_table_test2 ORDER BY param1
    LOOP
        CALL test2(rec.param1, rec.param2, prev_date);
        prev_date := rec.param1;
        end loop;
end;
$$;

SELECT test2_calls('2025-01-28')
