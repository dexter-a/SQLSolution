
/*
5. Retrieve the Employee hierarchy under dbo.Staff. (6 pts)
	a. Select the staff’s full name (First Name + Last Name) plus the full name of its manager/s
	b. Display the top-level manager’s name first (comma separated)
	c. E.g. “Mireya Copeland” manager is “Fabiola Jackson“ so the result is “Fabiola Jackson, Mierya Copeland”
	d. Use only recursive CTE
*/


WITH rCTE AS (
	
	SELECT e.StaffId 
		, e.FirstName + ' ' + e.LastName AS FullName
		, 0 AS OrgLevel
		, CAST(e.FirstName + ' ' + e.LastName + ', ' 
			AS VARCHAR(500)) AS EmployeeHierarchy
	FROM dbo.Staff e
	WHERE ManagerId IS NULL

	UNION ALL

	SELECT e.StaffId
		, e.FirstName + ' ' + e.LastName AS FullName
		, r.OrgLevel + 1
		, CAST(r.EmployeeHierarchy 
				+ e.FirstName 
				+ ' ' + e.LastName 
				+ ', ' AS VARCHAR(500)) 
	FROM dbo.Staff e
	INNER JOIN rCTE AS r
		ON (e.ManagerId = r.StaffId)
)
SELECT r.StaffId
	, r.FullName
	, LEFT(r.EmployeeHierarchy,LEN(r.EmployeeHierarchy) - 1) AS EmployeeHierarchy
FROM rCTE r
ORDER BY r.StaffId
