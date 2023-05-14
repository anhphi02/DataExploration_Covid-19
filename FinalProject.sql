
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--DELETE FROM PortfolioProject..CovidDeaths
--WHERE date >= '2023-05-10'
--ALTER Table PortfolioProject..CovidDeaths ALTER column total_cases float NULL
--ALTER Table PortfolioProject..CovidDeaths ALTER column total_deaths float NULL
-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contracting covid in Vietnam
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Vietnam'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Vietnam'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
Group by Location, population
ORDER BY InfectionRate DESC

-- Showing Countries with the Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/sum(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
Group by date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

-- Use CTE

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Use #TempTable

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null

SELECT*
FROM PercentPopulationVaccinated