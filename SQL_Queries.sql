alter table [dbo].[Covid_Deaths]
alter column date date;
alter table [dbo].[Covid_Deaths]
alter column population bigint;
alter table [dbo].[Covid_Deaths]
alter column total_cases int;
alter table [dbo].[Covid_Deaths]
alter column new_cases int;
alter table [dbo].[Covid_Deaths]
alter column total_deaths int;
alter table [dbo].[Covid_Deaths]
alter column new_deaths int;
alter table [dbo].[Covid_Vaccination]
alter column date date;
alter table [dbo].[Covid_Vaccination]
alter column new_vaccinations int;
alter table [dbo].[Covid_Vaccination]
alter column total_vaccinations int;


-- Table 1 Global tot case, tot death, caserate,deathrate
select sum(population) as Total_Population, sum(new_cases) as total_cases, sum(new_deaths) as total_death
,(sum(cast(new_cases as decimal (10,2)))/sum(cast(population as decimal (15,2))))*100 as DeathPercentage,
(sum(cast(new_deaths as decimal (10,2)))/sum(cast(new_cases as decimal (10,2))))*100 as DeathPercentage
from Covid_Deaths
where continent <>'' and population <>0

--Table 2 hingest case and Infection rate by country
select location,max(population) as population, max(total_cases) as Highest_Case, 
case
when population = 0 then 0
when population <> 0 then (max(cast(total_cases as decimal (15,2)))/max(cast(population as decimal (15,2))))*100
end as InfectionRate
from Covid_Deaths
where continent <> ''
group by location, population
order by Highest_Case desc

--Table 3 highest deathcount by country
select location, max(total_deaths) as Total_death
from Covid_Deaths
where continent <>''
group by location
order by Total_death desc

--Table 4 Total cases each contonent
select location,max(total_cases) as InfectionCount
from Covid_Deaths
where continent ='' and location not in ('world','european union', 'international')
group by location
order by InfectionCount desc


--Table 5 Total deaths each contonent
select location,max(total_deaths) as DeathCount
from Covid_Deaths
where continent ='' and location not in ('world','european union', 'international')
group by location
order by DeathCount desc

--Table 6 Maps Heat
select location,max(population) as population, max(total_cases) as Highest_Case, 
case
when population = 0 then 0
when population <> 0 then (max(cast(total_cases as decimal (15,2)))/max(cast(population as decimal (15,2))))*100
end as InfectionRate
from Covid_Deaths
where continent <> ''
group by location, population

--Table 7 Time Stamp World
select date, sum(new_cases) as NewCase, sum(new_deaths) as NewDeath
from Covid_Deaths
where continent <>''
group by date
order by 1 asc

--Table 8 Time Stamp SouthEast Asia Country
select location, date, total_cases , total_deaths,
case
when total_cases =0 then 0
when total_cases <>0 then (cast(total_deaths as decimal(15,2))/cast(total_cases as decimal(15,2)))*100
end as Death_Rate
from Covid_Deaths
order by 1,2

--Table 9 Highest vaccination, highest vaccinationrate, timestamp
Drop table if EXISTS #VaccinatedPercentage
create table #VaccinatedPercentage
(continent nvarchar(225),
location nvarchar(225),
date date,
population numeric,
new_vaccinations numeric,
Total_current_vaccination numeric)

insert into #VaccinatedPercentage
select cd.continent, cd.location,cd.date,population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_current_vaccination
from Covid_Deaths as cd
join Covid_Vaccination as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent <>''

select*, 
case
when population = 0 then null
when population <>0 then (cast(Total_current_vaccination as decimal(15,2))/cast(population as decimal(15,2)))*100
end as VaccinationRate
from #VaccinatedPercentage