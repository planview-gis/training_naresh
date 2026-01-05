/* ------------------------------------------------------------------
-- Modified By   : sjaffer
-- Modified Date : 2023-09-06 [yyyy-MM-dd]
-- Change History:
-- 2023-01-23   - Initial table configuration 
-- 2023-09-06   - Cleaned up single line comments
------------------------------------------------------------------ */


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'chw_test_if01fexport_staging') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE chw_test_if01fexport_staging (
    [RECORD] BIGINT NOT NULL IDENTITY(0,1),
    [RUN_ID] bigint,
    [SRC_REC_ID] bigint,
    stratajazz_id VARCHAR(MAX),
    location VARCHAR(MAX),
    project_budget DECIMAL(20,2),
    project_actual DECIMAL(20,2),
    project_obligation DECIMAL(20,2),
    REF_TABLE VARCHAR(MAX) DEFAULT 'no',
    UPDT_ON [datetime] DEFAULT GETDATE()
);


/* Index for interface staging table */
CREATE NONCLUSTERED INDEX pi_idx_run_id ON chw_test_if01fexport_staging
(
	[run_id] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]




