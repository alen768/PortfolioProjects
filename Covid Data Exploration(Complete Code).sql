SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Selecting Data that is going to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%' AND continent is not null
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%India%'
ORDER BY 1,2

--Countries with Highest Covid cases with respect to it's population
SELECT location, population, MAX(total_cases) AS TotalCaseCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%India%'
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC

-- Countries with Highest Covid Deaths with respect to population
SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%India%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Sorting by Continent

--Continent with Highest Covid Deaths with respect to population
SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%India%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--WORLD data
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



--Using CTE

With PopulvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinated/Population)*100 FROM  PopulvsVac


-- Temporary Table

DROP TABLE if exists #PercentageofPopulationVaccinated
CREATE TABLE #PercentageofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)


Insert into #PercentageofPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (PeopleVaccinated/Population)*100 FROM  #PercentageofPopulationVaccinated

-- Creating  View for later visualization

CREATE VIEW PercentageofPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * FROM PercentageofPopulationVaccinated