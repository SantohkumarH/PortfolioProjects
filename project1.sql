select *
from dbo.CovidDeaths
where continent is  NULL
order by 8


select *
from dbo.CovidVaccinations
order by 3



--let us select only columns which we want to use
select location,date,total_cases,new_cases,total_deaths,population
from .CovidDeaths 
where continent is NOT NULL
order by 1,2

--total cases vs total death percentage
--shows probability of dying if you contact COVID-19 in your country
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentagepopulation
from .CovidDeaths where location like '%india%'
order by 1,2

--total case vs population
--percentage of people who were tested positive for covid in that country
select location,date,total_cases,(total_cases/population) *100 as CovidPositive_Percentage,new_cases,total_deaths,population
from .CovidDeaths 
where location like '%india%' and  continent is NOT NULL
order by 1,2

--looking at countries with highest infection rate compaired to population

select location,date,(total_cases/population) *100 as CovidPositive_Percentage,population, MAX(total_cases) as Total_Infected_Count,max((total_cases/population) *100 ) as PercentageofInfectedPopulation
from .CovidDeaths 
--where location like '%india%'
where continent is not NULL
group by total_cases,location,date,population
order by  Total_Infected_Count desc

--selecting countries with heighest death count with respect to population

Select location ,total_deaths,max(total_deaths/population)*100 as Death_Percentage
from .CovidDeaths
where total_deaths is NOT NULL and  continent is NOT NULL
group by location,date,population,total_deaths
order by Death_Percentage desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from .CovidDeaths
where continent is NOT NULL
group by location
order by TotalDeathCount desc


--To get total number of death in world and order it accordingly 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from .CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

-- selecting continents  with highest number of death count per population

select continent,max(cast(total_deaths as int)) as maxdeath
from .CovidDeaths
where continent is not null
group by continent
order by maxdeath desc


--to get new case values globally 

select date,sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as TotalNewDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from .CovidDeaths
where continent is not null
group by date
--having (Sum(cast(new_deaths as int))/sum(new_cases)*100) >8
order by 1 desc  

select location,sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as TotalNewDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from .CovidDeaths
where continent is not null
group by location
having   location='India'  --(Sum(cast(new_deaths as int))/sum(new_cases)*100) >8
order by 1 desc  


-- above is the query to get total number of new cases globally

select sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as TotalNewDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from .CovidDeaths
where continent is not null

--above is the  query to get total number of new cases globally


--total death vs male smokers

select location,sum(cast(total_deaths as int))as Deaths,(sum(cast(male_smokers as decimal)) +sum(cast(female_smokers as decimal))) as Smokers , ((sum(cast(male_smokers as float)) + sum(cast(female_smokers as float)))/sum(cast(total_deaths as int))*100) as DeathPercentage
from .CovidDeaths
where continent is not null 
group by location
--having location like '%india%'
order by Smokers 

--to get details of total number of vaccinated people

select det.location,vacc.date,vacc.total_tests,vacc.people_vaccinated
from .CovidDeaths det join .CovidVaccinations vacc
on det.location = vacc.location
order by 2 




--to get total population vs vaccinations

--select d.continent,d.location,d.date,d.population,v.new_vaccinations,
--sum(convert(int,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--from .CovidDeaths d join .CovidVaccinations v
--on d.location = v.location  and d.date = v.date
--where d.continent is not null
--order by 2,3


--select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations))
--from .CovidDeaths d join .CovidVaccinations v
--on d.location = v.location  and d.date = v.date
--where d.continent is not null
--order by 2,3

--using CTE

with popVSvacc (continent,location,date,population,new_vaccinations,TotalPeopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as TotalPeopleVaccinated
from .CovidDeaths d join .CovidVaccinations v
on d.location = v.location  and d.date = v.date
where d.continent is not null
--order by 2,3

)
select location,max((TotalPeopleVaccinated/population)*100 )As VaccinationPercentage
from popVSvacc
group by location
having location like '%india%'
order by 1,2



--Using TEMP table
drop table if exists #popVsVaccTEMP
create table #popVsVaccTEMP
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated numeric
)
insert into #popVsVaccTEMP
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as TotalPeopleVaccinated
from .CovidDeaths d join .CovidVaccinations v
on d.location = v.location  and d.date = v.date
where d.continent is not null
--order by 2,3

select location,max((TotalPeopleVaccinated/population)*100) as VaccinationPercentage
from #popVsVaccTEMP
group by location
order by 1