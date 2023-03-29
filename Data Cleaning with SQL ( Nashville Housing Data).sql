--********Cleaning Data in SQL*******

select*
from PortfolioProject..NashvilleHousing
-----------------------------------------------------------------------------------------------------------
--Standardize Date Format

select SaleDateConverted --CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)
----------------------------------------------------------------------------------------------------------------------
--Populate Property address Data

select*
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress)) as City

from NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress))

select*
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Owner's Address into Individual columns (Address, City, State)

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace (OwnerAddress,',','.'),3),
PARSENAME(replace (OwnerAddress,',','.'),2),
PARSENAME(replace (OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


Alter Table portfolioproject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

update portfolioproject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace (OwnerAddress,',','.'),3)


Alter Table portfolioproject..NashvilleHousing
Add OwnerSplitcity nvarchar(255)

update portfolioproject..NashvilleHousing
set OwnerSplitcity = PARSENAME(replace (OwnerAddress,',','.'),2)


Alter Table portfolioproject..NashvilleHousing
Add OwnerSplitState nvarchar(255)

update portfolioproject..NashvilleHousing
set OwnerSplitState = PARSENAME(replace (OwnerAddress,',','.'),1)


select*
from portfolioproject..NashvilleHousing
------------------------------------------------------------------------------------------------------------------------
--Changing  Y and N to Yes and No "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from portfolioproject..NashvilleHousing

update portfolioproject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
-----------------------------------------------------------------------------------------
-- Removing Duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by parcelID, 
				 propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					uniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select*
from RowNumCTE
where row_num>1
--order by PropertyAddress

--------------------------------------------------------------------------------
--Deleting Unused Columns

select*
from portfolioproject..NashvilleHousing

alter table portfolioproject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolioproject..NashvilleHousing
drop column saledate