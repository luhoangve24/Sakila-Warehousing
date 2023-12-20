-- Tao bang DIM DATE
-- DROP TABLE IF EXISTS date_dimension;
CREATE TABLE date_dim (
        Date_Key                INTEGER PRIMARY KEY,  -- year*10000+month*100+day (hoac 1->n), Surrogate Key -> 2013-12-31/20131231
        Full_Date               DATE NOT NULL, -- 2002-04-02 (full date)
        Day_Num                 INTEGER NOT NULL, -- 1 to 31
        Month_Num               INTEGER NOT NULL, -- 1 to 12
        Year_Num                INTEGER NOT NULL, -- 2023
		Week_Day_Name 			VARCHAR(15) NOT NULL, -- 'Monday', 'Tuesday'...
        Week_Day_Short			VARCHAR(5) NOT NULL, -- MO, TU, WE, ...
        Month_Name				VARCHAR(15) NOT NULL, -- 'January', 'February'...
        Month_Short				VARCHAR(5) NOT NULL, -- JAN, FEB, ...
        Day_Of_Year 			INTEGER NOT NULL, -- 1 to 365/366
        Week_Of_Month			INTEGER NOT NULL, -- Tuan thu may cua thang (1 to 4)
        Week_Of_Year            INTEGER NOT NULL, -- 1 to 52/53
        Quarter_Year            INTEGER NOT NULL, -- 1 to 4
        Quarter_Name            VARCHAR(15) NOT NULL, -- First/Fourth, ...  
        Weekend_Flag            CHAR(1) DEFAULT 'f' NOT NULL,
        Holiday_Flag            CHAR(1) DEFAULT 'f' NOT NULL,
        Event_Name              VARCHAR(50) -- 'Ngay Phu nu Viet Nam', ...
);


-- Procedure tu dong dien gia tri cho DATE DIM
-- DROP PROCEDURE IF EXISTS fill_date_dimension;

DELIMITER //
-- Pass all SQL statements as a single by // character (the MySQL engine)
CREATE PROCEDURE fill_date_dimension(IN startdate DATE, IN stopdate DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
    -- Date_Key, Full_Date, Day_Num, Month_Num, Year_Num, Week_Day_Name, Week_Day_Short, Month_Name, Month_Short
	-- Day_Of_Year, Week_Of_Month, Week_Of_Year, Quarter_Year, Quarter_Name, Weekend_Flag, Holiday_Flag, Event_Name
        INSERT INTO date_dim VALUES (
                        YEAR(currentdate)*10000 + MONTH(currentdate)*100 + DAY(currentdate), -- Date_Key
                        currentdate, -- Full_Date
                        DAY(currentdate), -- Day_Num
                        MONTH(currentdate), -- Month_Num
                        YEAR(currentdate), -- Year_Num
                        DAYNAME(currentdate), -- Week_Day_Name
                        DATE_FORMAT(currentdate, '%a'), -- Week_Day_Short
                        MONTHNAME(currentdate), -- Month_Name
                        DATE_FORMAT(currentdate, '%b'), -- Month_Short
                        DAYOFYEAR(currentdate), -- Day_Of_Year
                        CEIL(DAYOFMONTH(currentdate)/7), -- Week_Of_Month
                        WEEK(currentdate), -- Week_Of_Year
                        QUARTER(currentdate), -- Quarter_Year
                        CASE QUARTER(currentdate) WHEN 1 THEN 'First' WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' ELSE 'Fourth' END, -- Quarter_Name
                        CASE DAYOFWEEK(currentdate) WHEN 1 THEN 't' WHEN 7 then 't' ELSE 'f' END, -- Weekend_Flag
                        'f', -- No Holiday_Flag
                        NULL -- No Event_Name
                        );
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END
//
DELIMITER ;

-- Execute Procedure (Sakila range: 2005 - 2006)
CALL fill_date_dimension('2005-01-01','2006-12-31');
-- SELECT * FROM date_dim;

-- Insert mot so ngay holidays
UPDATE date_dim
	SET Event_Name = CASE
	WHEN Day_Num = 1 AND Month_Num = 1 THEN 'Tet Duong Lich'
    WHEN (Day_Num > 21 AND Month_Num = 1) OR (Day_Num < 22 AND Month_Num = 2) THEN 'Tet Nguyen Dan (co the)'
    WHEN Day_Num = 30 AND Month_Num = 4 THEN 'Giai phong mien Nam, Thong nhat Dat Nuoc'
    WHEN Day_Num = 1 AND Month_Num = 5 THEN 'Quoc te Lao Dong'
    WHEN Day_Num = 2 AND Month_Num = 9 THEN 'Quoc khanh Viet Nam'
    ELSE NULL
END; -- Protecting the Update clause

UPDATE date_dim
	SET Holiday_Flag = 'f'
    WHERE Event_Name IS NULL;
-- ------------------------------------------------------------------------------------



-- Tao bang film dim
CREATE TABLE film_dim (
  film_key INT NOT NULL PRIMARY KEY,
  film_id INT,
  title VARCHAR(70),
  description TEXT,
  release_year INT,
  language VARCHAR(20),
  rental_duration INT,
  rental_rate DECIMAL(4,2),
  length INT,
  replacement_cost DECIMAL(5,2),
  rating VARCHAR(30),
  category_name VARCHAR(30),
  has_trailers CHAR(1),
  has_commentaries CHAR(1),
  has_deleted_scenes CHAR(1),
  has_behind_the_scenes CHAR(1)
);
ALTER TABLE film_dim MODIFY film_key INT AUTO_INCREMENT;
-- Check
-- SELECT * FROM film_dim;


-- Tao bang store dim
CREATE TABLE store_dim (store_key INT NOT NULL PRIMARY KEY);
ALTER TABLE `starring-sakila`.`store_dim` 
ADD COLUMN `store_id` INT NULL AFTER `store_key`,
ADD COLUMN `address` VARCHAR(70) NULL AFTER `store_id`,
ADD COLUMN `district` VARCHAR(20) NULL AFTER `address`,
ADD COLUMN `postal_code` VARCHAR(10) NULL AFTER `district`,
ADD COLUMN `phone_number` VARCHAR(20) NULL AFTER `postal_code`,
ADD COLUMN `city` VARCHAR(50) NULL AFTER `phone_number`,
ADD COLUMN `country` VARCHAR(50) NULL AFTER `city`,
ADD COLUMN `manager_staff_id` INT NULL AFTER `country`,
ADD COLUMN `manager_first_name` VARCHAR(45) NULL AFTER `manager_staff_id`,
ADD COLUMN `manager_last_name` VARCHAR(45) NULL AFTER `manager_first_name`;
ALTER TABLE store_dim MODIFY store_key INT AUTO_INCREMENT;
-- DROP TABLE store_dim;
-- AFTER ETL
-- SELECT * FROM store_dim;

-- Tao bang Customer DIM
CREATE TABLE customer_dim(customer_key INT NOT NULL PRIMARY KEY);
ALTER TABLE `starring-sakila`.`customer_dim` 
ADD COLUMN `customer_id` INT NULL AFTER `customer_key`,
ADD COLUMN `first_name` VARCHAR(50) NULL AFTER `customer_id`,
ADD COLUMN `last_name` VARCHAR(50) NULL AFTER `first_name`,
ADD COLUMN `email` VARCHAR(50) NULL AFTER `name`,
ADD COLUMN `activate` CHAR(3) NULL AFTER `email`,
ADD COLUMN `create_date` DATE NULL AFTER `activate`,
ADD COLUMN `address` VARCHAR(70) NULL AFTER `create_date`,
ADD COLUMN `district` VARCHAR(20) NULL AFTER `address`,
ADD COLUMN `postal_code` VARCHAR(20) NULL AFTER `district`,
ADD COLUMN `phone` VARCHAR(20) NULL AFTER `postal_code`,
ADD COLUMN `city` VARCHAR(50) NULL AFTER `phone`,
ADD COLUMN `country` VARCHAR(50) NULL AFTER `city`;
ALTER TABLE customer_dim MODIFY customer_key INT AUTO_INCREMENT;
-- TRUNCATE TABLE customer_dim;
-- Check
-- SELECT * FROM customer_dim;


-- Tao bang Staff Dim
CREATE TABLE staff_dim(staff_key INT NOT NULL PRIMARY KEY);
ALTER TABLE `starring-sakila`.`staff_dim` 
ADD COLUMN `staff_id` INT NULL AFTER `staff_key`,
ADD COLUMN `first_name` VARCHAR(45) NULL AFTER `staff_id`,
ADD COLUMN `last_name` VARCHAR(45) NULL AFTER `first_name`,
ADD COLUMN `email` VARCHAR(45) NULL AFTER `last_nam`,
ADD COLUMN `staff_store_id` INT NULL AFTER `email`,
ADD COLUMN `active` INT NULL AFTER `staff_store_id`,
ADD COLUMN `manager_staff_id` INT NULL AFTER `active`;
ALTER TABLE staff_dim MODIFY staff_key INT AUTO_INCREMENT;


-- Tao bang FACT
/*
rental_id,
---
customer_key, 
staff_key,
film_key,
store_key,
rental_date_key, 
return_date_key,
payment_date_key,
--- 
amount
rental_rate
rental_duration
replacement_cost
*/
-- CREATE TABLE IF NOT EXISTS `starring-sakila`.`fact_sales1` (
--   `rental_id` INT NULL DEFAULT NULL,
--   `customer_key` INT NOT NULL,
--   `staff_key` INT NOT NULL,
--   `film_key` INT NOT NULL,
--   `store_key` INT NOT NULL,
--   `rental_date_key` INT NOT NULL,
--   `return_date_key` INT NOT NULL,
-- --  `payment_date_key` INT NOT NULL,
--   `amount` DECIMAL(5,2) NOT NULL,
--   `rental_rate` DECIMAL(5,2) NOT NULL,
--   `rental_duration` INT NOT NULL,
--   `replacement_cost` DECIMAL(5,2) NOT NULL,
-- --   INDEX `fk_customer_idx` (`customer_key` ASC) VISIBLE,
-- --   INDEX `fk_stafk_idx` (`staff_key` ASC) VISIBLE,
-- --   INDEX `fk_store_idx` (`store_key` ASC) VISIBLE,
-- --   INDEX `fk_film_idx` (`film_key` ASC) VISIBLE,
-- --   INDEX `fk_date_idx` (`date_key` ASC) VISIBLE,
--   CONSTRAINT `fk_customer`
--     FOREIGN KEY (`customer_key`)
--     REFERENCES `starring-sakila`.`customer_dim` (`customer_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--   CONSTRAINT `fk_staff`
--     FOREIGN KEY (`staff_key`)
--     REFERENCES `starring-sakila`.`staff_dim` (`staff_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--   CONSTRAINT `fk_store`
--     FOREIGN KEY (`store_key`)
--     REFERENCES `starring-sakila`.`store_dim` (`store_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--   CONSTRAINT `fk_film`
--     FOREIGN KEY (`film_key`)
--     REFERENCES `starring-sakila`.`film_dim` (`film_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--   CONSTRAINT `fk_rental_date`
--     FOREIGN KEY (`rental_date_key`)
--     REFERENCES `starring-sakila`.`date_dim` (`date_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION,
--     CONSTRAINT `fk_return_date`
--     FOREIGN KEY (`return_date_key`)
--     REFERENCES `starring-sakila`.`date_dim` (`date_key`)
--     ON DELETE CASCADE
--     ON UPDATE NO ACTION)
    
-- FACT TABLE
CREATE TABLE IF NOT EXISTS `starring-sakila`.`fact_sales2` (
  `rental_id` INT NULL DEFAULT NULL,
  `customer_key` INT NOT NULL,
  `staff_key` INT NOT NULL,
  `film_key` INT NOT NULL,
  `store_key` INT NOT NULL,
  `rental_date_key` INT NOT NULL,
  `return_date_key` INT NOT NULL,
  `payment_date_key` INT NOT NULL,
  `amount` DECIMAL(5,2) NOT NULL,
  `rental_rate` DECIMAL(5,2) NOT NULL,
  `rental_duration` INT NOT NULL,
  `replacement_cost` DECIMAL(5,2) NOT NULL,
--   INDEX `fk_customer_idx` (`customer_key` ASC) VISIBLE,
--   INDEX `fk_stafk_idx` (`staff_key` ASC) VISIBLE,
--   INDEX `fk_store_idx` (`store_key` ASC) VISIBLE,
--   INDEX `fk_film_idx` (`film_key` ASC) VISIBLE,
--   INDEX `fk_date_idx` (`date_key` ASC) VISIBLE,
  CONSTRAINT `fk_customer2`
    FOREIGN KEY (`customer_key`)
    REFERENCES `starring-sakila`.`customer_dim` (`customer_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_staff2`
    FOREIGN KEY (`staff_key`)
    REFERENCES `starring-sakila`.`staff_dim` (`staff_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_store2`
    FOREIGN KEY (`store_key`)
    REFERENCES `starring-sakila`.`store_dim` (`store_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_film2`
    FOREIGN KEY (`film_key`)
    REFERENCES `starring-sakila`.`film_dim` (`film_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rental_date2`
    FOREIGN KEY (`rental_date_key`)
    REFERENCES `starring-sakila`.`date_dim` (`date_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_date2`
    FOREIGN KEY (`payment_date_key`)
    REFERENCES `starring-sakila`.`date_dim` (`date_key`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_return_date2`
	FOREIGN KEY (`return_date_key`)
	REFERENCES `starring-sakila`.`date_dim`(`date_key`)
	ON DELETE CASCADE
	ON UPDATE NO ACTION);
    
ALTER TABLE `starring-sakila`.`fact_sales2`
ADD CONSTRAINT `composite_key_constraint`
PRIMARY KEY (customer_key, staff_key, film_key, store_key, rental_date_key, return_date_key, payment_date_key);

-- FOR TESTING SCD TYPE 2
CREATE TABLE staff_dim2(staff_key INT NOT NULL PRIMARY KEY);
ALTER TABLE `starring-sakila`.`staff_dim2` 
ADD COLUMN `staff_id` INT NULL AFTER `staff_key`,
ADD COLUMN `first_name` VARCHAR(45) NULL AFTER `staff_id`,
ADD COLUMN `last_name` VARCHAR(45) NULL AFTER `first_name`,
ADD COLUMN `email` VARCHAR(45) NULL AFTER `last_name`,
ADD COLUMN `staff_store_id` INT NULL AFTER `email`,
ADD COLUMN `active` INT NULL AFTER `staff_store_id`,
ADD COLUMN `manager_staff_id` INT NULL AFTER `active`,
ADD COLUMN start_date DATE,
ADD COLUMN end_date DATE,
ADD COLUMN active_flag CHAR(3);
ALTER TABLE staff_dim2 MODIFY staff_key INT AUTO_INCREMENT;
ALTER TABLE staff_dim2 MODIFY start_date VARCHAR(45);
ALTER TABLE staff_dim2 MODIFY end_date VARCHAR(45);