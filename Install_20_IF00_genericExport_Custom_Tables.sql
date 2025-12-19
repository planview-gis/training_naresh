/* ------------------------------------------------------------------
-- Modified By   : sjaffer
-- Modified Date : 2023-09-06 [yyyy-MM-dd]
-- Change History:
-- 2023-01-23   - Initial table configuration 
-- 2023-09-06   - Cleaned up single line comments
------------------------------------------------------------------ */


IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'pi_abcd_if00export_staging') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE pi_abcd_if00export_staging (
    [RECORD] BIGINT NOT NULL IDENTITY(0,1),
    [RUN_ID] bigint,
    [SRC_REC_ID] bigint,
    CUTOFF_TO_BE VARCHAR(MAX),
    ON_OR_AFTER VARCHAR(MAX),
    BEFORE_OR_UNTIL VARCHAR(MAX),
    REF_TABLE VARCHAR(MAX) DEFAULT 'no',
    UPDT_ON [datetime] DEFAULT GETDATE()
);


/* Index for interface staging table */
CREATE NONCLUSTERED INDEX pi_idx_run_id ON pi_abcd_if00export_staging
(
	[run_id] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

