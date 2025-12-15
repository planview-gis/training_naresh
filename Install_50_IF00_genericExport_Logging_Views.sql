/* ------------------------------------------------------------------
-- Modified By   : Tanmay Sarkar
-- Modified Date : 2023-09-06 [yyyy-MM-dd]
-- Change History:
-- 2023-02-28  - Initial configuration 
-- 2023-09-06  - Cleaned up single line comments
------------------------------------------------------------------ */


INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('IF00_genericExport Views', GETDATE(), null);

BEGIN
/*Error log view*/
exec('CREATE OR ALTER VIEW pivw_abcd_if00_errors
AS
SELECT 
ml.RUN_ID, stg.SRC_REC_ID,ml.key1,ml.key2,
ml.stoplight, ml.alert_type, ml.alert_id, ml.alert_class, ml.alert_description
FROM pi_master_log ml
LEFT JOIN pi_abcd_if00export_staging stg
ON ml.RUN_ID = stg.RUN_ID AND ml.src_rec_id = stg.SRC_REC_ID 
WHERE
ml.alert_id IS NOT NULL  
AND ml.interface_name = ''IF00_genericExport''
'
)

/*Transaction log view: (used for service log)*/
exec('CREATE OR ALTER VIEW pivw_abcd_if00_transactions
AS
 with countError as (select count(alert_type) countErrorSrc, masLog.run_id, masLog.src_rec_id from pi_master_log masLog
where alert_type=''ERROR''
and masLog.interface_name = ''IF00_genericExport''
group by masLog.SRC_REC_ID, masLog.run_id)
SELECT distinct stg.RUN_ID, stg.SRC_REC_ID,''Data Exported'' [Transcation Description]
FROM pi_abcd_if00export_staging stg
LEFT JOIN countError on countError.run_id=stg.RUN_ID and countError.src_rec_id=stg.SRC_REC_ID
LEFT JOIN pi_master_log ml 
	ON ml.RUN_ID = stg.RUN_ID 
	AND ml.src_rec_id = stg.SRC_REC_ID 
	AND ml.interface_name = ''IF00_genericExport''
WHERE (countError.countErrorSrc=''0'' or countError.countErrorSrc is null) '
)
END

INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('IF00_genericExport Views', null, GETDATE() );
