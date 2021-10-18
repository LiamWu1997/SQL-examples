--------------------------------------------------------------------------------------------------------------------------
--This is a practice project for SQL Data Cleaning------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------


Select *
From PortfolioProject .dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject .dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT (DATE, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT (DATE, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data because some cells are NULL

Select *
From PortfolioProject .dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- Lookup address with the same parcelID, they belong to the same address, but some cells are NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject .dbo.NashvilleHousing a
JOIN PortfolioProject .dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a. PropertyAddress is null


-- Use ISNULL to populate all null cells in the propertyAddress column

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject .dbo.NashvilleHousing a
JOIN PortfolioProject .dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a. PropertyAddress is null



--Update/populate the data into the null cells

Update a --have to use alias instead of the actual name
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject .dbo.NashvilleHousing a
JOIN PortfolioProject .dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


-- Lookup again, all null cells have been filled

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject .dbo.NashvilleHousing a
JOIN PortfolioProject .dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a. PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject .dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- Use SUBSTRING AND CHARINDEX to look for ',' which is the delimiter 
select
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
From PortfolioProject .dbo.NashvilleHousing

-- Cant separete 2 values from 2 columns without creating 2 additional ones, so have to create 2 new columns and populate the results

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set propertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousing
Set propertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


--For OwnerAddress column, I try using PARSENAME instead of SUBSTRING to separate the delimiters
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--PARSENAME only reads periods
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


--Create new columns and update the tables 
Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--Case statement
Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates using ROW_NUMBER
-- Partition on data that are unique to each row

--Use CTE
WITH RowNumCTE As(
Select *,
	ROW_Number() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num


From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From PortfolioProject.dbo.NashvilleHousing




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
















