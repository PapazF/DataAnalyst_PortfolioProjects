/* DATA CLEANING SQL QUERIES of the Vancouver Business Licences Dataset*/

SELECT *
FROM business_licence
LIMIT 10;

-- Standardize Date format for column FolderYear show only YEAR
ALTER TABLE business_licence
MODIFY COLUMN FolderYear YEAR;

/* Had some missing values in the column TradeName (Name under which business is usually conducted), 
used column BusinessName (The ownership of the business) to populate missing values */
SELECT 
    BusinessName, 
    TradeName,
    CASE WHEN TradeName = '' THEN BusinessName
    ELSE TradeName END AS BusinessTradeName
FROM business_licence;

ALTER TABLE business_licence
ADD BusinessTradeName varchar(150);

UPDATE business_licence
SET BusinessTradeName =  CASE WHEN TradeName = '' THEN BusinessName
		         ELSE TradeName END;
                        
ALTER TABLE business_licence
MODIFY COLUMN BusinessTradeName varchar(150) AFTER TradeName; -- Change column position

-- Standardize Date format 
UPDATE business_licence
SET IssuedDate = DATE(IssuedDate);

/* Had some missing values in the column SubType(Sub-category(s) of the main business type), 
used column BusinessType(Description of the business activity) to populate missing values */
SELECT 
    BusinessType,
    SubType,
    CASE WHEN SubType = '' THEN BusinessType
    ELSE SubType END AS BusinessSubType
FROM business_licence;

ALTER TABLE business_licence
ADD COLUMN BusinessSubType varchar(150);

UPDATE business_licence
SET BusinessSubType = CASE WHEN SubType = '' THEN BusinessType
		      ELSE SubType END;
                    
ALTER TABLE business_licence
MODIFY COLUMN BusinessSubType varchar(150) AFTER SubType; -- Change column position

-- Breaking out BusinessAddress('MAIN ST, Vancouver, BC V5T 3C9') into individual columns (Street,City,Province,PostalCode)
SELECT 
    BusinessAddress,
    SUBSTRING_INDEX(BusinessAddress,',',1) AS Street,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',2),',',-1)) AS City,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',-1),' ',2)) AS Province, -- Had one sigle space after comma ', BC V5T 3C9'
    SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',-1),' ',-2) AS PostalCode
FROM business_licence;

ALTER TABLE business_licence
ADD COLUMN Street varchar(50);

UPDATE business_licence
SET Street = SUBSTRING_INDEX(BusinessAddress,',',1);

ALTER TABLE business_licence
ADD COLUMN City varchar(50);

UPDATE business_licence
SET City = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',2),',',-1));

ALTER TABLE business_licence
ADD COLUMN Province varchar(50);

UPDATE business_licence
SET Province = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',-1),' ',2));

ALTER TABLE business_licence
ADD COLUMN PostalCode varchar(50);

ALTER TABLE business_licence
MODIFY COLUMN PostalCode varchar(50);

UPDATE business_licence
SET PostalCode = SUBSTRING_INDEX(SUBSTRING_INDEX(BusinessAddress,',',-1),' ',-2);

-- Check for Duplicates
WITH RowNum AS (
  SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY LicenceRSN, LicenceNumber
	ORDER BY LicenceRSN) row_num
FROM business_licence
)
SELECT *
FROM RowNum
WHERE row_num > 1
ORDER BY LicenceRSN;

-- Removing unused columns 
ALTER TABLE business_licence
DROP COLUMN Unit;

ALTER TABLE business_licence
DROP COLUMN UnitType;

ALTER TABLE business_licence
DROP COLUMN BusinessAddress;a
