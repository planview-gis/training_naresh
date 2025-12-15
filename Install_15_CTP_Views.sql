/* ------------------------------------------------------------------
-- Modified By   : sjaffer
-- Modified Date : 2023-03-26 [yyyy-MM-dd]
-- Change History:
-- 2022-03-06  - Initial configuration 
-- 2023-07-24  - Cleaned up single line comments 
-- 2024-01-29  - Removed 'db_path' from view script
-- 2024-03-26  - Correction for running run status
------------------------------------------------------------------ */


INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('GIS Logs2CMS Tile View V1.0', GETDATE(), null);

BEGIN
/*CTP Tile view:*/
exec('CREATE OR ALTER VIEW pivw_logs2cms_tile
AS
SELECT 
	pe.component_name AS interface_name,
	pe.run_id, 
	pe.start_date, 
	pe.end_date, 
	CASE 
		WHEN pe.end_date IS NULL 
		THEN CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, GETDATE())/3600)) + ''h '' + CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, GETDATE())/60)-FLOOR(DATEDIFF(second, pe.start_date, GETDATE())/3600)*60) + ''m '' + CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, GETDATE()))-FLOOR(DATEDIFF(second, pe.start_date, GETDATE())/60)*60) + ''s '' 
		ELSE CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, pe.end_date)/3600)) + ''h '' + CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, pe.end_date)/60)-FLOOR(DATEDIFF(second, pe.start_date, pe.end_date)/3600)*60) + ''m '' + CONVERT(VARCHAR(20),FLOOR(DATEDIFF(second, pe.start_date, pe.end_date))-FLOOR(DATEDIFF(second, pe.start_date, pe.end_date)/60)*60) + ''s '' 
	END AS duration, 
	ERROR_COUNT,
	WARNING_COUNT,
	CASE 
		WHEN pe.end_date IS NULL 
		AND NOT EXISTS (
			SELECT 1
			FROM pi_master_log ml
			WHERE (alert_type IN (''EXCEPTION'',''ERROR'') OR stoplight IN (''RED''))
			AND ml.run_id = pe.run_id
		) 
		THEN ''Running''
		WHEN cms_process_id IS NULL
		OR EXISTS (
			SELECT 1
			FROM pi_master_log ml
			WHERE alert_type IN (''EXCEPTION'') 
			AND ml.run_id = pe.run_id
		) 
		THEN ''Abort'' 
		WHEN ERROR_COUNT > 0 
		THEN ''Red'' 
		WHEN WARNING_COUNT > 0 AND ERROR_COUNT = 0 
		THEN ''Amber'' 
		ELSE ''Done'' 
	END AS execution_status,
	cms_process_id, 
	cms_transaction_id, 
	cms_error_id, 
	cms_summary_id,
	machine_name,
	database_name
FROM pi_sl_pipeline_log pe')

END

INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('GIS Logs2CMS Tile View V1.0', null, GETDATE() );
