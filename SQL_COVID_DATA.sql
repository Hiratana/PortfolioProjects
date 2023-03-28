
--Showing TotalCases vs Population:
SELECT Location, Date, Population, Total_Cases, CAST(total_cases AS INT) / population*100 AS Percent_Population_Infected
FROM portfolioproject..coviddata
WHERE location = 'Bulgaria'
ORDER BY 1,2

------------------------------------------------
--Showing TotalCases vs TotalDeath and calculating DeathPercentage:
SELECT Location, Date, Population, Total_Cases, Total_Deaths, CAST(total_deaths AS FLOAT)/ total_cases*100 AS Death_Percentage
FROM portfolioproject..coviddata
WHERE location = 'Bulgaria'
ORDER BY 1,2

------------------------------------------------

--Showing Countries with Highest Infection Rate per Population:
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM portfolioproject..coviddata
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

------------------------------------------------

--Showing Countries with Highest Death Count Rate per Population:
SELECT Location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

------------------------------------------------

--Showing Continents with Highest Death Count Rate per Population:
SELECT Continent, MAX(CAST(Total_Deaths AS INT)) AS Total_Death_Count
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
  AND continent NOT IN ('income')
GROUP BY continent
ORDER BY Total_Death_Count DESC

------------------------------------------------

--Showing Global Numbers:
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(CAST(new_deaths AS FLOAT)) /SUM(new_cases)*100 END AS Death_Percentage
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

------------------------------------------------
--Showing Total Population vs Vaccinations:
--[0]
SELECT continent, Location, Date, Population, New_Vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
ORDER BY  1,2

--[1]
SELECT Continent, Location, Date, Population, new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Rolling_Vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
ORDER BY  location, date

-- USE CTE:
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations)
AS 
(
SELECT Continent, Location, Date, Population, New_Vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Rolling_Vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
)
SELECT*, (Rolling_Vaccinations/population)*100 AS Total_Vaccinations
FROM PopvsVac

------------------------------------------------

--TEMP TABLE:
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccination numeric, 
Rolling_Vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT Continent, Location, Date, Population, New_Vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Rolling_Vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL

SELECT*, (Rolling_Vaccinations/population)*100 AS Total_Vaccinations
FROM #PercentPopulationVaccinated

------------------------------------------------
--VIEW FOR VISULATION:
CREATE VIEW PercentPopulationVaccinated AS
SELECT Continent, Location, Date, Population, New_Vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS Rolling_Vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated