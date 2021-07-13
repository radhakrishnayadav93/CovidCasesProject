select * from PortfolioProject.dbo.CovidDeaths

select location, date, total_cases, new_cases, total_deaths,  population
from CovidDeaths
order by 1,2

-- total_deaths percentage per total_cases

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage,  population
from CovidDeaths
order by 1,2

-- Death_Percentage for Algeria

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage,  population
from CovidDeaths
where location = 'Algeria'
order by 1,2

--   OR

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage,  population
from CovidDeaths
where location like '%alg%'
order by 1,2

-- Total cases per population

select location, date, total_cases,total_deaths, (total_cases/population)*100 as Total_Cases_Per_Population,  population
from CovidDeaths
order by 1,2

-- Country wise highest No. of total cases and total percentage

select location,MAX(total_cases) as Highest_cases_Countrywise , max((total_cases/population)*100) as Highest_Cases_Per_Population_Countrywise,  population
from CovidDeaths
group by location, population
order by 3 desc

select location,MAX(cast(total_deaths as int)) as HighestDeathCount 
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount Desc


-- Total_vaccination vs Total_population

select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location , cd.date) as Rolling_Sum_Newvaccinations
from CovidDeaths as cd 
join CovidVaccinations as cv 
on cd.date = cv.date 
and cd.location = cv.location
where cd.continent is not null
order by 2,3

-- Using CTE

with PopvsVac(continent,location,date,population,new_vaccinations,Rolling_Sum_Newvaccinations)
as
(
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location , cd.date) as Rolling_Sum_Newvaccinations
from CovidDeaths as cd 
join CovidVaccinations as cv 
on cd.date = cv.date 
and cd.location = cv.location
where cd.continent is not null
--order by 2,3
)

select * , (Rolling_Sum_Newvaccinations/population)*100
from PopvsVac

--Temp Table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location , cd.date) as Rolling_Sum_Newvaccinations
from CovidDeaths as cd 
join CovidVaccinations as cv 
on cd.date = cv.date 
and cd.location = cv.location
where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

-- Creating view

create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location , cd.date) as Rolling_Sum_Newvaccinations
from CovidDeaths as cd 
join CovidVaccinations as cv 
on cd.date = cv.date 
and cd.location = cv.location
where cd.continent is not null
--order by 2,3

