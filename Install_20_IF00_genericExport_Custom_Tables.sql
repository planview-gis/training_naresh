/* ------------------------------------------------------------------
-- Modified By   : sjaffer
-- Modified Date : 2023-09-06 [yyyy-MM-dd]
-- Change History:
-- 2023-01-23   - Initial table configuration 
-- 2023-09-06   - Cleaned up single line comments
------------------------------------------------------------------ */


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'@(db_path)pi_abcd_if00export_staging') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE @(db_path)pi_abcd_if00export_staging (
	rec_id BIGINT  NOT NULL IDENTITY(1,1),
	SRC_REC_ID 	[bigint] NULL,
	[run_id] [bigint] NULL,
	[file_name]  [varchar](200),
	[src_row] [varchar](max) NULL,
	[log_date] [datetime] NULL
)


/* Index for interface staging table */
CREATE NONCLUSTERED INDEX pi_idx_run_id ON @(db_path)pi_abcd_if00export_staging
(
	[run_id] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
