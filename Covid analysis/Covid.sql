use portfolio;
select * from coviddeath
where continent is not null
order by 3,4;

--select * from CovidVaccination
--order by 3,4;


SELECT location,date,new_cases,total_cases,total_deaths,population
FROM coviddeath
where continent is not null
order by 1,2;

-- compare total case with total deaths

Select location, date,total_cases,total_deaths,(total_deaths * 1.0 / total_cases)*100 AS deathPercetage
from coviddeath
where continent is not null;

-- compare total case with total deaths in Afganistan
Select location, date,total_cases,total_deaths,(total_deaths * 1.0 / total_cases)*100 AS deathPercetage
from coviddeath
where continent is not null and  location like 'Afg%'
order by 1,2;

-- Compare total cases and the total population in Afganistan
Select location, date,  population, total_cases,(total_cases*1.0/population)*100 as CasePopulation
from coviddeath
where continent is not null and  location like 'Afg%'
order by 1,2;

-- Countries with highest infection rate
Select location, population, max(total_cases) as higestInfection,max((total_cases*1.0/population)*100) as CasePopulation
from coviddeath
where continent is not null 
group by location, population
order by CasePopulation Desc;

--continent with the highest deaths
Select continent, sum(max_death) as deathCount
from (
	Select continent, location, max(total_deaths) as max_death
	from coviddeath
	where continent is not null
	group by continent, location
) as contry_death
group by continent
order by deathCount desc;

-- countries with highest deathrate
Select location,max(total_deaths) as deathCount
from coviddeath
where continent is not null 
group by location
order by deathCount desc ;

-- Global querry 
SELECT date,
       SUM(new_cases) AS total_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       (SUM(new_deaths)*100.0 / SUM(new_cases))  AS death_rate
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Total new cases, deaths and date rate around the globe
SELECT 
       SUM(new_cases) AS total_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       (SUM(new_deaths)*100.0 / SUM(new_cases))  AS death_rate
FROM coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2;

create view global_total as 
SELECT 
       SUM(new_cases) AS total_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       (SUM(new_deaths)*100.0 / SUM(new_cases))  AS death_rate
FROM coviddeath
WHERE continent IS NOT NULL;

-- Vaccination analysis 
-- total population and total vaccination

SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    
    SUM(CAST(cv.new_vaccinations AS INT)) 
        OVER (
            PARTITION BY cd.location 
            ORDER BY cd.date
        ) AS rolling_new_vaccinations

FROM coviddeath AS cd

LEFT JOIN CovidVaccination AS cv
    ON cd.location = cv.location
   AND cd.date = cv.date

WHERE cd.continent IS NOT NULL

ORDER BY 
    cd.location,
    cd.date;

-- with cte
    with popVsvac (continent, location ,date, population,new_vaccination, rolling_new_vaccinations)
    as(
    SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
    
        SUM(CAST(cv.new_vaccinations AS INT)) 
            OVER (
                PARTITION BY cd.location 
                ORDER BY cd.date
            ) AS rolling_new_vaccinations

    FROM coviddeath AS cd

    LEFT JOIN CovidVaccination AS cv
        ON cd.location = cv.location
       AND cd.date = cv.date

    WHERE cd.continent IS NOT NULL 
    )
    select *,(rolling_new_vaccinations*100.0/population) as rate_of_vaccination
    from popVsvac
    order by 2,3;

-- Fact table
create table #PercentagePopulationVaccinated
(continent varchar(100),
 location varchar(100),
 date datetime,
 population numeric,
 new_vaccination numeric,
 rolling_new_vaccination numeric,
)

Insert into #PercentagePopulationVaccinated
SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
    
        SUM(CAST(cv.new_vaccinations AS INT)) 
            OVER (
                PARTITION BY cd.location 
                ORDER BY cd.date
            ) AS rolling_new_vaccinations

    FROM coviddeath AS cd

    LEFT JOIN CovidVaccination AS cv
        ON cd.location = cv.location
        AND cd.date = cv.date

select *,(new_vaccination*100.0/population) as rate_of_population_vaccinated 
from #PercentagePopulationVaccinated


-- creating a view
create view PercentagePopulationVaccinated
as
SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
    
        SUM(CAST(cv.new_vaccinations AS INT)) 
            OVER (
                PARTITION BY cd.location 
                ORDER BY cd.date
            ) AS rolling_new_vaccinations

    FROM coviddeath AS cd

    LEFT JOIN CovidVaccination AS cv
        ON cd.location = cv.location
        AND cd.date = cv.date
    where cv.continent is not null