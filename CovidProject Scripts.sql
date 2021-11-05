Select *
	From CovidProject..CovidDeaths
	where continent is not null
	order by 3,4

--Select *
--	From CovidProject..CovidVaccinations
--	order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
	From CovidProject..CovidDeaths
	order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From CovidProject..CovidDeaths
	Where location like '%states%'
	order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as CasePercentage
	From CovidProject..CovidDeaths
	Where location like '%states%'
	order by 1,2

-- Looking at countries with Higest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
	From CovidProject..CovidDeaths
	--Where location like '%states%'
	Group by Location, Population
	order by CasePercentage desc

-- Showing Countries with Highest Mortality rate per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group by Location
	order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
	--Where location like '%states%'
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc

-- Global Numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
	From CovidProject..CovidDeaths
	Where continent is not null
	Group by date
	order by 1,2


-- Most Recent Total Death Percentage 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
	From CovidProject..CovidDeaths
	Where continent is not null
	order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
		From CovidProject..CovidDeaths dea
		Join CovidProject..CovidVaccinations vac
			On dea.location = vac.location
			and dea.date = vac.date
		Where dea.continent is not null
		order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

-- Finding Rolling Vaccination Percentage

Select *, (RollingVaccinations/Population)*100 as RollingVaccinationPercentage
From PopvsVac


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated