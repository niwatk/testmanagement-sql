/* 期間分の日付値を表DTに格納 */
SET @date1 = (SELECT MIN('開始日') FROM T1);
SET @date2 = (SELECT MAX('終了日') FROM T1);
SET @cnt = DATEDIFF(day, @date1, @date2);
CREATE TABLE DT;
WHILE @cnt >= 0
BEGIN
SET @cnt = @cnt - 1;
INSERT INTO DT('日付') VALUES (FORMATDATE(@date1,"yy/mm/dd"));
SET @date1 = DATEADD(day, 1, @date1);
END;

/* バグ票の集計 */
SELECT '日付'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL,
    (SELECT COUNT(*) FROM T2 WHERE T2.'起票日' <= DT.'日付')) AS '累積起票数'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL,
    (SELECT COUNT(*) FROM T2 WHERE T2.'完了日' <= DT.'日付')) AS '累積完了数'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL,
    (SELECT COUNT(*) FROM T2 WHERE T2.'起票日' = DT.'日付')) AS '起票数'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL,
    (SELECT COUNT(*) FROM T2 WHERE T2.'完了日' = DT.'日付')) AS '完了数'
FROM DT;
