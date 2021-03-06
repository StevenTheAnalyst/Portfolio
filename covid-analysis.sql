/* 

COVID-19 Data Analysis

Skills used: SQL Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, Tableau

Dashboard: https://public.tableau.com/app/profile/steven.tang2622/viz/CoronavirusCOVID-19Cases_16563581215510/COVID-19GlobalView

*/


-- Select entire starting dataset

SELECT *
FROM Portfolio_Project.CovidDeaths;


-- Filter by column

SELECT location, date, population, total_cases, new_cases, total_deaths, 
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2; 


-- Total Cases vs Total Deaths
-- Shows likelihood of dying by contracting COVID-19 in the United States

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE location LIKE '%states%';


-- Total Cases vs Population
-- Shows what percentage of population infected with COVID-19

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
WHERE location LIKE '%states%';


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;


-- Countries with Highest Death Count per population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Sorting data by continent
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Global death rate from infection

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
GROUP BY date;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one dose of Covid vaccine

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) AS RollingSumVaccinated, (RollingSumVaccinated/population)*100
FROM PortfolioProject.CovidDeaths deaths
JOIN PortfolioProject.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL;


-- Using CTE to perform aggregation on Partition By clause in previous query

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingSumVaccinated)
AS (Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) AS RollingSumVaccinated
FROM PortfolioProject.CovidDeaths deaths
JOIN PortfolioProject.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac;


-- Using Temp Table to perform calculation on Partition By clause in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths deaths
JOIN PortfolioProject.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
	
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


-- Creating View to store data for future visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL;

SELECT * 
FROM PercentPopulationVaccinated;

    
    
