-- Data cleaning SQL queries 

Select *
From dbo.housingTable


-- Updating table with new Date format to Standarize sale date
Select convertedSaleDate
From dbo.housingTable

ALTER TABLE dbo.housingTable
Add convertedSaleDate Date;

Update dbo.housingTable
Set convertedSaleDate = CONVERT(Date, SaleDate)

ALTER TABLE dbo.housingTable
DROP COLUMN SaleDate;

/* Populating Property Address field where it's null
	with the porperty address of another field wher both fields
	have the same parcel ID */


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress)
From dbo.housingTable a
JOIN dbo.housingTable b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, B.PropertyAddress)
From dbo.housingTable a
JOIN dbo.housingTable b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking Property Address into address and city columns using substring

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From dbo.housingTable

ALTER TABLE dbo.housingTable
Add PropertySplitAddress Nvarchar(255);

Update dbo.housingTable
Set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE dbo.housingTable
Add PropertySplitCity Nvarchar(255);

Update dbo.housingTable
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From dbo.housingTable

-- Breaking Owner Address into address, city and state columns using parcing


ALTER TABLE dbo.housingTable
Add OwnerSplitAddress Nvarchar(255);

Update dbo.housingTable
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE dbo.housingTable
Add OwnerSplitCity Nvarchar(255);

Update dbo.housingTable
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE dbo.housingTable
Add OwnerSplitState Nvarchar(255);

Update dbo.housingTable
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-- Unifying sold as vacant column, changinf Y to Yes and N to No

Update dbo.housingTable
SET SoldAsVacant = 
CASE When SoldAsVacant='Y' Then 'Yes'
	 When SoldAsVacant='N' Then 'No'
	 ELSE SoldAsVacant
	 END


-- Removing duplicates using temp table

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 convertedSaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.housingTable
)

DELETE
From RowNumCTE
Where row_num > 1


--Deleting unused columns

ALTER TABLE dbo.housingTable
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



