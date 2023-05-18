/*
COVID Data exploration
SKILLS USED: Aggregate functions, Joins, CTEs, Temp table, Windows functions, Creating of views
*/

Select *
From CovidProject..CovidDeaths
Where continent is not null order by 3,4


-- Selecting Data 
Select Location, date, total_cases, new_cases,
total_deaths, population
From CovidProject..CovidDeaths
order by 1,2


-- Total cases vs Total Deaths
-- Shows likelihood of death on contracting COVID in the USA
Select Location, date, total_cases, total_deaths, (1.00*total_deaths/total_cases)*100 as Death_Percentage
From CovidProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Total cases vs population
-- Shows what percentage of population got COVID
Select Location, date, total_cases, population, total_cases, (1.00*total_cases/population)*100 as Death_Percentage
From CovidProject..CovidDeaths
where location like '%states%'
order by 1,2 


-- Countries with highest infection rates compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((1.00*total_cases/population))*100 
as PercentPopulationInfected
From CovidProject..CovidDeaths 
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing countries with Highest death count per population
Select Location, SUM(total_deaths) as Totaldeathcount
From CovidProject..CovidDeaths 
where continent is not null
Group by Location
order by Totaldeathcount desc




-- BREAKING DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select Continent, MAX(total_deaths) as TotalDeathCount 
From CovidProject..CovidDeaths 
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths
From CovidProject..CovidDeaths
where continent is not null
Order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopulationvsVaccinations (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL
)

Select *, (1.00*RollingPeopleVaccinated/population)*100
from PopulationvsVaccinations



-- Using a Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric,)


Insert into  #PercentPopulationVaccinated
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

Select *, (1.00*RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

GO



-- CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL



