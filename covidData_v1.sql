select  * from CovidData..covidDeaths order by 3,4;

--select top 100 * from covidVaccinations order by 3,4;

select location , date , total_cases, total_deaths , (total_deaths/total_cases) * 100 as DeathPercentage from 
covidDeaths where location like '%India%'
order by 1,2;

select location , date , total_cases, population , (total_cases/population) * 100 as InfectionRate from 
covidDeaths where location like '%India%'
order by 1,2;

select location ,  population , MAX(total_cases) as HighestCases , MAX((total_cases/population) * 100) as InfectionRate from covidDeaths 
--where location like '%India%'
group by location, population 
order by InfectionRate desc;

select location , continent , MAX(cast(total_deaths as int)) as deathCount from covidDeaths
where continent is not null
group by location , continent
order by deathCount desc;

select * from CovidData..covidDeaths cd join CovidData..covidVaccinations cv on
cd.location = cv.location and cd.date = cv.date 

select cd.location , cd.population , SUM(cast(cd.new_cases as int)) as covidCases , SUM(cast(cv.new_tests as int)) as CovidTests   from
CovidData..covidDeaths cd join CovidData..covidVaccinations cv on
cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
group by cd.location,cd.population
order by cd.location;


select cd.continent, cd.location , cd.date, cd.population , cast(cv.new_Vaccinations as int) as newVaccination ,
 SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.date) as rollingVaccination from 
CovidData..covidDeaths cd join CovidData..covidVaccinations cv on
cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
order by cd.location

--CTE

with Population_Vaccination (Continent,location,date ,population, Vaccination , rollingVaccination )
as 
(
select cd.continent, cd.location , cd.date, cd.population , cast(cv.new_Vaccinations as int) as newVaccination ,
 SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.date,cd.location) as rollingVaccination from 
CovidData..covidDeaths cd join CovidData..covidVaccinations cv on
cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
--order by cd.location
)
select *,rollingVaccination/population as perc_population from Population_Vaccination

drop view if exists V_popVsvacc

create View V_popVsvacc
as 
select cd.continent, cd.location , cd.date, cd.population , cast(cv.new_Vaccinations as int) as newVaccination ,
 SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.date,cd.location) as rollingVaccination from 
CovidData..covidDeaths cd join CovidData..covidVaccinations cv on
cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 

select * from V_popVsvacc
