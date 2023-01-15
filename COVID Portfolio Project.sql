Select *
From dbo.CovidDeaths
order by 3, 4

--Select *
--From dbo.CovidVaccinations
--order by 3, 4

--choose the column that we want to analyze
--sort by column 1,2 (location, date)

Select location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths .. total death percentage

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From dbo.CovidDeaths
order by 1,2

--Total death percentage in USA
-- show likelihood of dying if you contract covid in USA

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From dbo.CovidDeaths
Where location LIKE '%state%'
order by 1,2

--Total death percentage in Indonesia

--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
--From dbo.CovidDeaths
--Where location = 'Indonesia'
--order by 1,2



--Looking at Total cases vs population
--show what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From dbo.CovidDeaths
Where location LIKE '%state%'
order by 1,2


--Looking at countries that gor highest covid rate compare to its population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
From dbo.CovidDeaths
group by location, population
order by 4 DESC


--Showing countries with highest death count per population

Select location, MAX(total_deaths) AS TotalDeathCount
from dbo.CovidDeaths
group by location
order by 2 DESC

--Total_death need to change into numeric
--Look into dbo.CovidDeaths - Column - you can see that total_deaths is in nvarchar

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from dbo.CovidDeaths
group by location
order by 2 DESC

--in the location column we can see : loc that is not country such as world, europa, etc 

Select *
From dbo.CovidDeaths
where continent is not null
order by 3, 4

--where continent is not null, add this statement for every scrip

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by 2 DESC


--showing highest total death count by continent

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 DESC

-- it's seem that the total death count is not the correct number, we can see the total death in north america is the same with USA and it not include canada

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from dbo.CovidDeaths
where continent is null
group by location
order by 2 DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 DESC


--GLOBAL NUMBERS

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--Where location LIKE '%state%'
where continent is not null
group by date
order by 1,2

--Showing total cases global

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--Where location LIKE '%state%'
where continent is not null
--group by date
order by 1,2


--Join between 2 tables

Select *
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--showing Rolling people vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	  dea.date) AS RollingPeopleVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	  dea.date) AS RollingPeopleVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *
From PopvsVac

--The calculation using PopvsVac

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	  dea.date) AS RollingPeopleVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	  dea.date) AS RollingPeopleVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating views to store data for visializations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	  dea.date) AS RollingPeopleVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select*
From PercentPopulationVaccinated
