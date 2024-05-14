/*
Covid 19 data exploration
Skill used: Join's, CTE, Temp table, Windowns functions, Agreegate functions, Creating views, Converting data type  
*/
-----------------------------------------------------------------------------------------------------------------------

Select *
From Portfolio_project..CovidDeaths
Where continent is not null
Order by 3,4

--Select Data that where we are going to be start with
Select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population_density
From Portfolio_project..CovidDeaths
Where continent is not null
Order by 1,2

-----------------------------------------------------------------------------------------------------------------------------
--Looking at Total Cases vs Total Deaths

Select 
	location,
	date,
	total_cases,
	total_deaths,
	(cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
From Portfolio_project..CovidDeaths
Where lower(location) = 'vietnam'
Order by 1,2

-----------------------------------------------------------------------------------------------------------------------------
--Looking at Total Cases vs Population

Select 
	location,
	date,
	total_cases,
	population_density,
	(population_density/cast(total_cases as float))*100 as pop_percentage
From Portfolio_project..CovidDeaths
Where lower(location) like '%state%'
Order by 1,2

-----------------------------------------------------------------------------------------------------------------------------
--Looking at Countries with Highest Infection rate compared to Population

Select
	location,
	population_density,
	max(total_cases) as highest_inflection_cnt,
	max(cast(total_cases as float)/population_density)*100 as percent_pop_inflection
From Portfolio_project..CovidDeaths
Group by location, population_density
Order by percent_pop_inflection desc

-----------------------------------------------------------------------------------------------------------------------------
--Showing Countries with Highest Death Count per Population

Select
	location,
	sum(cast(total_deaths as float)) as total_deaths_cnt
From Portfolio_project..CovidDeaths
Where continent is not null
Group by location
Order by total_deaths_cnt desc

-----------------------------------------------------------------------------------------------------------------------------
--BREAKING THINGS DOWN BY CONTINENT
--Showing contintents with the highest death count per population

Select
	continent,
	max(cast(total_deaths as numeric)) as total_death_cnt
From Portfolio_project..CovidDeaths
Where continent is not null
Group by continent
Order by total_death_cnt desc

-----------------------------------------------------------------------------------------------------------------------------
--Global numbers

Select
	sum(new_cases) as total_cases,
	sum(new_deaths) as total_deaths,
	sum(new_deaths)/sum(new_cases)*100 as new_death_percent
From Portfolio_project..CovidDeaths
Where continent is not null

-----------------------------------------------------------------------------------------------------------------------------
--Looking at Total Population vs Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select	
	d.continent,
	d.location,
	d.date,
	d.population_density,
	v.new_vaccinations,
	sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
From Portfolio_project..CovidDeaths d
Left join Portfolio_project..CovidVaccination v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null 
Order by 2,3

-----------------------------------------------------------------------------------------------------------------------------
--Using CTE to perform Calculation on Partition By in previous query

with 
popvsvacc as 
(
	Select 
		d.continent,
		d.location,
		d.date,
		d.population_density,
		v.new_vaccinations,
		sum(convert(bigint, v.new_vaccinations)) 
		over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
	From Portfolio_project..CovidDeaths d
	Left join Portfolio_project..CovidVaccination v
		on d.location = v.location
		and d.date = v.date
	Where d.continent is not null
)
Select 
	*,
	(rolling_people_vaccinated/ population_density)*100 as vaccination_perc
From popvsvacc

-----------------------------------------------------------------------------------------------------------------------------
--Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists PercentagePopulationVaccinated
Create table PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into PercentagePopulationVaccinated
Select 
	d.continent,
	d.location,
	d.date,
	d.population_density,
	v.new_vaccinations,
	sum(convert(bigint, v.new_vaccinations)) 
	over (partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
From Portfolio_project..CovidDeaths d
Left join Portfolio_project..CovidVaccination v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null

Select 
	*,
	(nullif(rollingpeoplevaccinated,0)/ nullif(population,0))*100 as vaccination_perc
From PercentagePopulationVaccinated