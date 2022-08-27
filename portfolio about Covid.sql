select * from myportfolio..deaths
order by 3,4

select * from myportfolio..vaccination
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from myportfolio..deaths
where new_cases is not null
order by 1,2


select location, date, total_cases, isnull(new_cases, '0') new_cases, isnull(total_deaths, '0') total_deaths, population
from myportfolio..deaths
order by 1,2

--this is total_cases versus total death. it has lots ok null values, so table was changed to non-null values


select location, date, total_cases, population, isnull(new_cases, '0') new_cases, isnull(total_deaths, '0') total_deaths, round((total_deaths/total_cases) *  100, 1) Deathpercentage 
from myportfolio..deaths
where location like '%south korea%'
order by 1,2

-- Deathpercentage of south korea

select location, population,max(total_cases) as HighestInfectionCount, max(round((total_deaths/total_cases) *  100, 1)) as Deathpercentage 
from myportfolio..deaths
group by location,population
order by HighestInfectionCount desc

--looking at countries with highest infection rate compared to population
select location, max(cast(total_deaths as int)) as TotalDeathcount
from myportfolio..deaths
--WHERE continent IS NOT NULL
group by location
order by TotalDeathcount desc
--showing countries with highest death count per population , total_daeths column is nvarchart, for accurated analysis, I used cast function to change data type


-- BREAK DOWN COTINENT AND COUNTRY
select continent, max(cast(total_deaths as int)) as TotalDeathcount
from myportfolio..deaths
where continent is not null
group by continent
order by TotalDeathcount desc


--showing continent with the highest death count per population
select continent, max(cast(total_deaths as int))/max(population) as TotalDeathcount
from myportfolio..deaths
where continent is not null
group by continent
order by TotalDeathcount desc


--Global numbers
select  sum(new_Cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_Cases)*100 as deathpercentage
from myportfolio..deaths
where continent is not null
order by 1,2


--join two tables. Total population vs vaccinations. PARTITION BY LOCATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as rolling,
(sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) / dea.population) * 100 as rollingpercentage 
from myportfolio..deaths dea
join myportfolio..vaccination vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND vac.new_vaccinations IS NOT NULL
order by 2,3

-- try to use CTE)difficult to understand
with Pop_vs_vac (continent,Location, Date, population,new_vaccinations, rolling) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as rolling
from myportfolio..deaths dea
join myportfolio..vaccination vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND vac.new_vaccinations IS NOT NULL
)
select * from Pop_vs_vac

--creating View percentpopulationVaccinated 

Create view percentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as rolling
from myportfolio..deaths dea
join myportfolio..vaccination vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null AND vac.new_vaccinations IS NOT NULL

select * from percentPopulationvaccinated