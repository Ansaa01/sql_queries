SELECT * 
FROM covid_era.coviddeaths
where continent is null
order by 3,4;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_era.coviddeaths
where continent is null
ORDER BY 1 , 2;

-- total cases vs total deaths --
-- the chances of dying from covid in Canada --
SELECT location ,date, total_cases, total_deaths, 
 (total_deaths/total_cases) * 100 as death_percentage
FROM covid_era.coviddeaths
where location = 'Canada'
and continent is not null
ORDER BY 1 , 2;

-- total cases vs population --
-- indicates the percentage of population that contracted covid --
SELECT location ,date, population, total_cases,
 (total_cases/population) * 100 as population_percentage
FROM covid_era.coviddeaths
where location = 'Canada'
ORDER BY 1,2;

-- Countries with highest infection rate vs population --
SELECT location, population, max(total_cases) as highest_infection_count,
 max((total_cases/population)) * 100 as highest_infection_percentage
FROM covid_era.coviddeaths
group by location, population
ORDER BY highest_infection_percentage desc;

-- Countries with highest death count rate vs population --

SELECT location, max(cast(total_deaths as unsigned)) as highest_death_count 
FROM covid_era.coviddeaths
where continent is not null
group by location
ORDER BY highest_death_count desc;

-- Continents with highest death count rate vs population --
SELECT location, max(cast(total_deaths as unsigned)) as highest_death_count 
FROM covid_era.coviddeaths
where continent is null
group by location
ORDER BY highest_death_count desc;

-- Global Numbers --

SELECT date,
 sum(cast(ifnull(new_cases, 0) as unsigned)) as total_cases,
 sum(cast(ifnull(new_deaths, 0) as unsigned)) as total_deaths,
 sum(cast(ifnull(new_deaths, 0) as unsigned)) /sum(cast(ifnull(new_cases, 0) as unsigned)) * 100 as death_percentage
FROM covid_era.coviddeaths
group by date
ORDER BY 1,2;

-- Covid Vaccinations --
-- total population vs vaccinations --
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum((cast(vac.new_vaccinations as unsigned))) over (partition by
 dea.location order by dea.location, date) as rolling_vaccinated_people
FROM covid_era.coviddeaths dea
Join covid_era.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


-- cte version --
with population_vs_vaccination (continent, location, date, population, 
new_vaccinations, rolling_vaccinated_people)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum((cast(vac.new_vaccinations as unsigned))) over (partition by
 dea.location order by dea.location, date) as rolling_vaccinated_people
FROM covid_era.coviddeaths dea
Join covid_era.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3
)
select *, 
(rolling_vaccinated_people/population) * 100
from population_vs_vaccination;

-- temp table version 
drop table if exists PercentPopulationVaccinated;

create table PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric, 
rolling_vaccinated_people numeric
);

insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum((cast(vac.new_vaccinations as unsigned))) over (partition by
 dea.location order by dea.location, date) as rolling_vaccinated_people
FROM covid_era.coviddeaths dea
Join covid_era.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null;
-- order by 1,2,3

select *,
(rolling_vaccinated_people/population) * 100
from PercentPopulationVaccinated;

-- Creating View to store data --

create view HighestDeathView as
SELECT continent, max(cast(total_deaths as unsigned)) as highest_death_count 
FROM covid_era.coviddeaths
where continent is not null
group by continent;

create view CanadaDeathPercentage as
SELECT location ,date, total_cases, total_deaths, 
 (total_deaths/total_cases) * 100 as death_percentage
FROM covid_era.coviddeaths
where location = 'Canada'
and continent is not null
ORDER BY 1 , 2;

create view CanadaDeathChancesview as
SELECT location ,date, total_cases, total_deaths, 
 (total_deaths/total_cases) * 100 as death_percentage
FROM covid_era.coviddeaths
where location = 'Canada'
and continent is not null
ORDER BY 1 , 2;

