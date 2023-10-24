USE portfolioProject

SELECT MAX (continent),
		total_deaths
		
FROM dbo.CovidDeaths
WHERE continent  = 'Asia' 
GROUP BY total_deaths

SELECT *
FROM dbo.CovidDeaths

SELECT *
FROM dbo.CovidDeaths
ORDER BY iso_code 

-- Read on order by clause tomorrow to refresh your memory. 

--looking at the total population vs vaccination. 


SELECT 
	dea.population,
	dea.location,
	dea.date,
	dea.continent,
	vac.new_vaccinations
FROM DBO.CovidDeaths AS dea
INNER JOIN DBO.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Display new vaccination per day.

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	-- SUM (CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location)
	SUM (CONVERT (INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
INNER JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USING PeopleVaccinated (popvsvac) as a column

WITH popvsvac (continent, location, date, population, new_vaccinations, peoplevaccinated)
AS
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	-- SUM (CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location)
	SUM (CONVERT (INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
INNER JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *,
	(peoplevaccinated/population)* 100 AS vaccinatedpercenetage
FROM popvsvac

-- Creating temporary table

CREATE TABLE #percentagepopulationvaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric, 
	new_vaccinations numeric,
	rollingpeoplevaccinated numeric
)

INSERT INTO #percentagepopulationvaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	-- SUM (CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location)
	SUM (CONVERT (INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
INNER JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *
FROM #percentagepopulationvaccinated


--Creating view to store data for later visualization 

CREATE View percentagepopulationvaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	-- SUM (CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location)
	SUM (CONVERT (INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM dbo.CovidDeaths AS dea
INNER JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


select *
from percentagepopulationvaccinated