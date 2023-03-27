select *
From PortfolioProject..Covid_Deaths
where continent is not null
order by 1,2 



select *
From PortfolioProject..Covid_Vaccinations
order by 3,4

select location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
order by 1,2


-- Total cases VS Total Deaths

--This Indicates the likelihood of death if infected with covid in your country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where location like '%desh%'
and continent is not null
order by 1,2

-- Looking at Total cases VS Population
-- Demonstrates what percentage of the population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--where location like '%desh%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
Group by location, Population
order by PercentPopulationInfected desc

-- Showing countries with Highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S DISCUSS THINGS DOWN BY CONTINENT

select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is null
Group by location
order by TotalDeathCount desc

-- showing the continents with highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- ***Global Numbers***


select  date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
--where location like '%desh%'
where continent is not null
order by 1,2

--SELECT SUM(new_deaths)/ NULLIF(SUM(new_cases), 0) as result FROM PortfolioProject..Covid_Deaths
--Across the world total new cases and total deaths with death percentage

select date, SUM(new_cases)as total_new_cases, SUM(new_deaths)as total_new_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as newcases_DeathPercentage
From PortfolioProject..Covid_Deaths
--where location like '%desh%'
where continent is not null
group by date
order by 1,2


--Over All across the world death percentage

select SUM(new_cases)as total_new_cases, SUM(new_deaths)as total_new_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 
as newcases_DeathPercentage
From PortfolioProject..Covid_Deaths
--where location like '%desh%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by convert(nvarchar(255), dea.location), dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE
with popvsvac(continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by convert(nvarchar(255), dea.location), dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, ( RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from popvsvac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by convert(nvarchar(255), dea.location), dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*, ( RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by convert(nvarchar(255), dea.location), dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated