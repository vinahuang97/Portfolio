-- data cleaning

SELECT *
FROM layoffs;

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;


insert layoffs_staging
select *
from layoffs;

-- 1 Remove Duplicates
-- 2 Standardize the Data
-- 3 Null Values or blank Values
-- 4 Remove any Columns or Rows


-- 1 Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions
) as row_num
FROM layoffs_staging;


with duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions
) as row_num
FROM layoffs_staging
)
select *
from duplicate_cte
where row_num > 1 ;


-- cannot delete using this methods make new table to next step
with duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions
) as row_num
FROM layoffs_staging
)
DELETE
from duplicate_cte
where row_num > 1 ;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions
) as row_num
FROM layoffs_staging;

select *
from layoffs_staging2
where row_num > 1 
;

DELETE
from layoffs_staging2
where row_num > 1 
;

select *
from layoffs_staging2;


-- 2 Standardize the Data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country =  trim(trailing '.' from country)
where country like 'United States%'
;

select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

select *
from layoffs_staging2;


-- 3 Null Values or Blank Values

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


select *
from layoffs_staging2
where industry is null 
or industry = '';

select *
from layoffs_staging2
where company like 'Airbnb';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

select *
from layoffs_staging2
where company like 'Bally%';

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- 4 Remove unnecessary columns

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;