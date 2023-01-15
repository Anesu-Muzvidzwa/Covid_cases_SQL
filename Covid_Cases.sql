SELECT *
FROM Covid_Cases..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM Covid_Cases..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Cases..CovidDeaths
ORDER BY 1,2


--Investigating Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Cases..CovidDeaths

WHERE location like '%states%'
ORDER BY 1,2
