-- Cleaning Data with SQL Queries: 

SELECT *
FROM portfolioproject.dbo.NashvilleHousing

-------------------------------------------------------------------------------

-- Standardize Date Format:

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD Sale_Date_Converted DATE;

UPDATE portfolioproject.dbo.NashvilleHousing
SET Sale_Date_Converted = CONVERT(DATE, SaleDate);

SELECT Sale_Date_Converted
FROM portfolioproject.dbo.NashvilleHousing

-------------------------------------------------------------------------------

-- Populate Property Address Data:

SELECT *
FROM portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID , A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing A
JOIN portfolioproject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing A
JOIN portfolioproject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

-------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM portfolioproject.dbo.NashvilleHousing

--Alter Tables:

--[1.SUBSTRING METHOD]

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--[2. PARSENAME METHOD]

SELECT OwnerAddress
FROM portfolioproject.dbo.NashvilleHousing

SELECT
PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 3)
,PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 2)
,PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 1)
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD Owner_Split_Address NVARCHAR(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET Owner_Split_Address = PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 3)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD Owner_Split_City NVARCHAR(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET Owner_Split_City = PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 2) 

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD Owner_Split_State NVARCHAR(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET Owner_Split_State = PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 1)

-------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field:

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference 
	ORDER BY UniqueID) row_num

FROM portfolioproject.dbo.NashvilleHousing
--ORDER BY PropertyAddress
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate

-- Modify all NULL values to 'NA'

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN YearBuilt VARCHAR(10);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN Bedrooms VARCHAR(10);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN FullBath VARCHAR(10);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN HalfBath VARCHAR(10);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN Acreage VARCHAR(10);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN BuildingValue VARCHAR(30);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN LandValue VARCHAR(30);

ALTER TABLE portfolioproject.dbo.NashvilleHousing
ALTER COLUMN TotalValue VARCHAR(30);

-- Update all NULL values to 'NA'

UPDATE portfolioproject.dbo.NashvilleHousing
SET OwnerName = CASE WHEN OwnerName IS NULL THEN 'NA' ELSE OwnerName END;

UPDATE portfolioproject.dbo.NashvilleHousing
SET Acreage = CASE WHEN Acreage IS NULL THEN 'NA' ELSE Acreage END;

UPDATE portfolioproject.dbo.NashvilleHousing
SET LandValue = 'NA'
WHERE LandValue IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET TotalValue = 'NA'
WHERE TotalValue IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET BuildingValue = 'NA'
WHERE BuildingValue IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET YearBuilt = 'NA'
WHERE YearBuilt IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET Bedrooms = 'NA'
WHERE Bedrooms IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET FullBath = 'NA'
WHERE FullBath IS NULL;

UPDATE portfolioproject.dbo.NashvilleHousing
SET HalfBath = 'NA'
WHERE HalfBath IS NULL;
