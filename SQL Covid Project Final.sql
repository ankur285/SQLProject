create table covid_deaths
(
iso_code longtext,
continent longtext,
location longtext,
dateofinfo longtext,
population bigint,
total_cases bigint,
new_cases bigint,
new_cases_smoothed double,
total_deaths bigint,
new_deaths bigint,
new_deaths_smoothed double,
total_cases_per_million double,
new_cases_per_million double,
new_cases_smoothed_per_million	double,
total_deaths_per_million double,
new_deaths_per_million double,
new_deaths_smoothed_per_million	double,
reproduction_rate double,
icu_patients bigint,
icu_patients_per_million double,
hosp_patients bigint,
hosp_patients_per_million double,
weekly_icu_admissions bigint,
weekly_icu_admissions_per_million double,
weekly_hosp_admissions	bigint,
weekly_hosp_admissions_per_million double
);

select count(*) from covid_deaths;

create table covid_vaccinations
(
iso_code longtext,
continent longtext,
location longtext,
dateofinfo longtext,	
total_tests	bigint,
new_tests bigint,
total_tests_per_thousand double,	
new_tests_per_thousand double,
new_tests_smoothed double,
new_tests_smoothed_per_thousand double,
positive_rate double,
tests_per_case double,
tests_units	longtext,
total_vaccinations bigint,
people_vaccinated bigint,
people_fully_vaccinated	bigint,
total_boosters	bigint,
new_vaccinations bigint,
new_vaccinations_smoothed double,	
total_vaccinations_per_hundred double,
people_vaccinated_per_hundred double,
people_fully_vaccinated_per_hundred	double,
total_boosters_per_hundred double,
new_vaccinations_smoothed_per_million double,
new_people_vaccinated_smoothed double,
new_people_vaccinated_smoothed_per_hundred double,
stringency_index double,
population_density double,
median_age double,
aged_65_older bigint,
aged_70_older bigint,
gdp_per_capita double,
extreme_poverty	double,
cardiovasc_death_rate double,
diabetes_prevalence	double,
female_smokers double,
male_smokers double,
handwashing_facilities double,	
hospital_beds_per_thousand	double,
life_expectancy	double,
human_development_index double,
excess_mortality_cumulative_absolute double,
excess_mortality_cumulative double,
excess_mortality double,
excess_mortality_cumulative_per_million double
);
select count(*) from covid_vaccinations;
select * from covid_deaths;

alter table covid_deaths
drop dateofinfo;

alter table covid_deaths
add dateofinfo longtext;

select count(dateofinfo) from covid_deaths;

-- Changing the date to the correct date-time format for covid_vaccinations table
select * from covid_vaccinations;

alter table covid_vaccinations
add dd numeric,
add mm numeric,
add yy numeric,
add dateofinfo01 datetime;

update covid_vaccinations
set dd = substring(dateofinfo,1,2),
mm= substring(dateofinfo,4,2),
yy= substring(dateofinfo,7,4);

update covid_vaccinations
set dateofinfo01 = concat(yy,'-',mm,'-',dd);

select dateofinfo,mm,dd,yy,dateofinfo01 from covid_vaccinations;

alter table covid_vaccinations
drop dateofinfo;

alter table covid_vaccinations
rename column dateofinfo01 to dateofinfo;

-- Checking the changes
select* from covid_vaccinations;
alter table covid_vaccinations
drop dd, drop mm, drop yy;
select location, dateofinfo, total_tests, people_vaccinated 
from covid_vaccinations
order by 1,2;


-- Changing the date to the correct date-time format for covid_deaths table
select * from covid_deaths;

alter table covid_deaths
add dd numeric,
add mm numeric,
add yy numeric,
add dateofinfo01 datetime;

update covid_deaths
set dd = substring(dateofinfo,1,2),
mm= substring(dateofinfo,4,2),
yy= substring(dateofinfo,7,4);

update covid_deaths
set dateofinfo01 = concat(yy,'-',mm,'-',dd);

select dateofinfo,mm,dd,yy,dateofinfo01 from covid_deaths;

alter table covid_deaths
drop dateofinfo;

alter table covid_deaths
rename column dateofinfo01 to dateofinfo;

-- Checking the changes
select* from covid_deaths;
alter table covid_deaths
drop dd, drop mm, drop yy;

-- Start
select location,dateofinfo,total_cases,new_cases, total_deaths, population
from covid_deaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location,dateofinfo,total_cases, total_deaths, (total_deaths/ total_cases)*100 as death_percentage
from covid_deaths
where location like 'india'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location,dateofinfo,total_cases, population, (total_cases/ population)*100 as percent_population_infected
from covid_deaths
where location like 'india'
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to Population
select location, population, max(total_cases)as highest_infection_count, MAX((total_cases/ population))*100 as percent_population_infected
from covid_deaths
group by location, population
order by percent_population_infected desc;

-- Showing Countries with Highest Death Count per Population
select location, max(total_deaths) as totaldeathcount
from covid_deaths
where continent is not null
group by location
order by totaldeathcount desc;

select location, max(total_deaths) as totaldeathcount
from covid_deaths
where continent is null
group by location
order by totaldeathcount desc;

-- Breaking down by Continents
select continent, max(total_deaths) as totaldeathcount
from covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc;

-- Showing the Continents with the highest death count per population
select continent, max(total_deaths) as totaldeathcount
from covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc;

-- GLOBAL NUMBERS
select dateofinfo, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
group by dateofinfo
order by 1,2;

-- Death percentage all across the world
select  sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
order by 1,2;

-- Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.dateofinfo, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dateofinfo) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccinations as vac
on dea.location= vac.location
and dea.dateofinfo= vac.dateofinfo
where dea.continent is not null
order by 2,3;

-- by using CTE
with PopvsVacs( continent, location, dateofinfo, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.dateofinfo, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dateofinfo) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccinations as vac
on dea.location= vac.location
and dea.dateofinfo= vac.dateofinfo
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVacs;


-- by using TEMP TABLE
drop table if exists PercentPopulationVaccinated;
Create table  PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date01 datetime,
population numeric,
newvaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.dateofinfo, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dateofinfo) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccinations as vac
on dea.location= vac.location
and dea.dateofinfo= vac.dateofinfo;
-- where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating VIEW to store data for visualizations
drop view if exists percentpopulationvaccinated01;
create view percentpopulationvaccinated01 as 
select dea.continent, dea.location, dea.dateofinfo, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dateofinfo) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccinations as vac
on dea.location= vac.location
and dea.dateofinfo= vac.dateofinfo
where dea.continent is not null;