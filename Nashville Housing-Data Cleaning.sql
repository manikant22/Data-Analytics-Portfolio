select *
from nashville_housing 


------------------------ Populate Property Address  ------------------------

Select *
From nashville_housing 
WHERE TRIM(PropertyAddress) = '' OR PropertyAddress IS NULL;
--- order by ParcelID



SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
    nashville_housing a
JOIN 
    nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE 
    TRIM(a.PropertyAddress) = '' OR a.PropertyAddress IS NULL;


UPDATE nashville_housing a
JOIN nashville_housing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL OR TRIM(a.PropertyAddress) = '';

--------------------------------------------------------------------------------------

----Breaking out address into individual columns (Address,city,state)

select propertyaddress
from nashville_housing

select 
SUBSTRING(propertyaddress, 1, INSTR(propertyaddress, ',') -1) as Address,
SUBSTRING(propertyaddress, INSTR(propertyaddress, ',') +1 , LENGTH(propertyaddress)) as City
from nashville_housing 


alter table  nashville_housing 
add property_split_add Nvarchar(255);

update nashville_housing 
set property_split_add = SUBSTRING(propertyaddress, 1, INSTR(propertyaddress, ',') -1)

alter table nashville_housing 
add property_split_city Nvarchar(255)

update nashville_housing 
set property_split_city = SUBSTRING(propertyaddress, INSTR(propertyaddress, ',') +1 , LENGTH(propertyaddress))

select *
from nashville_housing 


--- now the owner's address ---



select select owneraddress
from nashville_housing




SELECT
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1)) AS Street,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1), ',', -1)) AS State
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD COLUMN OwnerStreet VARCHAR(255),
ADD COLUMN OwnerCity VARCHAR(255),
ADD COLUMN OwnerState VARCHAR(255);


UPDATE nashville_housing
SET 
  OwnerStreet = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
  OwnerCity   = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
  OwnerState  = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

select *
from nashville_housing
-----------------------------------------------------------------------------------------------

--- Change Y and N to Yes and No in "Sold as Vacant" field ---


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville_housing 
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing 




update nashville_housing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-------------------------------------------------------------------------------------------------

-- Remove Duplicates--


WITH RowNumCTE AS (
  SELECT *, 
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM nashville_housing
)
Delete *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



-----------------------------------------------------------------------------------------------

--- delete unused columns ------

Select *
From nashville_housing 


ALTER TABLE nashville_housing 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

-----------------------------------------------------------------------------------------------
