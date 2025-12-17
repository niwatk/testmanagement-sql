/* 全テスト項目数を先に計算(説明フィールド内の表の行数を数えることで実装) */
SET @test_num= (SELECT
  SUM(
  (LENGTH('説明'->getView())
  -LENGTH(REPLACE('説明'->getView(), "<tr>", "")))/4 - 1)
FROM T2);

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

/* 日付毎の完了数を集計して表VTに格納 */
CREATE TABLE VT;
INSERT INTO VT
SELECT '日付', SUM('テスト消化数') AS 'テスト消化数'
FROM
(
SELECT DT.'日付'
  ,IIF(T2.'説明' IS NOT NULL,
   (LENGTH(T2.'説明')-LENGTH(REPLACE(T2.'説明', DT.'日付', "")))/10
   ,0) AS 'テスト消化数'
FROM DT
LEFT JOIN T2 ON T2.'説明' LIKE "%" + DT.'日付' + "%"
)
GROUP BY '日付';
  
/* 日付毎の残数を計算して表示 */
SELECT '日付'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL, 
   @test_num - (SELECT SUM('テスト消化数') FROM VT VT2 WHERE VT2.'日付' <= VT.'日付')) AS '残テスト数'
  ,IIF(DATEDIFF(day, '日付', "today") < 0, NULL, 
   'テスト消化数') AS 'テスト消化数'  
FROM VT
ORDER BY '日付'