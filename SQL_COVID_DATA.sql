
--Showing TotalCases vs Population:
SELECT location, date, population, total_cases, CAST(total_cases AS INT) / population*100 AS PercentPopulationInfected
FROM portfolioproject..coviddata
WHERE location = 'Bulgaria'
ORDER BY 1,2

------------------------------------------------
--Showing TotalCases vs TotalDeath and calculating DeathPercentage:
SELECT location, date, population, total_cases, total_deaths, CAST(total_deaths AS FLOAT)/ total_cases*100 AS DeathPercentage
FROM portfolioproject..coviddata
WHERE location = 'Bulgaria'
ORDER BY 1,2

------------------------------------------------

--Showing Countries with Highest Infection Rate per Population:
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM portfolioproject..coviddata
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

------------------------------------------------

--Showing Countries with Highest Death Count Rate per Population:
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

------------------------------------------------

--Showing Continents with Highest Death Count Rate per Population:
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
  AND continent NOT IN ('income')
GROUP BY continent
ORDER BY TotalDeathCount DESC

------------------------------------------------

--Showing Global Numbers:
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(CAST(new_deaths AS FLOAT)) /SUM(new_cases)*100 END AS DeathPercentage
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

------------------------------------------------
--Showing Total Population vs Vaccinations:
--[0]
SELECT continent, location, date, population, new_vaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
ORDER BY  1,2

--[1]
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingVaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
ORDER BY  location, date

-- USE CTE:
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS 
(
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingVaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL
)
SELECT*, (RollingVaccinations/population)*100 AS TotalVaccinations
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
RollingVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingVaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL

SELECT*, (RollingVaccinations/population)*100 AS TotalVaccinations
FROM #PercentPopulationVaccinated

------------------------------------------------
--VIEW FOR VISULATION:
CREATE VIEW PercentPopulationVaccinated AS
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingVaccinations
FROM portfolioproject..coviddata
WHERE continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated