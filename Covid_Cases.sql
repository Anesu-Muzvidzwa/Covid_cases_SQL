SELECT *
FROM Covid_Cases..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM Covid_Cases..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Cases..CovidDeaths
ORDER BY 1,2


--Investigating Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Cases..CovidDeaths

WHERE location like '%Zimbabwe%'
ORDER BY 1,2


-- countries with the highest infection rate compared to poplation
SELECT Location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100 )as PercentPopulation
FROM Covid_Cases..CovidDeaths
-- add a group by to avoid error
GROUP BY location, population
ORDER BY PercentPopulation DESC

--Now showing highest deat coutnt per population
SELECT Location, population,MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/total_cases)*100 )as PercentDeath
FROM Covid_Cases..CovidDeaths
-- add a group by to avoid error
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Explore by continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Cases..CovidDeaths
-- add a group by to avoid error
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT  date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid_Cases..CovidDeaths
 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
 

 --lookig at both tables
 SELECT *
 From Covid_Cases..CovidDeaths dea
 JOIN Covid_Cases..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--looking at when countries started vaccinating
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM Covid_Cases..CovidDeaths dea
 JOIN Covid_Cases..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--addig a column that adds up the new vaccination
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY dea.location, dea.Date) as RollingVaccinated
 FROM Covid_Cases..CovidDeaths dea
 JOIN Covid_Cases..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated

From Covid_Cases..CovidDeaths dea
Join Covid_Cases..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingVaccinated/Population)*100 
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated

From Covid_Cases..CovidDeaths dea
Join Covid_Cases..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *, (RollingVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated

From Covid_Cases..CovidDeaths dea
Join Covid_Cases..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
