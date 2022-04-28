/*
Queries used for POWERBI Project
*/

SELECT @@SERVERNAME          -- to get server name,,which can be used in Powerbi while importing query

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) as DeathPercentage
From Portfolioprojects..covid_deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select Continent,location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioprojects..covid_deaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
Group by location,continent
order by TotalDeathCount desc


select distinct(location) from Portfolioprojects..covid_deaths$
Where continent is not null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')


-- 3. To know cases vs population of countries

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject1..covid_deaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Cases vs Population : Datewise


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject1..covid_deaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected asc


--5. General Queries to get fully vaccinated vs total infected  count, Percentage by Joining two tables

 select dea.continent,CONVERT(int,(vac.people_fully_vaccinated))  from Portfolioprojects..covid_vaccinations$ vac  join Portfolioprojects..covid_deaths$  dea on
 dea.location = vac.location
	
where dea.continent is not null
group by dea.continent,vac.people_fully_vaccinated


select vac.location,vac.people_fully_vaccinated from
Portfolioprojects..covid_vaccinations$ vac join Portfolioprojects..covid_deaths$ dea
on dea.location=vac.location

where dea.continent is not null
group by vac.location,vac.people_fully_vaccinated






-- 6. Contiennt wise Cases vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,dea.total_cases,vac.total_vaccinations,

(MAX(vac.total_vaccinations)/population)*100 as percent_vaccinated
From Portfolioprojects..covid_deaths$ dea
Join Portfolioprojects..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population,dea.total_cases,vac.total_vaccinations
order by 1,2,3
-- MAX(vac.total_vaccinations) as RollingPeopleVaccinated

select * from Portfolioprojects..covid_vaccinations$



-- 7.  Cases vs Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2




-- 8. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojects..covid_deaths$ dea
Join Portfolioprojects..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 9. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
