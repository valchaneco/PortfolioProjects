SELECT *
FROM
	coviddeaths
WHERE
	continent IS NOT NULL
ORDER BY
	3,4


SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	coviddeaths
ORDER BY
	location,
	date

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths::decimal/total_cases)*100 AS death_percentage
FROM
	coviddeaths
WHERE
	location LIKE '%Philippines%'
ORDER BY
	location,
	date;	


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases::decimal/population)*100 AS percent_population_infected
FROM
	coviddeaths
WHERE 
	location LIKE '%Philippines%'
ORDER BY
	location,
	date;


-- Looking at countries with highest infection rate compared to population

SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases::decimal/population))*100 AS percent_population_infected
FROM
	coviddeaths
-- WHERE location LIKE '%Philippines%'
GROUP BY
	location,
	population
ORDER BY
	percent_population_infected DESC;


-- Showing countries with highest death count per population

SELECT
	location,
	MAX(total_deaths) AS total_death_count
FROM
	coviddeaths
-- WHERE location LIKE '%Philippines%'
WHERE
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	total_death_count DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count per population

SELECT
	continent,
	MAX(total_deaths) AS total_death_count
FROM
	coviddeaths
-- WHERE location LIKE '%Philippines%'
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	total_death_count DESC;


-- GLOBAL NUMBERS

SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)::decimal/NULLIF(SUM(new_cases),0)*100 AS death_percentage
FROM
    coviddeaths
-- WHERE location LIKE '%Philippines%'
WHERE
	continent IS NOT NULL
-- GROUP BY date
ORDER BY
	1,2;


-- Looking at Total population vs Vaccinations

SELECT *
FROM
	coviddeaths dea
JOIN
	covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- 

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) AS rolling_people_vaccinated
FROM
	coviddeaths dea
JOIN
	covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,3


-- USE CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated) AS
(
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) AS rolling_people_vaccinated
	FROM
		coviddeaths dea
	JOIN
		covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL
	-- ORDER BY 2,3
)
SELECT
	*,
	(rolling_people_vaccinated/population)*100
FROM
	PopvsVac


-- TEMP TABLE	

-- Drop the table if it exists
DROP TABLE IF EXISTS percent_population_vaccinated


-- Create the temporary table
CREATE TEMPORARY TABLE percent_population_vaccinated (
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_people_vaccinated NUMERIC
);

-- Insert the data into the temporary table
INSERT INTO percent_population_vaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM
	coviddeaths dea
JOIN
	covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL;


-- Retrieve the results from the temporary table
SELECT
  *,
  (rolling_people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM
  percent_population_vaccinated;
  


-- Creating View to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM
	coviddeaths dea
JOIN
	covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY
-- 2,3
 
SELECT 
	*
FROM
	percent_population_vaccinated
	
 


