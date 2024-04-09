-- Viewing data

SELECT *
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
order by 3,4

SELECT *
From [Portfolio Project].dbo.CovidVaccinations
order by 3, 4

-- Select data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
Order By 1, 2


-- Looking at the Total Cases vs. Total Deaths
-- Shows the likelihood of dying if one contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
Order By 1, 2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
Order By 1, 2


-- Looking at countries with the highest covid rate vs population
Select Location, population, max(total_cases) as HighestCaseCount, 
	max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
Group by location, population
Order By PercentPopulationInfected desc

-- Looking at countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathsCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by location
Order By TotalDeathsCount desc

-- Breaking down by continent 
Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by continent
Order By TotalDeathsCount desc


-- Showing continents with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by continent
Order By TotalDeathsCount desc


-- Seeing total cases, deaths, and death percentage globally by each date

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group By date
Order By 1,2

-- Removing date to see total cases, total deaths, and death percentage overall.
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Order By 1,2


-- Join
Select * 
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs. vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVacCount,
	(RollingVacCount/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- Use CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingVac)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
	as RollingVac
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null)

Select *, (RollingVac/population)*100 
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
	as RollingVac
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVac/population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
	as RollingVac
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
