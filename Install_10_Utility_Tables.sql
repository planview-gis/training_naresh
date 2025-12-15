/* ------------------------------------------------------------------
-- Modified By   : sjaffer
-- Modified Date : 2022-09-06 [yyyy-MM-dd]
-- Change History
-- 2022-06-30  - Initial table configuration 
-- 2022-08-23  - Added installInterface staging stable
-- 2022-09-06  - Add start_utc/end_utc to pipeline log 
-- 2022-09-29  - Added indices
-- 2023-07-24  - Cleaned up single line comments 
------------------------------------------------------------------ */

INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('GIS Utility Objects V1.0', GETDATE(), null);

/*-------------------------------------------------------------------	
-- installInterface Component Tables --------------------------------
-------------------------------------------------------------------*/
/*## Structure import data staging Table Schema*/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_struc_upsert_data_staging') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	CREATE TABLE @(db_path)pi_struc_upsert_data_staging ( 
		u_id bigint  identity(1,1),
		run_id bigint  NULL,
		batch_id bigint  NULL,
		src_rec_id bigint  NULL,
		active_ind varchar (5) NULL,
		allow_duplicates varchar (5) NULL,
		depth bigint  NULL,
		description varchar (50) NULL,
		structure_key varchar (4000) NULL,
		parent_key varchar (4000) NULL,
		predecessor_key varchar (4000) NULL,
		structure_name varchar (50) NULL,
		timezone_date datetime2  NULL,
		utc_date datetime2  DEFAULT GETUTCDATE()
	) 



/*-------------------------------------------------------------------	
-- Common Logging Tables --------------------------------------------
-------------------------------------------------------------------*/
/*## Pipeline Run Log Table Schema*/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_sl_pipeline_log') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	CREATE TABLE @(db_path)pi_sl_pipeline_log ( 
		run_id bigint  identity(1,1),
		component_name varchar (100) NULL,
		start_date datetime  DEFAULT GETDATE(),
		start_utc datetime2  DEFAULT GETUTCDATE(),
		end_date datetime  NULL,
		end_utc datetime2  NULL,
		machine_name varchar (200) DEFAULT @@SERVERNAME,
		database_name varchar (200) DEFAULT DB_NAME(),
		error_count int  NULL,
		warning_count int  NULL,
		total_count int  NULL,
		cms_process_id int  NULL,
		cms_error_id int  NULL,
		cms_transaction_id int  NULL,
		cms_summary_id int  NULL,
		run_uuid varchar (255) NULL
	) 

/*## Master Log Table Schema*/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_master_log') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	CREATE TABLE @(db_path)pi_master_log ( 
		master_log_id bigint  identity(1,1),
		src_rec_id bigint  NULL,
		run_id bigint  NULL,
		batch_id bigint  NULL,
		interface_name varchar (100) NULL,
		stoplight varchar (50) NULL,
		alert_type varchar (50) NULL,
		alert_id varchar (30) NULL,
		alert_class varchar (50) NULL,
		alert_description varchar (max) NULL,
		key1 varchar (200) NULL,
		key2 varchar (200) NULL,
		key3 varchar (200) NULL,
		file_name varchar (256) NULL,
		timezone_date datetime2  ,
		utc_date datetime2 DEFAULT GETUTCDATE()  ,
		summary_log varchar (200) NULL
	) 

/*## Batch Log Table Schema*/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_batch_log') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	CREATE TABLE @(db_path)pi_batch_log ( 
		batch_log_id bigint  identity(1,1),
		run_id bigint  ,
		batch_id bigint  ,
		src_rec_id bigint  ,
		status varchar (50) NULL,
		service_name varchar (100) NULL,
		key1 varchar (200) NULL,
		key2 varchar (200) NULL,
		key3 varchar (200) NULL,
		timezone_date datetime2  ,
		utc_date datetime2 DEFAULT GETUTCDATE()  ,
		summary_log varchar (200) NULL
	) 
  
/*## Debug Log Table Schema*/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_debug') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	CREATE TABLE @(db_path)pi_debug ( 
		log_id bigint  identity(1,1),
		run_id bigint  ,
		batch_id bigint  NULL,
		log_message varchar (4000) NULL,
		logger varchar (4000) NULL,
		api_request varchar (max) NULL,
		api_response varchar (max) ,
		snap_data varchar (max) NULL,
		key1 varchar (4000) NULL,
		key2 varchar (4000) NULL,
		key3 varchar (4000) NULL,
		file_name varchar (200) NULL,
		timezone_date datetime2  ,
		utc_date datetime2 DEFAULT GETUTCDATE()  ,
		ruuid varchar (4000) NULL
	) 

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='start_utc' AND lower(table_name)='pi_sl_pipeline_log')
BEGIN
ALTER TABLE @(db_path)pi_sl_pipeline_log ADD start_utc datetime2;
END
  
IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='end_utc' AND lower(table_name)='pi_sl_pipeline_log')
BEGIN
ALTER TABLE @(db_path)pi_sl_pipeline_log ADD end_utc datetime2;
END 

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='timezone_date' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD timezone_date datetime2;
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='utc_date' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD utc_date datetime2;
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='run_id' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD run_id bigint;
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='batch_id' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD batch_id bigint;
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='logger' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD logger varchar (200);
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE column_name='log_date' AND lower(table_name)='pi_debug')
BEGIN
ALTER TABLE @(db_path)pi_debug ADD log_date datetime2;
END
	
/*-------------------------------------------------------------------
-- Create indicies on component tables ------------------------------
-------------------------------------------------------------------*/
IF NOT EXISTS (SELECT NAME FROM SYSINDEXES WHERE LOWER(NAME)='pi_idx_master_log')
	CREATE NONCLUSTERED INDEX pi_idx_master_log ON @(db_path)pi_master_log
	(

		src_rec_id 	ASC,
		run_id 		ASC,
		batch_id	ASC
	)
	WITH (
		PAD_INDEX = OFF, 
		STATISTICS_NORECOMPUTE = OFF, 
		SORT_IN_TEMPDB = OFF, 
		DROP_EXISTING = OFF, 
		ONLINE = OFF, 
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON
	) 
	ON [PRIMARY];


IF NOT EXISTS (SELECT NAME FROM SYSINDEXES WHERE LOWER(NAME)='pi_idx_batch_log')
	CREATE NONCLUSTERED INDEX pi_idx_batch_log ON @(db_path)pi_batch_log
	(
		src_rec_id 	ASC,
		run_id 		ASC,
		batch_id	ASC
	)
	WITH (
		PAD_INDEX = OFF, 
		STATISTICS_NORECOMPUTE = OFF, 
		SORT_IN_TEMPDB = OFF, 
		DROP_EXISTING = OFF, 
		ONLINE = OFF, 
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON
	) 
	ON [PRIMARY];


IF NOT EXISTS (SELECT NAME FROM SYSINDEXES WHERE LOWER(NAME)='pi_idx_debug')
	CREATE NONCLUSTERED INDEX pi_idx_debug ON @(db_path)pi_debug
	(
		batch_id 	ASC,
		run_id 		ASC
	)
	WITH (
		PAD_INDEX = OFF, 
		STATISTICS_NORECOMPUTE = OFF, 
		SORT_IN_TEMPDB = OFF, 
		DROP_EXISTING = OFF, 
		ONLINE = OFF, 
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON
	) 
	ON [PRIMARY];
	
INSERT INTO @(db_path)pv_log(script, run_start, run_finish) values ('GIS Utility Objects V1.0', null, GETDATE() );
