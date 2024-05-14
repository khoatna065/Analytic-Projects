/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio_project..[Nashville Housing]

---------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select
	SaleDate,
	convert(date, saledate) as SaleDateConverted
From Portfolio_project..[Nashville Housing]

Update [Nashville Housing]
Set SaleDate = convert(date, SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From Portfolio_project..[Nashville Housing]
Where PropertyAddress is not null
Order by ParcelID

Select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) as address_to_be_filled
From Portfolio_project..[Nashville Housing] a
Join Portfolio_project..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ] 
Where a.PropertyAddress is null

Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_project..[Nashville Housing] a
Join Portfolio_project..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
--PropertyAddress

Select 
	PropertyAddress
From Portfolio_project..[Nashville Housing]

Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as city
From Portfolio_project..[Nashville Housing]

Alter table [Nashville Housing]
Add PropertySplitAddress nvarchar(255);

Update [Nashville Housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table [Nashville Housing]
Add PropertySplitCity nvarchar(255);

Update [Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress

Select 
	OwnerAddress
From Portfolio_project..[Nashville Housing]
Where OwnerAddress is not null

Select 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state
From Portfolio_project..[Nashville Housing]
Where OwnerAddress is not null

Alter table [Nashville Housing]
Add OwnerSplitAddress nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table [Nashville Housing]
Add OwnerSplitCity nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table [Nashville Housing]
Add OwnerSplitState nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from Portfolio_project..[Nashville Housing]

---------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select 
	distinct(SoldAsVacant),
	count(SoldAsVacant) 
From Portfolio_project..[Nashville Housing]
Group by SoldAsVacant
Order by SoldAsVacant

Select	
	SoldAsVacant,
	Case when SoldAsVacant = 'N' then 'No'
		when SoldAsVacant = 'Y' then 'Yes' 
		else SoldAsVacant end 
From Portfolio_project..[Nashville Housing]

Update Portfolio_project..[Nashville Housing]
Set SoldAsVacant = Case when SoldAsVacant = 'N' then 'No'
						when SoldAsVacant = 'Y' then 'Yes' 
						else soldAsvacant end 

---------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with 
row_num_data as 
(
	Select 
		*,
		ROW_NUMBER() over (partition by parcelid, propertyaddress, saleprice, saledate, legalreference 
							order by uniqueid) as row_num
	From Portfolio_project..[Nashville Housing]
)
delete
from row_num_data
where row_num > 1;

---------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

select *
from Portfolio_project..[Nashville Housing]

Alter table Portfolio_project..[Nashville Housing]
Drop column owneraddress, taxdistrict, propertyaddress, saledate