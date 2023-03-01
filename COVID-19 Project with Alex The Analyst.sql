--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

----SELECT *
----FROM CovidVaccinations
----ORDER BY 3,4 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


--COVID DEATHS!!!

-- Total cases VS Total deaths
-- The percentages shows the likelihood of dying if you contract the virus

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


--Total cases VS Population
-- This shows the percentage of population that got COVID.

SELECT location, date, population, total_cases, (total_cases/population)*100 as HighestInfectedCount
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


-- Countries with Highest Inection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT location, continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null --AND location LIKE '%Nigeria%'
GROUP BY location, continent
ORDER BY TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENTS

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null --AND location LIKE '%Nigeria%'
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2


--COVID VACCINATIONS!!!

SELECT *
FROM CovidVaccinations 

--Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Percentage of People Vaccinated In a Country Using CTE's

With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Percentage of People Vaccinated In a Country Using Temp Tables

Drop Table if exists #PercentPopulationVaccinated --You use this when you want to make a change to your Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating a view for later visulization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null