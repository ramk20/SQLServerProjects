-- construct SQL to drop unused indexes
SELECT 'DROP INDEX ' + schema_name(objects.schema_id) + '.' + OBJECT_NAME(dm_db_index_usage_stats.object_id) + '.' + indexes.name AS Drop_Index
	,user_seeks
	,user_scans
	,user_lookups
	,user_updates
FROM sys.dm_db_index_usage_stats
INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id
	AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
WHERE indexes.is_primary_key = 0 -- exclude PKs
	AND indexes.is_unique = 0 -- exclude unique keys
	AND dm_db_index_usage_stats.user_updates <> 0 -- used only in updates which is probably not optimum
	AND dm_db_index_usage_stats.user_lookups = 0 
	AND dm_db_index_usage_stats.user_seeks = 0
	AND dm_db_index_usage_stats.user_scans = 0
	AND schema_name(objects.schema_id) = 'Sales'
	AND objects.name = 'SalesOrderDetail'
ORDER BY dm_db_index_usage_stats.user_updates DESC