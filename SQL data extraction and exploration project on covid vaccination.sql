Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that weare going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group by continent, population
order by InfectionRate desc

--showing countries with highest death count per population
--use "cast" to change data type of column to integer
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--breaking down by continent


--showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--death rate over time

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group by date
order by 1,2



--join 2 tables together

-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--trailing numbers/rolling counts
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (Continent, Location, Data, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--creating view to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select*
From PercentPopulationVaccinated




--Tableau visualization:

-- tableau table 1 -- global number 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null
--Group by date
order by 1,2



-- tableau table 2 -- death count by continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCounts
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCounts desc



-- tableau table 3 -- infection rate
Select Location, Population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
Group by Location, Population
order by InfectionRate desc



-- tableau table 4 -- infection rate vs time
Select Location, Population, date, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
Group by Location, Population, date
order by InfectionRate desc