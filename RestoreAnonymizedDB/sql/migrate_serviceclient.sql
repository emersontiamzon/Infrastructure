DECLARE @tenant VARCHAR(200) = $(tenant) 

IF (@tenant IN ('Acture'))
BEGIN
	INSERT [dbo].[ServiceClient] (
		[Id]
		,[Name]
		,[ClientSecret]
		,[Salt]
		,[IPAccess]
		,[TokenLifetimeSeconds]
		,[StartDate]
		,[EndDate]
		)
	VALUES (
		N'5519a583-abc7-4f96-8b28-907122134b90'
		,N'KEES'
		,N'QiO7LCFQcPYp5xaFhOxqCCO5NoDSFU5IK4+IACjVhM8='
		,N'ux2s2Ft2KBd/6CeqUHv9PVZwiZvGxUoOvJOsu60OdGw='
		,N'52.174.25.235;52.174.18.24;85.146.239.38;87.213.34.174'
		,3600
		,CAST(N'2019-11-27T13:19:20.4900000' AS DATETIME2)
		,NULL
		)

	INSERT [dbo].[ServiceClientAccess] (
		[ServiceClientId]
		,[AccessArea]
		)
	VALUES (
		N'5519a583-abc7-4f96-8b28-907122134b90'
		,N'svc.zw.casemanagement'
		)
END
